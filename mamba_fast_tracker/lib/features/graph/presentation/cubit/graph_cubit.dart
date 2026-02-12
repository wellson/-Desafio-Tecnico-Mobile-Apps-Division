import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/repositories/fasting_repository.dart';
import 'package:mamba_fast_tracker/features/meals/domain/repositories/meal_repository.dart';
import 'package:mamba_fast_tracker/features/graph/presentation/cubit/graph_state.dart';

class GraphCubit extends Cubit<GraphState> {
  final MealRepository _mealRepository;
  final FastingRepository _fastingRepository;

  GraphCubit(this._mealRepository, this._fastingRepository)
      : super(GraphInitial());

  Future<void> loadWeeklyData() async {
    emit(GraphLoading());
    try {
      final data = <GraphData>[];
      final now = DateTime.now();

      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);
        final calories = await _mealRepository.getTotalCaloriesByDate(date);
        final fastingMinutes =
            await _fastingRepository.getTotalFastingMinutesByDate(date);

        data.add(GraphData(
          date: date,
          calories: calories.toDouble(),
          fastingHours: fastingMinutes / 60.0,
        ));
      }

      emit(GraphLoaded(data));
    } catch (e) {
      emit(GraphError(e.toString()));
    }
  }
}
