import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safetynecklaceapp/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? firebaseInitError;

  try {
    await Firebase.initializeApp();
  } catch (error, stackTrace) {
    firebaseInitError = error;
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(MyApp(firebaseInitError: firebaseInitError));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.firebaseInitError});

  final Object? firebaseInitError;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFF4BF5E),
        surface: const Color(0xFFFFEFD2),
      ),
      textTheme: GoogleFonts.judsonTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFEFD2),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF4BF5E),
          foregroundColor: const Color(0xFF3A3A3A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );

    if (firebaseInitError != null) {
      return MaterialApp(
        title: 'SafeNeck',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: _FirebaseSetupErrorScreen(error: firebaseInitError.toString()),
      );
    }

    return MaterialApp(
      title: 'SafeNeck',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routes: routes,
    );
  }
}

class _FirebaseSetupErrorScreen extends StatelessWidget {
  const _FirebaseSetupErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFEFD2);

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 56,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'SafeNeck setup required',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  kIsWeb
                      ? 'This project is currently configured for mobile Firebase only. Run it on iOS or Android, or add web Firebase options.'
                      : 'Firebase could not initialize. Verify the iOS/Android Firebase config files are present and match this app.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
