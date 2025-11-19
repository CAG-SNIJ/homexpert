import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_list_model.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/user_table.dart';
import '../widgets/pagination_widget.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({super.key});

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  
  List<UserListItem> _users = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  final int _itemsPerPage = 10;
  String _searchQuery = '';
  String? _sortColumn;
  bool _sortAscending = true;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _adminService.getUsers(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      if (mounted) {
        setState(() {
          _users = result['users'] as List<UserListItem>;
          final pagination = result['pagination'] as Map<String, dynamic>;
          _totalPages = pagination['totalPages'] ?? 1;
          _totalUsers = pagination['total'] ?? 0;
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

  void _handleSearch() {
    _searchQuery = _searchController.text.trim();
    _loadUsers(resetPage: true);
  }

  void _applySorting() {
    if (_sortColumn == null) return;
    
    setState(() {
      _users.sort((a, b) {
        int comparison = 0;
        switch (_sortColumn) {
          case 'User ID':
            comparison = a.userId.compareTo(b.userId);
            break;
          case 'Name':
            comparison = a.name.compareTo(b.name);
            break;
          case 'Region':
            comparison = a.region.compareTo(b.region);
            break;
          case 'Email':
            comparison = a.email.compareTo(b.email);
            break;
          case 'Status':
            comparison = a.status.compareTo(b.status);
            break;
          case 'Date Joined':
            comparison = a.dateJoined.compareTo(b.dateJoined);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  void _handleEdit(String userId) {
    // TODO: Navigate to edit user page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit user: $userId')),
    );
  }

  void _handleSuspend(String userId) {
    // TODO: Implement suspend user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Suspend user: $userId')),
    );
  }

  void _handleDelete(UserListItem user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete User',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this user?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E8EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'User ID: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '#${user.userId}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'User Name: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'No',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close confirmation dialog first
              Navigator.of(context).pop();
              
              // Wait a frame to ensure dialog is closed
              await Future.delayed(const Duration(milliseconds: 100));
              
              if (!mounted) return;
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => PopScope(
                  canPop: false,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              );

              try {
                await _adminService.deleteUser(user.userId);
                
                if (!mounted) return;
                
                // Close loading dialog
                Navigator.of(context).pop();
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Refresh user list
                _loadUsers();
              } catch (e) {
                if (!mounted) return;
                
                // Close loading dialog
                Navigator.of(context).pop();
                
                // Show error message
                final errorMessage = e.toString().replaceFirst('Exception: ', '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting user: $errorMessage'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Yes, Delete',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
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
                const SizedBox(width: 260), // Spacer for sidebar
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 80), // Spacer for header
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            onPressed: _loadUsers,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppTheme.primaryColor,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title and Create New Button
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Manage User',
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF387366),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  context.go('/admin/users/create');
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppTheme.primaryColor,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                          vertical: 12),
                                                ),
                                                child: const Text('Create New'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          // Search Bar
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: _isSearchFocused
                                                    ? AppTheme.primaryColor
                                                    : const Color(0xFFE5E8EB),
                                                width: _isSearchFocused ? 2 : 1,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller: _searchController,
                                                    focusNode: _searchFocusNode,
                                                    decoration: const InputDecoration(
                                                      hintText: 'Search User',
                                                      prefixIcon: Icon(
                                                        Icons.search,
                                                        color: AppTheme.textSecondary,
                                                      ),
                                                      border: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      contentPadding: EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12,
                                                      ),
                                                    ),
                                                    onSubmitted: (_) => _handleSearch(),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(right: 4),
                                                  child: ElevatedButton(
                                                    onPressed: _handleSearch,
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF387366),
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      elevation: 0,
                                                      minimumSize: const Size(0, 40),
                                                    ),
                                                    child: const Text('Search'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          // User Table
                                          UserTable(
                                            users: _users,
                                            onEdit: _handleEdit,
                                            onSuspend: _handleSuspend,
                                            onDelete: _handleDelete,
                                            onSort: (column, ascending) {
                                              setState(() {
                                                _sortColumn = column;
                                                _sortAscending = ascending;
                                              });
                                              _applySorting();
                                            },
                                            sortColumn: _sortColumn,
                                            sortAscending: _sortAscending,
                                          ),
                                          const SizedBox(height: 24),
                                          // Pagination
                                          if (_totalPages > 1)
                                            PaginationWidget(
                                              currentPage: _currentPage,
                                              totalPages: _totalPages,
                                              onPageChanged: (page) {
                                                setState(() {
                                                  _currentPage = page;
                                                });
                                                _loadUsers();
                                              },
                                            ),
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
            // Sidebar (middle layer)
            Positioned(
              left: 0,
              top: 70,
              bottom: 0,
              child: AdminSidebar(
                currentRoute: '/admin/users',
              ),
            ),
            // Header (top layer)
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

