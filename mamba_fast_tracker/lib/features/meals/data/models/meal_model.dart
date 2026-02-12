import 'package:mamba_fast_tracker/features/meals/domain/entities/meal.dart';

class MealModel extends Meal {
  const MealModel({
    super.id,
    required super.name,
    required super.calories,
    required super.dateTime,
  });

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      calories: map['calories'] as int,
      dateTime: DateTime.parse(map['date_time'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'calories': calories,
      'date_time': dateTime.toIso8601String(),
    };
  }

  factory MealModel.fromEntity(Meal meal) {
    return MealModel(
      id: meal.id,
      name: meal.name,
      calories: meal.calories,
      dateTime: meal.dateTime,
    );
  }
}
