import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/cubit/meal_cubit.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/cubit/meal_state.dart';
import 'package:mamba_fast_tracker/features/meals/domain/repositories/meal_repository.dart';
import 'package:mamba_fast_tracker/features/meals/domain/entities/meal.dart';

class MockMealRepository extends Mock implements MealRepository {}

void main() {
  late MealCubit cubit;
  late MockMealRepository mockMealRepository;

  final testMeal = Meal(
    id: 1,
    name: 'Lunch',
    calories: 500,
    dateTime: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(testMeal);
  });

  setUp(() {
    mockMealRepository = MockMealRepository();
    cubit = MealCubit(mockMealRepository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is MealInitial', () {
    expect(cubit.state, isA<MealInitial>());
  });

  group('loadMeals', () {
    blocTest<MealCubit, MealState>(
      'emits [MealLoading, MealLoaded] when loading successful',
      build: () {
        when(() => mockMealRepository.getMealsByDate(any()))
            .thenAnswer((_) async => [testMeal]);
        when(() => mockMealRepository.getTotalCaloriesByDate(any()))
            .thenAnswer((_) async => 500);
        return cubit;
      },
      act: (cubit) => cubit.loadMeals(),
      expect: () => [
        isA<MealLoading>(),
        isA<MealLoaded>(),
      ],
    );
  });

  group('addMeal', () {
    blocTest<MealCubit, MealState>(
      'calls addMeal on repository and reloads',
      build: () {
        when(() => mockMealRepository.addMeal(any()))
            .thenAnswer((_) async => 1);
        when(() => mockMealRepository.getMealsByDate(any()))
            .thenAnswer((_) async => [testMeal]);
        when(() => mockMealRepository.getTotalCaloriesByDate(any()))
            .thenAnswer((_) async => 500);
        return cubit;
      },
      act: (cubit) => cubit.addMeal('Lunch', 500),
      expect: () => [
        isA<MealLoading>(),
        isA<MealLoaded>(),
      ],
      verify: (_) {
        verify(() => mockMealRepository.addMeal(any())).called(1);
      },
    );
  });

  group('deleteMeal', () {
    blocTest<MealCubit, MealState>(
      'calls deleteMeal on repository and reloads',
      build: () {
        when(() => mockMealRepository.deleteMeal(any()))
            .thenAnswer((_) async {});
        when(() => mockMealRepository.getMealsByDate(any()))
            .thenAnswer((_) async => []);
        when(() => mockMealRepository.getTotalCaloriesByDate(any()))
            .thenAnswer((_) async => 0);
        return cubit;
      },
      act: (cubit) => cubit.deleteMeal(1),
      expect: () => [
        isA<MealLoading>(),
        isA<MealLoaded>(),
      ],
      verify: (_) {
        verify(() => mockMealRepository.deleteMeal(1)).called(1);
      },
    );
  });
}
