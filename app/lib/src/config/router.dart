import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/map/map_screen.dart';
import '../presentation/shared/app_shell.dart';
import '../presentation/auth/auth_screen.dart';
import '../presentation/auth/auth_provider.dart';
import '../presentation/resumen/resumen_screen.dart';
import '../presentation/tabla/tabla_screen.dart';
import '../presentation/scraping/scraping_screen.dart';
import '../presentation/sync/conflicts_screen.dart';
import '../presentation/users/users_screen.dart';
import '../presentation/actividades/actividades_screen.dart';
import '../presentation/profile/profile_screen.dart';

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
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/map',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MapScreen()),
          ),
          GoRoute(
            path: '/resumen',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ResumenScreen()),
          ),
          GoRoute(
            path: '/tabla',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TablaScreen()),
          ),
          GoRoute(
            path: '/scraping',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ScrapingScreen()),
          ),
          GoRoute(
            path: '/users',
            redirect: (context, state) {
              final role = authState.user?['nivel_acceso'] as String? ?? '';
              if (role != 'director') return '/map';
              return null;
            },
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: UsersScreen()),
          ),
          GoRoute(
            path: '/actividades',
            redirect: (context, state) {
              final role = authState.user?['nivel_acceso'] as String? ?? '';
              if (role == 'visitante' || role.isEmpty) return '/map';
              return null;
            },
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ActividadesScreen()),
          ),
          GoRoute(
            path: '/conflicts',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ConflictsScreen()),
          ),
        ],
      ),
    ],
  );
});
