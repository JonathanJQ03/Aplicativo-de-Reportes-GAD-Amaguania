import 'package:go_router/go_router.dart';

import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/auth/views/verify_code_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/reports/views/my_reports_view.dart';
import '../../features/reports/views/new_leak_report_view.dart';
import '../../features/reports/views/new_pet_report_view.dart';
import '../../features/reports/views/report_detail_view.dart';

/// Configuración de rutas de la app con `go_router`.
///
/// TODO: añadir una guardia de autenticación (`redirect`) que envíe al
/// usuario a `/login` cuando intente acceder a rutas privadas sin sesión.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
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
    GoRoute(path: '/profile', builder: (context, state) => const ProfileView()),
  ],
  // TODO: añadir errorBuilder con una pantalla de "página no encontrada".
);
