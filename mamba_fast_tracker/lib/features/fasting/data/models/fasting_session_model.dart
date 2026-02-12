import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_session.dart';

class FastingSessionModel extends FastingSession {
  const FastingSessionModel({
    super.id,
    required super.protocolName,
    required super.fastingHours,
    required super.eatingHours,
    required super.startTime,
    super.endTime,
    super.status,
    super.elapsedSeconds,
  });

  factory FastingSessionModel.fromMap(Map<String, dynamic> map) {
    return FastingSessionModel(
      id: map['id'] as int?,
      protocolName: map['protocol_name'] as String,
      fastingHours: map['fasting_hours'] as int,
      eatingHours: map['eating_hours'] as int,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
      status: _parseStatus(map['status'] as String),
      elapsedSeconds: map['elapsed_seconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'protocol_name': protocolName,
      'fasting_hours': fastingHours,
      'eating_hours': eatingHours,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status.name,
      'elapsed_seconds': elapsedSeconds,
    };
  }

  static FastingStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return FastingStatus.active;
      case 'completed':
        return FastingStatus.completed;
      case 'cancelled':
        return FastingStatus.cancelled;
      default:
        return FastingStatus.active;
    }
  }

  factory FastingSessionModel.fromEntity(FastingSession session) {
    return FastingSessionModel(
      id: session.id,
      protocolName: session.protocolName,
      fastingHours: session.fastingHours,
      eatingHours: session.eatingHours,
      startTime: session.startTime,
      endTime: session.endTime,
      status: session.status,
      elapsedSeconds: session.elapsedSeconds,
    );
  }
}
