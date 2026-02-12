import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/core/di/injection_container.dart';
import 'package:mamba_fast_tracker/core/services/background_service.dart';
import 'package:mamba_fast_tracker/core/notifications/notification_service.dart';
import 'package:mamba_fast_tracker/core/services/sound_service.dart';
import 'package:mamba_fast_tracker/core/router/app_router.dart';
import 'package:mamba_fast_tracker/core/theme/app_theme.dart';
import 'package:mamba_fast_tracker/core/theme/theme_cubit.dart';
import 'package:mamba_fast_tracker/core/utils/date_utils.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale for pt_BR
  await AppDateUtils.initLocale();
  // Initialize dependencies
  await initDependencies();
  await sl<SoundService>().initialize();

  // Initialize notifications
  await sl<NotificationService>().initialize();
  
  // Initialize background service
  await BackgroundService().initialize();

  runApp(const MambaFastTrackerApp());
}

class MambaFastTrackerApp extends StatefulWidget {
  const MambaFastTrackerApp({super.key});

  @override
  State<MambaFastTrackerApp> createState() => _MambaFastTrackerAppState();
}

class _MambaFastTrackerAppState extends State<MambaFastTrackerApp>
    with WidgetsBindingObserver {
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authCubit = sl<AuthCubit>()..checkAuthStatus();
    _themeCubit = ThemeCubit()..loadTheme();
    _appRouter = AppRouter(_authCubit);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authCubit.close();
    _themeCubit.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Mamba Fast Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}
