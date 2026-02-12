import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/features/daily_summary/domain/entities/daily_summary.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/repositories/fasting_repository.dart';
import 'package:mamba_fast_tracker/features/meals/domain/repositories/meal_repository.dart';
import 'package:mamba_fast_tracker/features/daily_summary/presentation/cubit/daily_summary_state.dart';

class DailySummaryCubit extends Cubit<DailySummaryState> {
  final MealRepository _mealRepository;
  final FastingRepository _fastingRepository;

  DailySummaryCubit(this._mealRepository, this._fastingRepository)
      : super(DailySummaryInitial());

  Future<void> loadSummary({DateTime? date}) async {
    emit(DailySummaryLoading());
    try {
      final selectedDate = date ?? DateTime.now();
      final totalCalories = await _mealRepository.getTotalCaloriesByDate(selectedDate);
      final totalFastingMinutes =
          await _fastingRepository.getTotalFastingMinutesByDate(selectedDate);
      final meals = await _mealRepository.getMealsByDate(selectedDate);
      final sessions = await _fastingRepository.getSessionsByDate(selectedDate);

      // Get target from the most recent session's protocol
      int targetMinutes = 16 * 60; // Default 16h
      if (sessions.isNotEmpty) {
        targetMinutes = sessions.first.fastingHours * 60;
      }

      final summary = DailySummary(
        date: selectedDate,
        totalCalories: totalCalories,
        totalFastingMinutes: totalFastingMinutes,
        targetFastingMinutes: targetMinutes,
        mealsCount: meals.length,
      );
      emit(DailySummaryLoaded(summary));
    } catch (e) {
      emit(DailySummaryError(e.toString()));
    }
  }
}
