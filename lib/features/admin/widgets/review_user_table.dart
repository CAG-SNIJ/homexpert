import 'package:flutter/material.dart';
import '../../../core/models/review_user_model.dart';
import '../../../core/theme/app_theme.dart';

class ReviewUserTable extends StatelessWidget {
  final List<ReviewUserItem> users;
  final Function(String userId)? onReview;
  final Function(String column, bool ascending)? onSort;
  final String? sortColumn;
  final bool sortAscending;

  const ReviewUserTable({
    super.key,
    required this.users,
    this.onReview,
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
                _buildHeaderCell('Email', flex: 2, onSort: onSort, sortColumn: sortColumn, sortAscending: sortAscending),
                _buildHeaderCell('Account Status', flex: 1, onSort: onSort, sortColumn: sortColumn, sortAscending: sortAscending),
                _buildHeaderCell('Date Submitted', flex: 1, onSort: onSort, sortColumn: sortColumn, sortAscending: sortAscending),
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

  Widget _buildTableRow(ReviewUserItem user, BuildContext context) {
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
          _buildCell(user.email, flex: 2),
          _buildStatusCell(user.accountStatus, flex: 1),
          _buildCell(
            '${user.dateSubmitted.year}-${user.dateSubmitted.month.toString().padLeft(2, '0')}-${user.dateSubmitted.day.toString().padLeft(2, '0')}',
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
    // Capitalize first letter and handle status text
    final statusLower = status.toLowerCase();
    String statusText;
    bool isKycPending = false;
    bool isSuspendedPending = false;
    
    if (statusLower.contains('kyc pending') || statusLower == 'kyc pending') {
      statusText = 'KYC Pending';
      isKycPending = true;
    } else if (statusLower.contains('suspended pending') || statusLower == 'suspended pending' || statusLower == 'suspended') {
      statusText = 'Suspended Pending';
      isSuspendedPending = true;
    } else {
      statusText = status.substring(0, status.length > 15 ? 15 : status.length);
    }
    
    // Different colors for different statuses
    Color backgroundColor;
    Color textColor;
    
    if (isKycPending) {
      // KYC Pending: Orange/Amber background with dark text
      backgroundColor = const Color(0xFFFFF4E6); // Light orange
      textColor = const Color(0xFFE67E22); // Dark orange
    } else if (isSuspendedPending) {
      // Suspended Pending: Red background with dark red text
      backgroundColor = const Color(0xFFFFE6E6); // Light red
      textColor = const Color(0xFFE74C3C); // Dark red
    } else {
      // Default: Grey
      backgroundColor = const Color(0xFFF0F0F0);
      textColor = AppTheme.textPrimary;
    }
    
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCell(ReviewUserItem user, BuildContext context, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: ElevatedButton(
        onPressed: () => onReview?.call(user.userId),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF387366),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 36),
        ),
        child: const Text(
          'Review',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

