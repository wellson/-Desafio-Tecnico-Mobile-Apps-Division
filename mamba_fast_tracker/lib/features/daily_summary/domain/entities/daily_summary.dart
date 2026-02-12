import 'package:equatable/equatable.dart';

class DailySummary extends Equatable {
  final DateTime date;
  final int totalCalories;
  final int totalFastingMinutes;
  final int targetFastingMinutes;
  final int mealsCount;

  const DailySummary({
    required this.date,
    required this.totalCalories,
    required this.totalFastingMinutes,
    required this.targetFastingMinutes,
    required this.mealsCount,
  });

  bool get isWithinGoal => totalFastingMinutes >= targetFastingMinutes;

  String get fastingTimeFormatted {
    final hours = totalFastingMinutes ~/ 60;
    final minutes = totalFastingMinutes % 60;
    return '${hours}h ${minutes}min';
  }

  String get targetFormatted {
    final hours = targetFastingMinutes ~/ 60;
    final minutes = targetFastingMinutes % 60;
    return '${hours}h ${minutes}min';
  }

  double get fastingProgress {
    if (targetFastingMinutes == 0) return 0;
    return (totalFastingMinutes / targetFastingMinutes).clamp(0.0, 1.0);
  }

  @override
  List<Object> get props => [
        date,
        totalCalories,
        totalFastingMinutes,
        targetFastingMinutes,
        mealsCount,
      ];
}
