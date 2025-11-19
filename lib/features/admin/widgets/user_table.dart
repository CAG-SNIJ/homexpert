import 'package:flutter/material.dart';
import '../../../core/models/user_list_model.dart';
import '../../../core/theme/app_theme.dart';

class UserTable extends StatelessWidget {
  final List<UserListItem> users;
  final Function(String userId)? onEdit;
  final Function(String userId)? onSuspend;
  final Function(UserListItem user)? onDelete;
  final Function(String column, bool ascending)? onSort;
  final String? sortColumn;
  final bool sortAscending;

  const UserTable({
    super.key,
    required this.users,
    this.onEdit,
    this.onSuspend,
    this.onDelete,
    this.onSort,
    this.sortColumn,
    this.sortAscending = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E8EB)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xFFE5E8EB)),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell('User ID', flex: 1, onSort: onSort, sortColumn: sortColumn, sortAscending: sortAscending),
                _buildHeaderCell('Name', flex: 2, onSort: onSort, sortColumn: sortColumn, sortAscending: sortAscending),
                _buildHeaderCell('Region', flex: 1, onSort: onSort, sortColumn: sortColumn, sortAscending: sortAscending),
                _buildHeaderCell('Email', flex: 2, onSort: onSort, sortColumn: sortColumn, sortAscending: sortAscending),
                _buildHeaderCell('Status', flex: 1, onSort: onSort, sortColumn: sortColumn, sortAscending: sortAscending),
                _buildHeaderCell('Date Joined', flex: 1, onSort: onSort, sortColumn: sortColumn, sortAscending: sortAscending),
                _buildHeaderCell('Actions', flex: 1),
              ],
            ),
          ),
          // Table Body
          ...users.map((user) => _buildTableRow(user, context)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    String text, {
    int flex = 1,
    Function(String column, bool ascending)? onSort,
    String? sortColumn,
    bool sortAscending = true,
  }) {
    final isSortable = onSort != null && text != 'Actions';
    final isSorted = sortColumn == text;
    
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: isSortable
            ? () {
                onSort!(text, isSorted ? !sortAscending : true);
              }
            : null,
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (isSortable) ...[
              const SizedBox(width: 4),
              Icon(
                isSorted
                    ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: 16,
                color: isSorted ? const Color(0xFF387366) : AppTheme.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(UserListItem user, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE5E8EB).withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          _buildCell('#${user.userId}', flex: 1),
          _buildCell(user.name, flex: 2),
          _buildCell(user.region, flex: 1),
          _buildCell(user.email, flex: 2),
          _buildStatusCell(user.status, flex: 1),
          _buildCell(
            '${user.dateJoined.year}-${user.dateJoined.month.toString().padLeft(2, '0')}-${user.dateJoined.day.toString().padLeft(2, '0')}',
            flex: 1,
          ),
          _buildActionsCell(user, context, flex: 1),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status, {int flex = 1}) {
    final isActive = status.toLowerCase() == 'active';
    final statusText = status.length > 8 ? status.substring(0, 8) : status;
    
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFF0F0F0)
                : const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? AppTheme.textPrimary
                  : Colors.red,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCell(UserListItem user, BuildContext context, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => onEdit?.call(user.userId),
            child: const Text(
              'Edit User',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF387366),
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => onSuspend?.call(user.userId),
            child: const Text(
              'Suspend',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => onDelete?.call(user),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
