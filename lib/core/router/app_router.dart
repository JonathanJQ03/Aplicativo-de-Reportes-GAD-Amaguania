import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/session_loading_view.dart';
import '../../features/auth/presentation/views/verify_email_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/moderation/presentation/views/admin_access_denied_view.dart';
import '../../features/moderation/presentation/views/admin_checking_view.dart';
import '../../features/moderation/presentation/views/admin_home_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/reports/views/my_reports_view.dart';
import '../../features/reports/views/new_leak_report_view.dart';
import '../../features/reports/views/new_pet_report_view.dart';
import '../../features/reports/views/report_detail_view.dart';
import '../errors/not_found_view.dart';
import 'route_guards.dart';

/// Construye el router único de VeciApp.
///
/// La app de vecinos y el panel de administración comparten sesión, tema y
/// navegación. [resolveAppRedirect] concentra las reglas de sesión, correo y
/// rol para poder probarlas sin levantar la interfaz.
GoRouter createAppRouter(AuthViewModel authViewModel) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authViewModel,
    redirect: (context, state) {
      return resolveAppRedirect(
        location: state.matchedLocation,
        isLoggedIn: authViewModel.isAuthenticated,
        isEmailVerified: authViewModel.isEmailVerified,
        isRoleLoading: authViewModel.isRoleLoading,
        role: authViewModel.currentUser?.role,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) => const VerifyEmailView(),
      ),
      GoRoute(
        path: AppRoutes.sessionLoading,
        builder: (context, state) => const SessionLoadingView(),
      ),
      GoRoute(
        path: AppRoutes.adminLogin,
        builder: (context, state) => const LoginView(adminMode: true),
      ),
      GoRoute(
        path: AppRoutes.adminForgotPassword,
        builder: (context, state) =>
            const ForgotPasswordView(backRoute: AppRoutes.adminLogin),
      ),
      GoRoute(
        path: AppRoutes.adminChecking,
        builder: (context, state) => const AdminCheckingView(),
      ),
      GoRoute(
        path: AppRoutes.adminDenied,
        builder: (context, state) => const AdminAccessDeniedView(),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        builder: (context, state) => const AdminHomeView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeView(),
      ),
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
