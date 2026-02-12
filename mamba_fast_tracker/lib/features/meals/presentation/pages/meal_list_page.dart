import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/core/theme/app_theme.dart';
import 'package:mamba_fast_tracker/core/utils/date_utils.dart';
import 'package:mamba_fast_tracker/features/meals/domain/entities/meal.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/cubit/meal_cubit.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/cubit/meal_state.dart';
import 'package:mamba_fast_tracker/core/utils/strings.dart';

class MealListPage extends StatelessWidget {
  const MealListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.mealsTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMealDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<MealCubit, MealState>(
        builder: (context, state) {
          if (state is MealLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MealError) {
            return Center(child: Text('${AppStrings.errorPrefix}${state.message}'));
          }

          if (state is MealLoaded) {
            return Column(
              children: [
                // Calorie summary card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.caloriesToday,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          Text(
                            '${state.totalCalories} ${AppStrings.unitKcal}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(Icons.restaurant, color: Colors.white70, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            '${state.meals.length} ${AppStrings.mealsCountLabel}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Meal list
                Expanded(
                  child: state.meals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu,
                                  size: 64, color: Theme.of(context).unselectedWidgetColor.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.noMealsRegistered,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppStrings.tapToAdd,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.meals.length,
                          itemBuilder: (context, index) {
                            final meal = state.meals[index];
                            return _buildMealCard(context, meal);
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Meal meal) {
    return Dismissible(
      key: Key('meal_${meal.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.accentRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (meal.id != null) {
          context.read<MealCubit>().deleteMeal(meal.id!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.fastfood, color: AppTheme.accentOrange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    AppDateUtils.formatTimeOnly(meal.dateTime),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text(
              '${meal.calories} ${AppStrings.unitKcal}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.accentOrange,
                  ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: AppTheme.textSecondary),
              onPressed: () => _showEditMealDialog(context, meal),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealDialog(BuildContext context) {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text(AppStrings.addMealTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.mealNameLabel,
                prefixIcon: Icon(Icons.restaurant),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.caloriesLabel,
                prefixIcon: Icon(Icons.local_fire_department),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final calories = int.tryParse(caloriesController.text) ?? 0;

              if (name.isNotEmpty && calories > 0) {
                context.read<MealCubit>().addMeal(name, calories);
                Navigator.pop(ctx);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showEditMealDialog(BuildContext context, Meal meal) {
    final nameController = TextEditingController(text: meal.name);
    final caloriesController =
        TextEditingController(text: meal.calories.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text(AppStrings.editMealTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.mealNameLabel,
                prefixIcon: Icon(Icons.restaurant),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.caloriesLabel,
                prefixIcon: Icon(Icons.local_fire_department),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final calories = int.tryParse(caloriesController.text) ?? 0;

              if (name.isNotEmpty && calories > 0) {
                context.read<MealCubit>().updateMeal(
                      meal.copyWith(name: name, calories: calories),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
