import 'package:equatable/equatable.dart';
import 'package:mamba_fast_tracker/features/meals/domain/entities/meal.dart';

abstract class MealState extends Equatable {
  const MealState();
  @override
  List<Object?> get props => [];
}

class MealInitial extends MealState {}

class MealLoading extends MealState {}

class MealLoaded extends MealState {
  final List<Meal> meals;
  final int totalCalories;
  final DateTime selectedDate;

  const MealLoaded({
    required this.meals,
    required this.totalCalories,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [meals, totalCalories, selectedDate];
}

class MealError extends MealState {
  final String message;
  const MealError(this.message);

  @override
  List<Object?> get props => [message];
}
