import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/features/meals/domain/entities/meal.dart';
import 'package:mamba_fast_tracker/features/meals/domain/repositories/meal_repository.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/cubit/meal_state.dart';

class MealCubit extends Cubit<MealState> {
  final MealRepository _mealRepository;

  MealCubit(this._mealRepository) : super(MealInitial());

  Future<void> loadMeals({DateTime? date}) async {
    emit(MealLoading());
    try {
      final selectedDate = date ?? DateTime.now();
      final meals = await _mealRepository.getMealsByDate(selectedDate);
      final totalCalories = await _mealRepository.getTotalCaloriesByDate(selectedDate);
      emit(MealLoaded(
        meals: meals,
        totalCalories: totalCalories,
        selectedDate: selectedDate,
      ));
    } catch (e) {
      emit(MealError(e.toString()));
    }
  }

  Future<void> addMeal(String name, int calories) async {
    try {
      final meal = Meal(
        name: name,
        calories: calories,
        dateTime: DateTime.now(),
      );
      await _mealRepository.addMeal(meal);

      final currentState = state;
      final date = currentState is MealLoaded ? currentState.selectedDate : DateTime.now();
      await loadMeals(date: date);
    } catch (e) {
      emit(MealError(e.toString()));
    }
  }

  Future<void> updateMeal(Meal meal) async {
    try {
      await _mealRepository.updateMeal(meal);
      final currentState = state;
      final date = currentState is MealLoaded ? currentState.selectedDate : DateTime.now();
      await loadMeals(date: date);
    } catch (e) {
      emit(MealError(e.toString()));
    }
  }

  Future<void> deleteMeal(int id) async {
    try {
      await _mealRepository.deleteMeal(id);
      final currentState = state;
      final date = currentState is MealLoaded ? currentState.selectedDate : DateTime.now();
      await loadMeals(date: date);
    } catch (e) {
      emit(MealError(e.toString()));
    }
  }
}
