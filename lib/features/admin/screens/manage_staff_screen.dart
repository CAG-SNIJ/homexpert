import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/staff_list_model.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/staff_table.dart';
import '../widgets/pagination_widget.dart';

class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<StaffListItem> _staff = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalStaff = 0;
  final int _itemsPerPage = 10;
  String _searchQuery = '';
  String? _sortColumn;
  bool _sortAscending = true;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _loadStaff();
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

  Future<void> _loadStaff({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _adminService.getStaffMembers(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      if (mounted) {
        setState(() {
          _staff = result['staff'] as List<StaffListItem>;
          final pagination = result['pagination'] as Map<String, dynamic>;
          _totalPages = pagination['totalPages'] ?? 1;
          _totalStaff = pagination['total'] ?? 0;
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
    _loadStaff(resetPage: true);
  }

  void _applySorting() {
    if (_sortColumn == null) return;

    setState(() {
      _staff.sort((a, b) {
        int comparison = 0;
        switch (_sortColumn) {
          case 'Staff ID':
            comparison = a.staffId.compareTo(b.staffId);
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

  void _handleEdit(String staffId) {
    // TODO: Navigate to edit staff page when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit staff: $staffId (coming soon)')),
    );
  }

  void _handleDelete(StaffListItem staffMember) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Staff',
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
              'Are you sure you want to delete this staff member?',
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
                        'Staff ID: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '#${staffMember.staffId}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Name: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          staffMember.name,
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete staff feature coming soon'),
                  duration: Duration(seconds: 3),
                ),
              );
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

  Future<void> _handleToggleStatus(StaffListItem staffMember) async {
    final isCurrentlyActive = staffMember.status.toLowerCase() == 'active';
    final targetStatus = isCurrentlyActive ? 'inactivate' : 'activate';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${targetStatus[0].toUpperCase()}${targetStatus.substring(1)} Staff',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to $targetStatus ${staffMember.name}? They ${isCurrentlyActive ? 'will not be able to sign in while inactive.' : 'will regain access once activated.'}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isCurrentlyActive ? const Color(0xFFF2994A) : AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              targetStatus[0].toUpperCase() + targetStatus.substring(1),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _adminService.updateStaffStatus(
        staffId: staffMember.staffId,
        isActive: !isCurrentlyActive,
      );
      await _loadStaff();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Staff ${!isCurrentlyActive ? 'activated' : 'inactivated'} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update status: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            Row(
              children: [
                const SizedBox(width: 260),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
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
                                            onPressed: _loadStaff,
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
                                          Row(
                                            children: [
                                              const Text(
                                                'Manage Staff',
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF387366),
                                                ),
                                              ),
                                              const SizedBox(width: 24),
                                              ElevatedButton(
                                                onPressed: () {
                                                  context.go('/admin/staff/create');
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
                                                child: const Text('Create Staff'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: _isSearchFocused
                                                    ? AppTheme.primaryColor
                                                    : const Color(0xFFE5E8EB),
                                                width: _isSearchFocused ? 2 : 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        _searchController,
                                                    focusNode: _searchFocusNode,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'Search Staff',
                                                      prefixIcon: Icon(
                                                        Icons.search,
                                                        color: AppTheme
                                                            .textSecondary,
                                                      ),
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12,
                                                      ),
                                                    ),
                                                    onSubmitted: (_) =>
                                                        _handleSearch(),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 4),
                                                  child: ElevatedButton(
                                                    onPressed: _handleSearch,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFF387366),
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      elevation: 0,
                                                      minimumSize:
                                                          const Size(0, 40),
                                                    ),
                                                    child: const Text('Search'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          StaffTable(
                                            staff: _staff,
                                            onEdit: _handleEdit,
                                            onDelete: _handleDelete,
                                            onToggleStatus: _handleToggleStatus,
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
                                          if (_totalPages > 1)
                                            PaginationWidget(
                                              currentPage: _currentPage,
                                              totalPages: _totalPages,
                                              onPageChanged: (page) {
                                                setState(() {
                                                  _currentPage = page;
                                                });
                                                _loadStaff();
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
            Positioned(
              left: 0,
              top: 70,
              bottom: 0,
              child: AdminSidebar(
                currentRoute: '/admin/staff',
              ),
            ),
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

