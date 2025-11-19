import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int page)? onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () => onPageChanged?.call(currentPage - 1)
              : null,
          color: currentPage > 1
              ? AppTheme.primaryColor
              : AppTheme.textSecondary,
        ),
        const SizedBox(width: 8),
        // Page numbers
        ...List.generate(
          totalPages,
          (index) {
            final pageNumber = index + 1;
            final isActive = pageNumber == currentPage;
            return GestureDetector(
              onTap: () => onPageChanged?.call(pageNumber),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primaryColor
                        : const Color(0xFFE5E8EB),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$pageNumber',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive
                          ? Colors.white
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        // Next button
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () => onPageChanged?.call(currentPage + 1)
              : null,
          color: currentPage < totalPages
              ? AppTheme.primaryColor
              : AppTheme.textSecondary,
        ),
      ],
    );
  }
}

