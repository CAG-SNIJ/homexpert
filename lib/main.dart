import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'core/config/router_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optional - only needed for image storage)
  // Skip initialization on web if Firebase scripts are not configured in index.html
  // This allows the app to run without Firebase setup
  // Firebase will be initialized later when image uploads are needed
  if (!kIsWeb) {
    // For mobile platforms (Android/iOS), try to initialize Firebase
    // Firebase should be configured via google-services.json or GoogleService-Info.plist
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        debugPrint('✅ Firebase initialized successfully');
      }
    } catch (e) {
      // Firebase not configured - this is OK, app can still run
      debugPrint('⚠️ Firebase not configured. Image uploads disabled until Firebase is set up.');
    }
  } else {
    // On web, Firebase should be initialized via scripts in index.html
    // If scripts are present, Firebase will be auto-initialized
    // If not, we skip initialization to avoid errors
    // Check if Firebase is already initialized by scripts
    if (Firebase.apps.isNotEmpty) {
      debugPrint('✅ Firebase initialized via web scripts');
    } else {
      debugPrint('⚠️ Firebase not configured in index.html. Image uploads disabled until Firebase is set up.');
    }
  }
  
  runApp(const HomeXpertApp());
}

class HomeXpertApp extends StatelessWidget {
  const HomeXpertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
