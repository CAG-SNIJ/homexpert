import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/user/screens/homepage_screen.dart';
import '../../features/user/screens/user_dashboard_screen.dart';
import '../../features/agent/screens/agent_dashboard_screen.dart';
import '../../features/staff/screens/staff_login_screen.dart';
import '../../features/staff/screens/staff_dashboard_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/manage_user_screen.dart';
import '../../features/admin/screens/create_user_screen.dart';
import '../../features/admin/screens/user_created_success_screen.dart';
import '../../core/services/auth_service.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.routeHome,
    redirect: (context, state) async {
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      final isHomePage = state.matchedLocation == AppConstants.routeHome;
      final isLoginPage = state.matchedLocation == AppConstants.routeLogin;
      final isRegisterPage = state.matchedLocation == AppConstants.routeRegister;
      final isStaffLoginPage = state.matchedLocation == AppConstants.routeStaffLogin;

      // Homepage and login pages are public, no redirect needed
      if (isHomePage || isLoginPage || isRegisterPage || isStaffLoginPage) {
        return null;
      }

      // If not logged in and trying to access protected route
      if (!isLoggedIn) {
        return AppConstants.routeLogin;
      }

      // If logged in and trying to access auth pages
      if (isLoggedIn && (isLoginPage || isRegisterPage)) {
        // Redirect to appropriate dashboard based on role
        final role = await authService.getUserRole();
        switch (role) {
          case AppConstants.roleAgent:
            return AppConstants.routeAgentDashboard;
          case AppConstants.roleStaff:
            return AppConstants.routeStaffDashboard;
          case AppConstants.roleAdmin:
            return AppConstants.routeAdminDashboard;
          default:
            return AppConstants.routeUserDashboard;
        }
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: AppConstants.routeHome,
        name: 'home',
        builder: (context, state) => const HomepageScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeStaffLogin,
        name: 'staff_login',
        builder: (context, state) => const StaffLoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeUserDashboard,
        name: 'user_dashboard',
        builder: (context, state) => const UserDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAgentDashboard,
        name: 'agent_dashboard',
        builder: (context, state) => const AgentDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.routeStaffDashboard,
        name: 'staff_dashboard',
        builder: (context, state) => const StaffDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAdminDashboard,
        name: 'admin_dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'manage_users',
        builder: (context, state) => const ManageUserScreen(),
      ),
      GoRoute(
        path: '/admin/users/create',
        name: 'create_user',
        builder: (context, state) => const CreateUserScreen(),
      ),
      GoRoute(
        path: '/admin/users/create/success',
        name: 'user_created_success',
        builder: (context, state) => const UserCreatedSuccessScreen(),
      ),
    ],
  );
}

