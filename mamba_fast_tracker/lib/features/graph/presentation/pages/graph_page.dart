import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphic/graphic.dart';
import 'package:mamba_fast_tracker/core/theme/app_theme.dart';
import 'package:mamba_fast_tracker/core/utils/date_utils.dart';
import 'package:mamba_fast_tracker/features/graph/presentation/cubit/graph_cubit.dart';
import 'package:mamba_fast_tracker/features/graph/presentation/cubit/graph_state.dart';
import 'package:mamba_fast_tracker/core/utils/strings.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  bool _showCalories = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.graphTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GraphCubit>().loadWeeklyData(),
          ),
        ],
      ),
      body: BlocBuilder<GraphCubit, GraphState>(
        builder: (context, state) {
          if (state is GraphLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GraphError) {
            return Center(child: Text('Erro: ${state.message}'));
          }

          if (state is GraphLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle button
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showCalories = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _showCalories
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  AppStrings.caloriesToggle,
                                  style: TextStyle(
                                    color: _showCalories
                                        ? Colors.white
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showCalories = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_showCalories
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  AppStrings.fastingToggle,
                                  style: TextStyle(
                                    color: !_showCalories
                                        ? Colors.white
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chart title
                  Text(
                    _showCalories
                        ? AppStrings.caloriesChartTitle
                        : AppStrings.fastingChartTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Chart
                  SizedBox(
                    height: 300,
                    child: _buildChart(state.weeklyData),
                  ),
                  const SizedBox(height: 24),

                  // Data table
                  Text(
                    AppStrings.detailsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...state.weeklyData.map((data) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppDateUtils.formatWeekday(data.date)} ${AppDateUtils.formatDayMonth(data.date)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              _showCalories
                                  ? '${data.calories.toInt()} ${AppStrings.unitKcal}'
                                  : '${data.fastingHours.toStringAsFixed(1)}h',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: _showCalories
                                        ? AppTheme.accentOrange
                                        : AppTheme.primaryColor,
                                  ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildChart(List<GraphData> data) {
    final chartData = data.asMap().entries.map((entry) {
      final d = entry.value;
      return {
        'day': AppDateUtils.formatWeekday(d.date),
        'value': _showCalories ? d.calories : d.fastingHours,
      };
    }).toList();

    if (chartData.every((d) => (d['value'] as double) == 0)) {
      return Center(
        child: Text(
          AppStrings.noDataToDisplay,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
      );
    }

    return Chart(
      data: chartData,
      variables: {
        'day': Variable(
          accessor: (Map map) => map['day'] as String,
        ),
        'value': Variable(
          accessor: (Map map) => map['value'] as num,
        ),
      },
      marks: [
        LineMark(
          color: ColorEncode(
            value: _showCalories
                ? AppTheme.accentOrange
                : AppTheme.primaryColor,
          ),
          size: SizeEncode(value: 3),
          shape: ShapeEncode(value: BasicLineShape(smooth: true)),
        ),
        PointMark(
          color: ColorEncode(
            value: _showCalories
                ? AppTheme.accentOrange
                : AppTheme.primaryColor,
          ),
          size: SizeEncode(value: 5),
        ),
      ],
      axes: [
        Defaults.horizontalAxis,
        Defaults.verticalAxis,
      ],
    );
  }
}
