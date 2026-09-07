import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sahayogseva/main.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/screens/auth/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    LanguageProvider.skipNativeConnectivity = true;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app launches on splash', (tester) async {
    await tester.pumpWidget(const SahayogSevaApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('SahayogSeva'), findsOneWidget);
  });
}
