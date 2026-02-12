import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/core/theme/app_theme.dart';
import 'package:mamba_fast_tracker/core/utils/date_utils.dart';
import 'package:mamba_fast_tracker/features/history/presentation/cubit/history_cubit.dart';
import 'package:mamba_fast_tracker/features/history/presentation/cubit/history_state.dart';
import 'package:mamba_fast_tracker/core/utils/strings.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.historyTitle),
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistoryError) {
            return Center(child: Text('Erro: ${state.message}'));
          }

          if (state is HistoryLoaded) {
            if (state.summaries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history,
                        size: 64,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.noHistoryFound,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<HistoryCubit>().loadHistory(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.summaries.length,
                itemBuilder: (context, index) {
                  final summary = state.summaries[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: summary.isWithinGoal
                            ? AppTheme.accentGreen.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppDateUtils.formatDate(summary.date),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: summary.isWithinGoal
                                    ? AppTheme.accentGreen.withValues(alpha: 0.2)
                                    : AppTheme.accentOrange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                summary.isWithinGoal ? AppStrings.metaTag : AppStrings.outsideTag,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: summary.isWithinGoal
                                      ? AppTheme.accentGreen
                                      : AppTheme.accentOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.local_fire_department,
                              color: AppTheme.accentOrange,
                              label: '${summary.totalCalories} ${AppStrings.unitKcal}',
                            ),
                            const SizedBox(width: 12),
                            _InfoChip(
                              icon: Icons.timer,
                              color: AppTheme.primaryColor,
                              label: summary.fastingTimeFormatted,
                            ),
                            const SizedBox(width: 12),
                            _InfoChip(
                              icon: Icons.restaurant,
                              color: AppTheme.secondaryColor,
                              label: '${summary.mealsCount} ${AppStrings.unitRef}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}
