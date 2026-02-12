import 'package:equatable/equatable.dart';

class Meal extends Equatable {
  final int? id;
  final String name;
  final int calories;
  final DateTime dateTime;

  const Meal({
    this.id,
    required this.name,
    required this.calories,
    required this.dateTime,
  });

  Meal copyWith({
    int? id,
    String? name,
    int? calories,
    DateTime? dateTime,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  @override
  List<Object?> get props => [id, name, calories, dateTime];
}
