import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase auto-configures from google-services.json (Android) or
  // GoogleService-Info.plist (iOS). On iOS, ensure the plist is in place.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase may fail to initialize if config files are missing.
    // The app will show the login screen and gracefully handle auth errors.
    debugPrint('Firebase init warning: $e');
  }

  runApp(const ProviderScope(child: FlashyApp()));
}
