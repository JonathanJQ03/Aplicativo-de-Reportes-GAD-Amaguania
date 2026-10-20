import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/verify_code_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/reports/views/my_reports_view.dart';
import '../../features/reports/views/new_leak_report_view.dart';
import '../../features/reports/views/new_pet_report_view.dart';
import '../../features/reports/views/report_detail_view.dart';

/// Construye el router con una guarda básica de sesión.
///
/// En S01 la guarda solo distingue entre sesión abierta y cerrada. La
/// restricción por roles se agrega en S07.
GoRouter createAppRouter(AuthViewModel authViewModel) {
  // Rutas accesibles sin sesión. S06 agregará '/forgot-password'.
  const Set<String> publicRoutes = <String>{'/login', '/register'};

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authViewModel,
    redirect: (context, state) {
      final bool isLoggedIn = authViewModel.isAuthenticated;
      final bool isPublicRoute = publicRoutes.contains(state.matchedLocation);

      if (!isLoggedIn) {
        return isPublicRoute ? null : '/login';
      }
      if (isPublicRoute) {
        return '/';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/verify-code',
        builder: (context, state) => const VerifyCodeView(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeView()),
      GoRoute(
        path: '/my-reports',
        builder: (context, state) => const MyReportsView(),
      ),
      GoRoute(
        path: '/reports/new-leak',
        builder: (context, state) => const NewLeakReportView(),
      ),
      GoRoute(
        path: '/reports/new-pet',
        builder: (context, state) => const NewPetReportView(),
      ),
      GoRoute(
        path: '/reports/:id',
        builder: (context, state) => const ReportDetailView(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
    ],
    // TODO(S07): agregar errorBuilder con una pantalla de "página no
    // encontrada" y guards por rol.
  );
}
