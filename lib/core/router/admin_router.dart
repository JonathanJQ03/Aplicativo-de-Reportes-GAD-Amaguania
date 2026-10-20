import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/moderation/presentation/views/admin_access_denied_view.dart';
import '../../features/moderation/presentation/views/admin_checking_view.dart';
import '../../features/moderation/presentation/views/admin_home_view.dart';
import '../errors/not_found_view.dart';
import 'route_guards.dart';

/// Router del panel de administración.
///
/// La sesión y el rol se resuelven en [AuthViewModel]; las reglas de
/// redirección viven en [resolveAdminRedirect] para poder probarlas aparte.
GoRouter createAdminRouter(AuthViewModel authViewModel) {
  return GoRouter(
    initialLocation: AdminRoutes.login,
    refreshListenable: authViewModel,
    redirect: (context, state) {
      return resolveAdminRedirect(
        location: state.matchedLocation,
        isLoggedIn: authViewModel.isAuthenticated,
        isRoleLoading: authViewModel.isRoleLoading,
        role: authViewModel.currentUser?.role,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: AdminRoutes.login,
        builder: (context, state) => const LoginView(adminMode: true),
      ),
      GoRoute(
        path: AdminRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: AdminRoutes.checking,
        builder: (context, state) => const AdminCheckingView(),
      ),
      GoRoute(
        path: AdminRoutes.accessDenied,
        builder: (context, state) => const AdminAccessDeniedView(),
      ),
      GoRoute(
        path: AdminRoutes.home,
        builder: (context, state) => const AdminHomeView(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundView(),
  );
}
