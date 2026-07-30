import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/presentation/role_selection_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/customer/presentation/customer_navigation_shell.dart';
import 'features/vendor/presentation/vendor_navigation_shell.dart';
import 'features/admin/presentation/admin_navigation_shell.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;
  try {
    // Attempt Firebase initialization with linked configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase Initialization Warning: $e');
    debugPrint('Ensure google-services.json (Android) or GoogleService-Info.plist (iOS) is added.');
  }

  runApp(
    ProviderScope(
      child: MyApp(firebaseInitialized: firebaseInitialized),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool firebaseInitialized;
  const MyApp({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'SpotCart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: firebaseInitialized 
          ? const AuthGate() 
          : const FirebaseConfigWarningScreen(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    // Splash screen during startup session checks
    if (authState.status == AuthStatus.checkingSession) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to SpotCart...', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    if (authState.status == AuthStatus.onboardingRequired) {
      return const RoleSelectionScreen();
    }

    if (authState.status == AuthStatus.authenticated) {
      final role = authState.user?.role;
      if (role == 'vendor') {
        return const VendorNavigationShell();
      } else if (role == 'customer') {
        return const CustomerNavigationShell();
      } else if (role == 'admin') {
        return const AdminNavigationShell();
      } else {
        return const RoleSelectionScreen();
      }
    }

    // Step 1: Default entrypoint opens the Multi-Role Login Portal directly!
    return const LoginScreen();
  }
}

class FirebaseConfigWarningScreen extends ConsumerWidget {
  const FirebaseConfigWarningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Firebase Config Required',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              const SizedBox(height: 16),
              const Text(
                'SpotCart relies on Firebase services. To run the app on a physical device or emulator, please make sure you:\n\n'
                '1. Create a Firebase project in the Firebase Console.\n'
                '2. Add an Android app and download google-services.json into android/app/.\n'
                '3. Add an iOS app and download GoogleService-Info.plist into ios/Runner/.\n'
                '4. Enable Phone Authentication and Cloud Firestore in the Firebase Console.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black54),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  // Enable demo mode (bypasses Firebase with in-memory database)
                  ref.read(isDemoModeProvider.notifier).state = true;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const AuthGate(),
                    ),
                  );
                },
                child: const Text('Enter Demo Mode'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
