import 'package:equatable/equatable.dart';

enum FastingStatus { active, completed, cancelled }

class FastingSession extends Equatable {
  final int? id;
  final String protocolName;
  final int fastingHours;
  final int eatingHours;
  final DateTime startTime;
  final DateTime? endTime;
  final FastingStatus status;
  final int elapsedSeconds;

  const FastingSession({
    this.id,
    required this.protocolName,
    required this.fastingHours,
    required this.eatingHours,
    required this.startTime,
    this.endTime,
    this.status = FastingStatus.active,
    this.elapsedSeconds = 0,
  });

  Duration get totalFastingDuration => Duration(hours: fastingHours);

  Duration get elapsed {
    if (status == FastingStatus.active) {
      return DateTime.now().difference(startTime);
    }
    return Duration(seconds: elapsedSeconds);
  }

  Duration get remaining {
    final rem = totalFastingDuration - elapsed;
    return rem.isNegative ? Duration.zero : rem;
  }

  double get progress {
    final total = totalFastingDuration.inSeconds;
    if (total == 0) return 0;
    final elap = elapsed.inSeconds;
    return (elap / total).clamp(0.0, 1.0);
  }

  bool get isCompleted => elapsed >= totalFastingDuration;

  FastingSession copyWith({
    int? id,
    String? protocolName,
    int? fastingHours,
    int? eatingHours,
    DateTime? startTime,
    DateTime? endTime,
    FastingStatus? status,
    int? elapsedSeconds,
  }) {
    return FastingSession(
      id: id ?? this.id,
      protocolName: protocolName ?? this.protocolName,
      fastingHours: fastingHours ?? this.fastingHours,
      eatingHours: eatingHours ?? this.eatingHours,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        protocolName,
        fastingHours,
        eatingHours,
        startTime,
        endTime,
        status,
        elapsedSeconds,
      ];
}
