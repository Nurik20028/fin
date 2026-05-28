import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:finance/components/main_navigation_container.dart';
import 'package:finance/session/app_session_cubit.dart';
import 'package:finance/ui/add_operation_screen.dart';
import 'package:finance/ui/code_enter_page.dart';
import 'package:finance/ui/filter_screen.dart';
import 'package:finance/ui/history_screen.dart';
import 'package:finance/ui/registration_page.dart';
import 'package:finance/ui/settings_screen.dart';
import 'package:finance/ui/splash_screen.dart';
import 'package:finance/ui/statistics_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AppSessionCubit appSessionCubit;
  AppRouter(this.appSessionCubit);
  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(appSessionCubit.stream),
    redirect: (context, state) {
      // Получаем состояние сессии
      final session = appSessionCubit.state;
      final isSplash = state.matchedLocation == '/splash';
      final isRegister = state.matchedLocation == '/register';
      final isAuth = state.matchedLocation == '/code_enter_page';
      // загрузка SplashPage
      if (isSplash) return null;

      // ЛОГИКА ПЕРВОГО ЗАПУСКА разрешаем ТОЛЬКО страницу регистрации
      if (session.isFirstRun) {
        return isRegister ? null : '/register';
      }
      //// Если не разблокировано — только ввод пин-кода:
      if (!session.isUnlocked) {
        return isAuth ? null : '/code_enter_page';
      }
      // ЕСЛИ РАЗБЛОКИРОВАНО
      // Если пользователь авторизован, но пытается зайти на страницы входа — отправляем в home
      if (session.isUnlocked && (isRegister || isAuth)) {
        return '/main_navigation_container';
      }

      return null;
    },
    // В остальных случаях идем куда хотели
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegistrationPage()),
      GoRoute(
        path: '/code_enter_page',
        builder: (_, __) => const CodEnterPage(),
      ),
      GoRoute(
        path: '/main_navigation_container',
        builder: (_, __) => const MainNavigationContainer(),
      ),
      GoRoute(
        path: '/add_operation',
        builder: (_, __) => const AddOperationScreen(),
      ),
      GoRoute(path: '/filters_page', builder: (_, __) => const FilterScreen()),
      GoRoute(path: '/history_page', builder: (_, __) => const HistoryScreen()),
      GoRoute(
        path: '/statistic_page',
        builder: (_, __) => const StatisticsScreen(),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
