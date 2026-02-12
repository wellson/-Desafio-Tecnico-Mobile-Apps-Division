import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:mamba_fast_tracker/core/network/dio_client.dart';
import 'package:mamba_fast_tracker/core/notifications/notification_service.dart';
import 'package:mamba_fast_tracker/core/services/sound_service.dart';
import 'package:mamba_fast_tracker/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mamba_fast_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mamba_fast_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mamba_fast_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mamba_fast_tracker/features/daily_summary/presentation/cubit/daily_summary_cubit.dart';
import 'package:mamba_fast_tracker/features/fasting/data/datasources/fasting_local_datasource.dart';
import 'package:mamba_fast_tracker/features/fasting/data/repositories/fasting_repository_impl.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/repositories/fasting_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/cubit/fasting_cubit.dart';
import 'package:mamba_fast_tracker/features/graph/presentation/cubit/graph_cubit.dart';
import 'package:mamba_fast_tracker/features/history/presentation/cubit/history_cubit.dart';
import 'package:mamba_fast_tracker/features/meals/data/datasources/meal_local_datasource.dart';
import 'package:mamba_fast_tracker/features/meals/data/repositories/meal_repository_impl.dart';
import 'package:mamba_fast_tracker/features/meals/domain/repositories/meal_repository.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/cubit/meal_cubit.dart';

import 'package:shared_preferences/shared_preferences.dart';

// ── Core ──
final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => DioClient(sl<FlutterSecureStorage>()));
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => SoundService());

  // ── Datasources ──
  sl.registerLazySingleton(() => AuthRemoteDatasource(sl<DioClient>(), sl<FlutterSecureStorage>()));
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton(() => FastingLocalDatasource());
  sl.registerLazySingleton(() => MealLocalDatasource());

  // ── Repositories ──
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDatasource>(), sl<AuthLocalDatasource>()));
  sl.registerLazySingleton<FastingRepository>(
      () => FastingRepositoryImpl(sl<FastingLocalDatasource>()));
  sl.registerLazySingleton<MealRepository>(
      () => MealRepositoryImpl(sl<MealLocalDatasource>()));

  // ── Cubits ──
  sl.registerFactory(() => AuthCubit(sl<AuthRepository>()));
  sl.registerFactory(() => FastingCubit(sl<FastingRepository>(), sl<NotificationService>()));
  sl.registerFactory(() => MealCubit(sl<MealRepository>()));
  sl.registerFactory(() => DailySummaryCubit(sl<MealRepository>(), sl<FastingRepository>()));
  sl.registerFactory(() => HistoryCubit(sl<MealRepository>(), sl<FastingRepository>()));
  sl.registerFactory(() => GraphCubit(sl<MealRepository>(), sl<FastingRepository>()));
}
