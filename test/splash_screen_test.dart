import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sahayogseva/providers/auth_provider.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/screens/auth/language_selection_screen.dart';
import 'package:sahayogseva/screens/auth/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sahayogseva/l10n/l10n.dart';

Widget _splashApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: MaterialApp(
      builder: (context, child) {
        final language = context.watch<LanguageProvider>();
        return AppLocaleScope(
          locale: language.locale,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
      routes: {
        '/language-selection': (context) => const LanguageSelectionScreen(),
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    LanguageProvider.skipNativeConnectivity = true;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('splash shows branding and navigates to language selection', (
    tester,
  ) async {
    await tester.pumpWidget(_splashApp());

    expect(find.text('SahayogSeva'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(SplashScreen.delay);
    await tester.pumpAndSettle();

    expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    expect(find.text('Choose Your Language'), findsOneWidget);
  });
}
