import 'package:flutter/material.dart';
import '../../../core/models/staff_list_model.dart';
import '../../../core/theme/app_theme.dart';

class StaffTable extends StatelessWidget {
  final List<StaffListItem> staff;
  final Function(String staffId)? onEdit;
  final Function(StaffListItem staff)? onDelete;
  final Function(StaffListItem staff)? onToggleStatus;
  final Function(String column, bool ascending)? onSort;
  final String? sortColumn;
  final bool sortAscending;

  const StaffTable({
    super.key,
    required this.staff,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
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
                _buildHeaderCell('Staff ID', flex: 1),
                _buildHeaderCell('Name', flex: 2),
                _buildHeaderCell('Region', flex: 1),
                _buildHeaderCell('Email', flex: 2),
                _buildHeaderCell('Status', flex: 1),
                _buildHeaderCell('Date Joined', flex: 1),
                _buildHeaderCell('Actions', flex: 1, isSortable: false),
              ],
            ),
          ),
          ...staff.map((member) => _buildRow(member)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1, bool isSortable = true}) {
    final isSorted = sortColumn == text;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: isSortable && onSort != null
            ? () => onSort!(text, isSorted ? !sortAscending : true)
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
            if (isSortable && onSort != null) ...[
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

  Widget _buildRow(StaffListItem member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE5E8EB).withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          _buildCell(member.staffId, flex: 1),
          _buildCell(member.name, flex: 2),
          _buildCell(member.region, flex: 1),
          _buildCell(member.email, flex: 2),
          _buildStatusCell(member.status, flex: 1),
          _buildCell(
            '${member.dateJoined.year}-${member.dateJoined.month.toString().padLeft(2, '0')}-${member.dateJoined.day.toString().padLeft(2, '0')}',
            flex: 1,
          ),
          _buildActions(member, flex: 1),
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
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF387366).withOpacity(0.1)
                : const Color(0xFFF54F43).withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? const Color(0xFF387366)
                  : const Color(0xFFF54F43),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(StaffListItem member, {int flex = 1}) {
    final isActive = member.status.toLowerCase() == 'active';

    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => onEdit?.call(member.staffId),
            child: const Text(
              'Edit Staff',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF387366),
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => onToggleStatus?.call(member),
            child: Text(
              isActive ? 'Inactivate' : 'Activate',
              style: TextStyle(
                fontSize: 14,
                color: isActive ? const Color(0xFFF2994A) : const Color(0xFF1B998B),
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => onDelete?.call(member),
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

