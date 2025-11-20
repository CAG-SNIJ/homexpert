import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/review_user_model.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/review_user_table.dart';
import '../widgets/pagination_widget.dart';

class ReviewUserAccountScreen extends StatefulWidget {
  const ReviewUserAccountScreen({super.key});

  @override
  State<ReviewUserAccountScreen> createState() => _ReviewUserAccountScreenState();
}

class _ReviewUserAccountScreenState extends State<ReviewUserAccountScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ReviewUserItem> _users = [];
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
      final result = await _adminService.getReviewUsers(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      if (mounted) {
        setState(() {
          _users = result['users'] as List<ReviewUserItem>;
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
          case 'Email':
            comparison = a.email.compareTo(b.email);
            break;
          case 'Account Status':
            comparison = a.accountStatus.compareTo(b.accountStatus);
            break;
          case 'Date Submitted':
            comparison = a.dateSubmitted.compareTo(b.dateSubmitted);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  void _handleReview(String userId) {
    context.go('/admin/users/review/$userId');
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
                                          // Title
                                          const Text(
                                            'Review User Account',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF387366),
                                            ),
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
                                          // Review User Table
                                          ReviewUserTable(
                                            users: _users,
                                            onReview: _handleReview,
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
                currentRoute: '/admin/users/review',
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

