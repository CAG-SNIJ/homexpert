import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';

class AdminSidebar extends StatefulWidget {
  final String currentRoute;
  final VoidCallback? onToggle;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    this.onToggle,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  bool _isExpanded = true;
  late bool _userExpanded;
  bool _agentExpanded = false;
  bool _staffExpanded = false;

  @override
  void initState() {
    super.initState();
    // Auto-expand User menu if on a user-related route
    _userExpanded = widget.currentRoute.startsWith('/admin/users');
  }

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _isExpanded ? 260 : 70,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Always pure white background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(4, 0), // Shadow on the right side
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Only collapse/expand icon with shadow
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000), // 0.05 opacity black
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.arrow_left_outlined : Icons.arrow_right_outlined,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                  onPressed: _toggleSidebar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Navigation Items
          Expanded(
            child: Container(
              color: const Color(0xFFFFFFFF),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    label: 'Dashboard',
                    route: AppConstants.routeAdminDashboard,
                    isActive: widget.currentRoute == AppConstants.routeAdminDashboard,
                  ),
                  _buildExpandableNavItem(
                    icon: Icons.person_outline,
                    label: 'User',
                    isExpanded: _userExpanded,
                    onTap: () {
                      setState(() {
                        _userExpanded = !_userExpanded;
                      });
                    },
                    children: [
                      _buildSubNavItem('Manage User', '/admin/users'),
                      _buildSubNavItem('Create User', '/admin/users/create'),
                      _buildSubNavItem('Review User Account', '/admin/users/review'),
                    ],
                  ),
                  _buildExpandableNavItem(
                    icon: Icons.people_outline,
                    label: 'Agent',
                    isExpanded: _agentExpanded,
                    onTap: () {
                      setState(() {
                        _agentExpanded = !_agentExpanded;
                      });
                    },
                    children: [
                      _buildSubNavItem('All Agents', '/admin/agents'),
                      _buildSubNavItem('Add Agent', '/admin/agents/add'),
                    ],
                  ),
                  _buildExpandableNavItem(
                    icon: Icons.people_outline,
                    label: 'Staff',
                    isExpanded: _staffExpanded,
                    onTap: () {
                      setState(() {
                        _staffExpanded = !_staffExpanded;
                      });
                    },
                    children: [
                      _buildSubNavItem('All Staff', '/admin/staff'),
                      _buildSubNavItem('Add Staff', '/admin/staff/add'),
                    ],
                  ),
                  _buildNavItem(
                    icon: Icons.search,
                    label: 'Review Listing',
                    route: '/admin/review-listing',
                  ),
                  _buildNavItem(
                    icon: Icons.description,
                    label: 'Review Document',
                    route: '/admin/review-document',
                  ),
                  _buildNavItem(
                    icon: Icons.bar_chart,
                    label: 'Reports',
                    route: '/admin/reports',
                  ),
                  _buildNavItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    route: '/logout',
                    isLogout: true,
                    onLogout: () async {
                      final authService = AuthService();
                      await authService.logout();
                      if (context.mounted) {
                        context.go(AppConstants.routeStaffLogin);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
    bool isActive = false,
    bool isLogout = false,
    VoidCallback? onLogout,
  }) {
    // Active item: dark green background, white icon and text, fully rounded
    // Logout: dark green icon and text (no background)
    // Other items: black icon and text (no background)
    final iconColor = isActive
        ? Colors.white
        : (isLogout ? AppTheme.primaryColor : AppTheme.textPrimary);
    final textColor = isActive
        ? Colors.white
        : (isLogout ? AppTheme.primaryColor : AppTheme.textPrimary);
    final bgColor = isActive ? AppTheme.primaryColor : const Color(0xFFFFFFFF);

    return InkWell(
      onTap: () {
        if (isLogout && onLogout != null) {
          onLogout();
        } else if (!isLogout) {
          context.go(route);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100), // Fully rounded (100%)
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            if (_isExpanded) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableNavItem({
    required IconData icon,
    required String label,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFFFFFFF),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.textPrimary, size: 20),
                if (_isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.arrow_left : Icons.arrow_right,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_isExpanded && isExpanded)
          ...children,
      ],
    );
  }

  Widget _buildSubNavItem(String label, String route) {
    final isActive = widget.currentRoute == route;
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.only(left: 40, right: 8, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(100), // Fully rounded
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isActive ? Colors.white : AppTheme.textPrimary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
