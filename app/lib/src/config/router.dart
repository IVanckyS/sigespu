import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/map/map_screen.dart';
import '../presentation/shared/app_shell.dart';
import '../presentation/auth/auth_screen.dart';
import '../presentation/auth/auth_provider.dart';
import '../presentation/resumen/resumen_screen.dart';
import '../presentation/tabla/tabla_screen.dart';
import '../presentation/scraping/scraping_screen.dart';
import '../presentation/users/users_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/map',
    redirect: (context, state) {
      final isGoingToLogin = state.uri.path == '/login';
      
      if (!authState.isAuthenticated && !isGoingToLogin) {
        return '/login';
      }
      if (authState.isAuthenticated && isGoingToLogin) {
        return '/map';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/resumen',
            builder: (context, state) => const ResumenScreen(),
          ),
          GoRoute(
            path: '/tabla',
            builder: (context, state) => const TablaScreen(),
          ),
          GoRoute(
            path: '/scraping',
            builder: (context, state) => const ScrapingScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
          ),
        ],
      ),
    ],
  );
});
