import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba_fast_tracker/core/di/injection_container.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:mamba_fast_tracker/features/daily_summary/presentation/cubit/daily_summary_cubit.dart';
import 'package:mamba_fast_tracker/features/daily_summary/presentation/pages/daily_summary_page.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/cubit/fasting_cubit.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/pages/fasting_page.dart';
import 'package:mamba_fast_tracker/features/graph/presentation/cubit/graph_cubit.dart';
import 'package:mamba_fast_tracker/features/graph/presentation/pages/graph_page.dart';
import 'package:mamba_fast_tracker/features/history/presentation/cubit/history_cubit.dart';
import 'package:mamba_fast_tracker/features/history/presentation/pages/history_page.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/cubit/meal_cubit.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/pages/meal_list_page.dart';
import 'package:mamba_fast_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:mamba_fast_tracker/core/utils/strings.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter(this.authCubit);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isLoginRoute = state.matchedLocation == '/login';

      if (authState is AuthUnauthenticated || authState is AuthError) {
        return isLoginRoute ? null : '/login';
      }

      if (authState is AuthAuthenticated && isLoginRoute) {
        return '/fasting';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return _HomeShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/fasting',
            builder: (context, state) {
              return BlocProvider(
                create: (_) => sl<FastingCubit>()..loadInitialState(),
                child: const FastingPage(),
              );
            },
          ),
          GoRoute(
            path: '/meals',
            builder: (context, state) {
              return BlocProvider(
                create: (_) => sl<MealCubit>()..loadMeals(),
                child: const MealListPage(),
              );
            },
          ),
          GoRoute(
            path: '/summary',
            builder: (context, state) {
              return BlocProvider(
                create: (_) => sl<DailySummaryCubit>()..loadSummary(),
                child: const DailySummaryPage(),
              );
            },
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) {
              return BlocProvider(
                create: (_) => sl<HistoryCubit>()..loadHistory(),
                child: const HistoryPage(),
              );
            },
          ),
          GoRoute(
            path: '/graph',
            builder: (context, state) {
              return BlocProvider(
                create: (_) => sl<GraphCubit>()..loadWeeklyData(),
                child: const GraphPage(),
              );
            },
          ),
        ],
      ),
    ],
  );
}

class _HomeShell extends StatelessWidget {
  final Widget child;

  const _HomeShell({required this.child});

  static const _tabs = [
    '/fasting',
    '/meals',
    '/summary',
    '/history',
    '/graph',
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexOf(location);
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (index) => context.go(_tabs[index]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: AppStrings.tabFasting,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: AppStrings.tabMeals,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppStrings.tabSummary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: AppStrings.tabHistory,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: AppStrings.tabGraph,
          ),
        ],
      ),
    );
  }
}

/// Converts a Stream into a ChangeNotifier for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
