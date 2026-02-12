import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_protocol.dart';

class FastingProtocolModel extends FastingProtocol {
  const FastingProtocolModel({
    super.id,
    required super.name,
    required super.fastingHours,
    required super.eatingHours,
    super.isCustom,
  });

  factory FastingProtocolModel.fromMap(Map<String, dynamic> map) {
    return FastingProtocolModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      fastingHours: map['fasting_hours'] as int,
      eatingHours: map['eating_hours'] as int,
      isCustom: (map['is_custom'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'fasting_hours': fastingHours,
      'eating_hours': eatingHours,
      'is_custom': isCustom ? 1 : 0,
    };
  }
}
