import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FloatingChatbotButton extends StatelessWidget {
  const FloatingChatbotButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // TODO: Open chatbot dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chatbot feature coming soon!'),
          ),
        );
      },
      backgroundColor: AppTheme.primaryColor,
      shape: const StadiumBorder(),
      icon: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(2),
        child: Image.asset(
          'assets/images/homexpert_logo_white.png',
          fit: BoxFit.contain,
        ),
      ),
      label: const Text(
        'Chatbot',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          //add text spacing
          letterSpacing: 1,
        ),
      ),
    );
  }
}

