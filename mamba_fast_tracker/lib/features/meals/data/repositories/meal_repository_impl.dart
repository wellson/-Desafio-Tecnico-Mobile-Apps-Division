import 'package:mamba_fast_tracker/features/meals/data/datasources/meal_local_datasource.dart';
import 'package:mamba_fast_tracker/features/meals/data/models/meal_model.dart';
import 'package:mamba_fast_tracker/features/meals/domain/entities/meal.dart';
import 'package:mamba_fast_tracker/features/meals/domain/repositories/meal_repository.dart';

class MealRepositoryImpl implements MealRepository {
  final MealLocalDatasource _localDatasource;

  MealRepositoryImpl(this._localDatasource);

  @override
  Future<int> addMeal(Meal meal) async {
    final model = MealModel.fromEntity(meal);
    return await _localDatasource.insertMeal(model);
  }

  @override
  Future<void> updateMeal(Meal meal) async {
    final model = MealModel.fromEntity(meal);
    await _localDatasource.updateMeal(model);
  }

  @override
  Future<void> deleteMeal(int id) async {
    await _localDatasource.deleteMeal(id);
  }

  @override
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    return await _localDatasource.getMealsByDate(date);
  }

  @override
  Future<int> getTotalCaloriesByDate(DateTime date) async {
    return await _localDatasource.getTotalCaloriesByDate(date);
  }

  @override
  Future<List<Meal>> getMealsInRange(DateTime start, DateTime end) async {
    return await _localDatasource.getMealsInRange(start, end);
  }
}
