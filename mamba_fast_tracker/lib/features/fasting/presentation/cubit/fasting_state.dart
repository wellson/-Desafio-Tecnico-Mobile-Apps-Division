import 'package:equatable/equatable.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_session.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_protocol.dart';

abstract class FastingState extends Equatable {
  const FastingState();
  @override
  List<Object?> get props => [];
}

class FastingInitial extends FastingState {}

class FastingLoading extends FastingState {}

class FastingIdle extends FastingState {
  final List<FastingProtocol> protocols;
  final FastingProtocol? selectedProtocol;

  const FastingIdle({required this.protocols, this.selectedProtocol});

  @override
  List<Object?> get props => [protocols, selectedProtocol];
}

class FastingActive extends FastingState {
  final FastingSession session;
  final Duration elapsed;
  final Duration remaining;
  final double progress;
  final List<FastingProtocol> protocols;

  const FastingActive({
    required this.session,
    required this.elapsed,
    required this.remaining,
    required this.progress,
    required this.protocols,
  });

  @override
  List<Object?> get props => [session, elapsed, remaining, progress, protocols];
}

class FastingCompleted extends FastingState {
  final FastingSession session;
  final List<FastingProtocol> protocols;

  const FastingCompleted({required this.session, required this.protocols});

  @override
  List<Object?> get props => [session, protocols];
}

class FastingError extends FastingState {
  final String message;
  const FastingError(this.message);

  @override
  List<Object?> get props => [message];
}
