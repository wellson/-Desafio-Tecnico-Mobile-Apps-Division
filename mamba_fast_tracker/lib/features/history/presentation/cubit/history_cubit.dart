import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/features/daily_summary/domain/entities/daily_summary.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/repositories/fasting_repository.dart';
import 'package:mamba_fast_tracker/features/meals/domain/repositories/meal_repository.dart';
import 'package:mamba_fast_tracker/features/history/presentation/cubit/history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final MealRepository _mealRepository;
  final FastingRepository _fastingRepository;

  HistoryCubit(this._mealRepository, this._fastingRepository)
      : super(HistoryInitial());

  Future<void> loadHistory() async {
    emit(HistoryLoading());
    try {
      final summaries = <DailySummary>[];
      final now = DateTime.now();

      // Load last 30 days
      for (int i = 0; i < 30; i++) {
        final date = DateTime(now.year, now.month, now.day - i);
        final totalCalories = await _mealRepository.getTotalCaloriesByDate(date);
        final totalFastingMinutes =
            await _fastingRepository.getTotalFastingMinutesByDate(date);
        final meals = await _mealRepository.getMealsByDate(date);
        final sessions = await _fastingRepository.getSessionsByDate(date);

        // Only add days that have data
        if (totalCalories > 0 || totalFastingMinutes > 0 || meals.isNotEmpty || sessions.isNotEmpty) {
          int targetMinutes = 16 * 60;
          if (sessions.isNotEmpty) {
            targetMinutes = sessions.first.fastingHours * 60;
          }

          summaries.add(DailySummary(
            date: date,
            totalCalories: totalCalories,
            totalFastingMinutes: totalFastingMinutes,
            targetFastingMinutes: targetMinutes,
            mealsCount: meals.length,
          ));
        }
      }

      emit(HistoryLoaded(summaries));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
