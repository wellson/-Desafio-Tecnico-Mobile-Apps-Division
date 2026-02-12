import 'package:mamba_fast_tracker/core/database/database_helper.dart';
import 'package:mamba_fast_tracker/core/utils/constants.dart';
import 'package:mamba_fast_tracker/features/meals/data/models/meal_model.dart';

class MealLocalDatasource {
  Future<int> insertMeal(MealModel meal) async {
    final db = await DatabaseHelper.database;
    return db.insert(AppConstants.mealsTable, meal.toMap());
  }

  Future<void> updateMeal(MealModel meal) async {
    final db = await DatabaseHelper.database;
    await db.update(
      AppConstants.mealsTable,
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<void> deleteMeal(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      AppConstants.mealsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MealModel>> getMealsByDate(DateTime date) async {
    final db = await DatabaseHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final maps = await db.query(
      AppConstants.mealsTable,
      where: 'date_time BETWEEN ? AND ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date_time DESC',
    );
    return maps.map((m) => MealModel.fromMap(m)).toList();
  }

  Future<int> getTotalCaloriesByDate(DateTime date) async {
    final db = await DatabaseHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT SUM(calories) as total
      FROM ${AppConstants.mealsTable}
      WHERE date_time BETWEEN ? AND ?
    ''', [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);

    return result.first['total'] as int? ?? 0;
  }

  Future<List<MealModel>> getMealsInRange(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      AppConstants.mealsTable,
      where: 'date_time BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date_time ASC',
    );
    return maps.map((m) => MealModel.fromMap(m)).toList();
  }
}
