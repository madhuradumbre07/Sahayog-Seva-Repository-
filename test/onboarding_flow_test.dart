import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/screens/auth/language_selection_screen.dart';
import 'package:sahayogseva/screens/auth/login_screen.dart';
import 'package:sahayogseva/screens/auth/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    LanguageProvider.skipNativeConnectivity = true;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('continue without selection shows validation banner', (
    tester,
  ) async {
    final languageProvider = LanguageProvider();
    // Do not set language code
    await tester.pumpWidget(
      flowApp(
        languageProvider: languageProvider,
      ),
    );
    await tester.pumpAndSettle();

    // Select and continue
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);
  });

  testWidgets('selecting a language and continue opens onboarding', (
    tester,
  ) async {
    await tester.pumpWidget(flowApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.tap(find.text('Continue →'));
    await tester.pump();
    expect(find.textContaining('Setting Language'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Verified Skilled Workers'), findsOneWidget);
    expect(find.text('Next →'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_language'), 'en');
  });

  testWidgets('onboarding next, skip and get started navigate correctly', (
    tester,
  ) async {
    await tester.pumpWidget(flowApp(initialRoute: '/onboarding'));
    await tester.pumpAndSettle();

    expect(find.text('Verified Skilled Workers'), findsOneWidget);

    await tester.tap(find.text('Next →'));
    await tester.pumpAndSettle();
    expect(find.text('Transparent Pricing'), findsOneWidget);

    await tester.tap(find.text('Next →'));
    await tester.pumpAndSettle();
    expect(find.text('Guaranteed Quality'), findsOneWidget);
    expect(find.text('Get Started →'), findsOneWidget);

    await tester.tap(find.text('Get Started →'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('skip on onboarding goes to login', (tester) async {
    await tester.pumpWidget(flowApp(initialRoute: '/onboarding'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
