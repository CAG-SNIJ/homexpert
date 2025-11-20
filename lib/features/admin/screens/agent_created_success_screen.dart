import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';

class AgentCreatedSuccessScreen extends StatelessWidget {
  const AgentCreatedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
                      const SizedBox(height: 60),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 60),
                                const Icon(
                                  Icons.task_alt,
                                  size: 100,
                                  color: Color(0xFF387366),
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'Agent Created Successfully',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'A welcome email with login instructions has been sent to the agent.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 48),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.go('/admin/agents/add');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF387366),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Back to Create Agent',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
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
              child: const AdminSidebar(
                currentRoute: '/admin/agents/add',
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

