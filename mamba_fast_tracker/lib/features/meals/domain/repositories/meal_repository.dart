import 'package:mamba_fast_tracker/features/meals/domain/entities/meal.dart';

abstract class MealRepository {
  Future<int> addMeal(Meal meal);
  Future<void> updateMeal(Meal meal);
  Future<void> deleteMeal(int id);
  Future<List<Meal>> getMealsByDate(DateTime date);
  Future<int> getTotalCaloriesByDate(DateTime date);
  Future<List<Meal>> getMealsInRange(DateTime start, DateTime end);
}
