import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';

class ReviewUserDetailScreen extends StatelessWidget {
  final String userId;

  const ReviewUserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final dummyProfile = {
      'name': 'Sophia Tan',
      'email': 'sophia.tan@email.com',
      'phone': '+60 12-345 6789',
    };

    final dummySuspension = {
      'reason': 'Violation of community guidelines',
      'date': '2024-01-15',
      'status': 'Suspended Pending Review',
      'violations': '3',
    };

    final dummySubmission = {
      'submissionDate': '2024-07-26',
      'status': 'Pending Review',
    };

    final documentImages = List.generate(6, (index) => 'https://via.placeholder.com/150');

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            if (context.mounted) {
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
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Suspended Details',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF387366),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                title: 'User Profile',
                                child: _buildTwoColumnInfo({
                                  'Name': dummyProfile['name']!,
                                  'Email': dummyProfile['email']!,
                                  'Phone': dummyProfile['phone']!,
                                }),
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                title: 'Suspension Details',
                                child: _buildTwoColumnInfo({
                                  'Reason for Suspension': dummySuspension['reason']!,
                                  'Suspension Date': dummySuspension['date']!,
                                  'Status': dummySuspension['status']!,
                                  'Number of Violations': dummySuspension['violations']!,
                                }),
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                title: 'Submitted Documents',
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: documentImages.length,
                                  itemBuilder: (_, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        documentImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                title: 'Submission Details',
                                child: _buildTwoColumnInfo({
                                  'Submission Date': dummySubmission['submissionDate']!,
                                  'Suspended Status': dummySubmission['status']!,
                                }),
                              ),
                              const SizedBox(height: 24),
                              _buildActionButtons(),
                            ],
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
                currentRoute: '/admin/users/review',
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

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E8EB)),
            color: Colors.white,
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildTwoColumnInfo(Map<String, String> info) {
    final entries = info.entries.toList();
    return Column(
      children: List.generate(
        (entries.length / 2).ceil(),
        (rowIndex) {
          final first = entries[rowIndex * 2];
          final second = (rowIndex * 2 + 1) < entries.length ? entries[rowIndex * 2 + 1] : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoItem(first.key, first.value)),
                if (second != null) ...[
                  const SizedBox(width: 24),
                  Expanded(child: _buildInfoItem(second.key, second.value)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final buttons = [
      {'label': 'Reinstate Account', 'color': AppTheme.primaryColor},
      {'label': 'Maintain Suspension', 'color': const Color(0xFF6C757D)},
      {'label': 'Permanently Delete Account', 'color': const Color(0xFFE74C3C)},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: buttons.map((button) {
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: button['color'] as Color,
            side: BorderSide(color: button['color'] as Color),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Text(button['label'] as String),
        );
      }).toList(),
    );
  }
}

