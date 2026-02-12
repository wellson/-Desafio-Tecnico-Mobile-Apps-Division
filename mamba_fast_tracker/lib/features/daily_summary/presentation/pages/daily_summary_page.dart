import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/core/theme/app_theme.dart';
import 'package:mamba_fast_tracker/core/utils/date_utils.dart';
import 'package:mamba_fast_tracker/features/daily_summary/presentation/cubit/daily_summary_cubit.dart';
import 'package:mamba_fast_tracker/features/daily_summary/presentation/cubit/daily_summary_state.dart';
import 'package:mamba_fast_tracker/core/utils/strings.dart';

class DailySummaryPage extends StatelessWidget {
  const DailySummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dailySummaryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<DailySummaryCubit>().loadSummary(),
          ),
        ],
      ),
      body: BlocBuilder<DailySummaryCubit, DailySummaryState>(
        builder: (context, state) {
          if (state is DailySummaryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DailySummaryError) {
            return Center(child: Text('Erro: ${state.message}'));
          }

          if (state is DailySummaryLoaded) {
            final summary = state.summary;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date header
                  Text(
                    AppDateUtils.formatDate(summary.date),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),

                  // Goal status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: summary.isWithinGoal
                            ? [AppTheme.accentGreen, AppTheme.accentGreen.withValues(alpha: 0.7)]
                            : [AppTheme.accentOrange, AppTheme.accentOrange.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          summary.isWithinGoal
                              ? Icons.check_circle
                              : Icons.warning_amber,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary.isWithinGoal
                              ? AppStrings.withinGoal
                              : AppStrings.outsideGoal,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.local_fire_department,
                          iconColor: AppTheme.accentOrange,
                          label: AppStrings.caloriesStat,
                          value: '${summary.totalCalories}',
                          unit: 'kcal',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.restaurant,
                          iconColor: AppTheme.secondaryColor,
                          label: AppStrings.mealsStat,
                          value: '${summary.mealsCount}',
                          unit: '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.timer,
                          iconColor: AppTheme.primaryColor,
                          label: AppStrings.fastingTimeStat,
                          value: summary.fastingTimeFormatted,
                          unit: '',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.flag,
                          iconColor: AppTheme.accentGreen,
                          label: AppStrings.goalStat,
                          value: summary.targetFormatted,
                          unit: '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.fastingProgress,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: summary.fastingProgress,
                          minHeight: 12,
                          backgroundColor: Theme.of(context).cardTheme.color ?? Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                            summary.isWithinGoal
                                ? AppTheme.accentGreen
                                : AppTheme.accentOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(summary.fastingProgress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            unit.isNotEmpty ? '$value $unit' : value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
