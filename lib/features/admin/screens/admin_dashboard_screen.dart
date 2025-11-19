import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/models/dashboard_model.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/activities_table.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  
  DashboardStats? _stats;
  List<Activity> _activities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _adminService.getDashboardStats();
      final activities = await _adminService.getRecentActivities(limit: 5);

      if (mounted) {
        setState(() {
          _stats = stats;
          _activities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      context.go(AppConstants.routeStaffLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        // If back button is pressed, try to pop normally
        // If can't pop (no previous page), go to home instead of login
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            // Normal back navigation
            Navigator.of(context).pop();
          } else {
            // No previous page, go to home instead of login
            if (mounted) {
              context.go(AppConstants.routeHome);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
          // Main Content (bottom layer)
          Row(
            children: [
              SizedBox(width: 260), // Spacer for sidebar
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 80), // Spacer for header
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                ),
                              )
                            : _error != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 64,
                                          color: AppTheme.errorColor,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _error!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton(
                                          onPressed: _loadDashboardData,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  )
                                : SingleChildScrollView(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Dashboard Title
                                        const Text(
                                          'Dashboard',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        // Summary Cards
                                        if (_stats != null) ...[
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              int crossAxisCount = 3;
                                              if (constraints.maxWidth < 900) {
                                                crossAxisCount = 2;
                                              }
                                              if (constraints.maxWidth < 600) {
                                                crossAxisCount = 1;
                                              }
                                              return GridView.count(
                                                crossAxisCount: crossAxisCount,
                                                crossAxisSpacing: 16,
                                                mainAxisSpacing: 16,
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                childAspectRatio: 2.5,
                                                children: [
                                                  DashboardSummaryCard(
                                                    title: 'Total Users',
                                                    value: _stats!.totalUsers,
                                                    icon: Icons.person,
                                                  ),
                                                  DashboardSummaryCard(
                                                    title: 'Total Agents',
                                                    value: _stats!.totalAgents,
                                                    icon: Icons.group,
                                                  ),
                                                  DashboardSummaryCard(
                                                    title: 'Total Listings',
                                                    value: _stats!.totalListings,
                                                    icon: Icons.list,
                                                  ),
                                                  DashboardSummaryCard(
                                                    title: 'Total Properties',
                                                    value: _stats!.totalProperties,
                                                    icon: Icons.home,
                                                  ),
                                                  DashboardSummaryCard(
                                                    title: 'Total Rent',
                                                    value: _stats!.totalRent,
                                                    icon: Icons.key,
                                                  ),
                                                  DashboardSummaryCard(
                                                    title: 'Total Sale',
                                                    value: _stats!.totalSale,
                                                    icon: Icons.sell,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 32),
                                        ],
                                        // Recent Activities
                                        const Text(
                                          'Recent Activities',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ActivitiesTable(activities: _activities),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Sidebar (middle layer, with shadow - full height)
          Positioned(
            left: 0,
            top: 70,
            bottom: 0,
            child: AdminSidebar(
              currentRoute: AppConstants.routeAdminDashboard,
            ),
          ),
          // Header (top layer, overlapping sidebar)
          const Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: AdminHeader(),
          ),
        ],
        ),
      ),
    );
  }
}
