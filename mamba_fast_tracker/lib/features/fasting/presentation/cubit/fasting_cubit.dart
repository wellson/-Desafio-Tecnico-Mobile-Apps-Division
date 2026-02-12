import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mamba_fast_tracker/core/services/background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/core/notifications/notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_protocol.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_session.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/repositories/fasting_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/cubit/fasting_state.dart';

class FastingCubit extends Cubit<FastingState> {
  final FastingRepository _fastingRepository;
  final NotificationService _notificationService;
  final BackgroundService _backgroundService;
  Timer? _timer;

  FastingCubit(
    this._fastingRepository,
    this._notificationService, {
    BackgroundService? backgroundService,
  })  : _backgroundService = backgroundService ?? BackgroundService(),
        super(FastingInitial());

  Future<void> loadInitialState() async {
    emit(FastingLoading());
    try {
      final protocols = await _fastingRepository.getProtocols();
      final activeSession = await _fastingRepository.getActiveSession();

      if (activeSession != null) {
        // Check if session has naturally completed while app was closed
        final elapsed = DateTime.now().difference(activeSession.startTime);
        final totalDuration = Duration(hours: activeSession.fastingHours);

        if (elapsed >= totalDuration) {
          // Session completed while app was in background
          await _fastingRepository.endFasting(
            activeSession.id!,
            FastingStatus.completed,
          );
          emit(FastingCompleted(session: activeSession, protocols: protocols));
        } else {
          _startTicker(activeSession, protocols);
        }
      } else {
        emit(FastingIdle(
          protocols: protocols,
          selectedProtocol: protocols.isNotEmpty ? protocols.first : null,
        ));
      }
    } catch (e) {
      emit(FastingError(e.toString()));
    }
  }

  void selectProtocol(FastingProtocol protocol) {
    final currentState = state;
    if (currentState is FastingIdle) {
      emit(FastingIdle(
        protocols: currentState.protocols,
        selectedProtocol: protocol,
      ));
    }
  }

  Future<void> startFasting(FastingProtocol protocol) async {
    try {
      final session = await _fastingRepository.startFasting(protocol);
      final protocols = await _fastingRepository.getProtocols();

      // Send notifications
      await _notificationService.showFastingStarted(); // Still show the initial toast-like notification
      final endTime = session.startTime.add(Duration(hours: protocol.fastingHours));
      await _notificationService.scheduleFastingEnd(endTime);

      // Start Background Service (Foreground Notification)
      try {
        _backgroundService.startService(session.startTime, protocol.fastingHours);
      } catch (e) {
        debugPrint('Failed to start background service: $e');
      }

      _startTicker(session, protocols);
    } catch (e) {
      emit(FastingError(e.toString()));
    }
  }

  Future<void> endFasting() async {
    _timer?.cancel();
    _backgroundService.stopService(); // Stop service
    try {
      final activeSession = await _fastingRepository.getActiveSession();
      if (activeSession != null) {
        await _fastingRepository.endFasting(
          activeSession.id!,
          FastingStatus.completed,
        );
        await _notificationService.cancelFastingNotifications();
      }

      final protocols = await _fastingRepository.getProtocols();
      emit(FastingIdle(
          protocols: protocols,
          selectedProtocol: protocols.isNotEmpty ? protocols.first : null));
    } catch (e) {
      emit(FastingError(e.toString()));
    }
  }

  Future<void> cancelFasting() async {
    _timer?.cancel();
    _backgroundService.stopService(); // Stop service
    try {
      final activeSession = await _fastingRepository.getActiveSession();
      if (activeSession != null) {
        await _fastingRepository.endFasting(
          activeSession.id!,
          FastingStatus.cancelled,
        );
        await _notificationService.cancelFastingNotifications();
      }

      final protocols = await _fastingRepository.getProtocols();
      emit(FastingIdle(
          protocols: protocols,
          selectedProtocol: protocols.isNotEmpty ? protocols.first : null));
    } catch (e) {
      emit(FastingError(e.toString()));
    }
  }

  Future<void> saveCustomProtocol(String name, int fastingHours, int eatingHours) async {
    try {
      final protocol = FastingProtocol(
        name: name,
        fastingHours: fastingHours,
        eatingHours: eatingHours,
        isCustom: true,
      );
      await _fastingRepository.saveCustomProtocol(protocol);
      final protocols = await _fastingRepository.getProtocols();

      final currentState = state;
      if (currentState is FastingIdle) {
        emit(FastingIdle(protocols: protocols, selectedProtocol: protocol));
      } else if (currentState is FastingActive) {
        emit(FastingActive(
          session: currentState.session,
          elapsed: currentState.elapsed,
          remaining: currentState.remaining,
          progress: currentState.progress,
          protocols: protocols,
        ));
      }
    } catch (e) {
      emit(FastingError(e.toString()));
    }
  }

  Future<void> deleteProtocol(int id) async {
    try {
      await _fastingRepository.deleteProtocol(id);
      final protocols = await _fastingRepository.getProtocols();
      
      final currentState = state;
      // If the deleted protocol was selected, deselect it
      FastingProtocol? selected;
      if (currentState is FastingIdle) {
        selected = currentState.selectedProtocol;
        if (selected?.id == id) {
          selected = protocols.isNotEmpty ? protocols.first : null;
        }
        emit(FastingIdle(protocols: protocols, selectedProtocol: selected));
      } else if (currentState is FastingActive) {
        emit(FastingActive(
          session: currentState.session,
          elapsed: currentState.elapsed,
          remaining: currentState.remaining,
          progress: currentState.progress,
          protocols: protocols,
        ));
      } else if (currentState is FastingCompleted) {
        emit(FastingCompleted(
          session: currentState.session,
          protocols: protocols,
        ));
      }
    } catch (e) {
      emit(FastingError(e.toString()));
    }
  }

  void _startTicker(FastingSession session, List<FastingProtocol> protocols) {
    _timer?.cancel();
    _emitActiveState(session, protocols);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = DateTime.now().difference(session.startTime);
      final totalDuration = Duration(hours: session.fastingHours);
      final remaining = totalDuration - elapsed;

      if (remaining.isNegative || remaining == Duration.zero) {
        _timer?.cancel();
        _fastingRepository.endFasting(session.id!, FastingStatus.completed);
        emit(FastingCompleted(session: session, protocols: protocols));
      } else {
        _emitActiveState(session, protocols);
      }
    });
  }

  void _emitActiveState(FastingSession session, List<FastingProtocol> protocols) {
    final elapsed = DateTime.now().difference(session.startTime);
    final totalDuration = Duration(hours: session.fastingHours);
    final remaining = totalDuration - elapsed;
    final progress = (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);

    emit(FastingActive(
      session: session,
      elapsed: elapsed,
      remaining: remaining.isNegative ? Duration.zero : remaining,
      progress: progress,
      protocols: protocols,
    ));
  }

  /// Called when the app resumes from background
  Future<void> onAppResumed() async {
    final activeSession = await _fastingRepository.getActiveSession();
    if (activeSession != null) {
      final protocols = await _fastingRepository.getProtocols();
      final elapsed = DateTime.now().difference(activeSession.startTime);
      final totalDuration = Duration(hours: activeSession.fastingHours);

      if (elapsed >= totalDuration) {
        _timer?.cancel();
        await _fastingRepository.endFasting(
          activeSession.id!,
          FastingStatus.completed,
        );
        emit(FastingCompleted(session: activeSession, protocols: protocols));
      } else {
        _startTicker(activeSession, protocols);
      }
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
