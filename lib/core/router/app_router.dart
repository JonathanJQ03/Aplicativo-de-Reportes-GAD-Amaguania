import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../errors/not_found_view.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/verify_email_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/reports/views/my_reports_view.dart';
import '../../features/reports/views/new_leak_report_view.dart';
import '../../features/reports/views/new_pet_report_view.dart';
import '../../features/reports/views/report_detail_view.dart';

/// Construye el router con la guarda de sesión y de correo verificado.
///
/// La restricción por roles se agrega en S07. Mientras el correo no esté
/// confirmado, el usuario solo puede ver la pantalla de verificación.
GoRouter createAppRouter(AuthViewModel authViewModel) {
  // Rutas accesibles sin sesión.
  const Set<String> publicRoutes = <String>{
    '/login',
    '/register',
    '/forgot-password',
  };
  const String verifyEmailRoute = '/verify-email';

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authViewModel,
    redirect: (context, state) {
      final bool isLoggedIn = authViewModel.isAuthenticated;
      final bool isPublicRoute = publicRoutes.contains(state.matchedLocation);
      final bool isVerifyEmailRoute = state.matchedLocation == verifyEmailRoute;

      if (!isLoggedIn) {
        return isPublicRoute ? null : '/login';
      }
      if (!authViewModel.isEmailVerified) {
        return isVerifyEmailRoute ? null : verifyEmailRoute;
      }
      if (isPublicRoute || isVerifyEmailRoute) {
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
        path: verifyEmailRoute,
        builder: (context, state) => const VerifyEmailView(),
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
    errorBuilder: (context, state) => const NotFoundView(),
  );
}
