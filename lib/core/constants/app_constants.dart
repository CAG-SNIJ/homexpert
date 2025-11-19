class AppConstants {
  // App Information
  static const String appName = 'HomeXpert';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  // IMPORTANT: Backend server must be running on http://localhost:3000
  // To start backend: cd backend && npm run dev
  // Backend health check: http://localhost:3000/health
  static const String baseUrl = 'http://localhost:3000/api';
  static const String backendUrl = 'http://localhost:3000'; // Base backend URL (without /api)
  static const String wsUrl = 'ws://localhost:3000'; // WebSocket URL
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String userRoleKey = 'user_role';
  
  // User Roles
  static const String roleUser = 'user';
  static const String roleAgent = 'agent';
  static const String roleStaff = 'staff';
  static const String roleAdmin = 'admin';
  
  // Routes
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeUserDashboard = '/user/dashboard';
  static const String routeAgentDashboard = '/agent/dashboard';
  static const String routeStaffLogin = '/staff/login';
  static const String routeStaffDashboard = '/staff/dashboard';
  static const String routeAdminDashboard = '/admin/dashboard';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}

