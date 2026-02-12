import 'package:equatable/equatable.dart';

class FastingProtocol extends Equatable {
  final int? id;
  final String name;
  final int fastingHours;
  final int eatingHours;
  final bool isCustom;

  const FastingProtocol({
    this.id,
    required this.name,
    required this.fastingHours,
    required this.eatingHours,
    this.isCustom = false,
  });

  @override
  List<Object?> get props => [id, name, fastingHours, eatingHours, isCustom];
}
