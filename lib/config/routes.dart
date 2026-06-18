import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/tramite/tramite_detail_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/sugerencias/sugerencia_detail_screen.dart';
import '../services/hive_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/tramite/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TramiteDetailScreen(tramiteId: id);
      },
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/sugerencia/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return SugerenciaDetailScreen(sugerenciaId: id);
      },
    ),
  ],
  redirect: (context, state) {
    final isOnboardingCompleted = HiveService.isOnboardingCompleted();
    final location = state.matchedLocation;

    if (!isOnboardingCompleted && location != '/') {
      return '/';
    }

    if (isOnboardingCompleted && location == '/') {
      return '/home';
    }

    return null;
  },
);
