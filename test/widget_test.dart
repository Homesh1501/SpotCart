import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotcart/main.dart';
import 'package:spotcart/features/auth/controllers/auth_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders Firebase Config Warning Screen when not initialized', (WidgetTester tester) async {
    // Build our app and trigger a frame with firebaseInitialized: false.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isDemoModeProvider.overrideWith((ref) => true),
        ],
        child: const MyApp(firebaseInitialized: false),
      ),
    );

    // Verify that the config warning screen is shown.
    expect(find.text('Firebase Config Required'), findsOneWidget);
  });
}
