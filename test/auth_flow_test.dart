import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/screens/auth/otp_screen.dart';
import 'package:sahayogseva/screens/auth/workspace_screen.dart';
import 'package:sahayogseva/screens/home/home_screen.dart';
import 'package:sahayogseva/widgets/primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

Future<void> _sendOtpFromLogin(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), '9876543210');
  await tester.pump();
  await tester.ensureVisible(find.text('Send OTP →'));
  await tester.tap(find.text('Send OTP →'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    LanguageProvider.skipNativeConnectivity = true;
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
  });

  testWidgets('login send OTP navigates to verification', (tester) async {
    await tester.pumpWidget(flowApp(initialRoute: '/login'));
    await tester.pump();

    await _sendOtpFromLogin(tester);

    expect(find.byType(OtpScreen), findsOneWidget);
    expect(find.textContaining('98765 43210'), findsOneWidget);
  });

  testWidgets('invalid OTP shows error then demo OTP reaches workspace', (
    tester,
  ) async {
    await tester.pumpWidget(flowApp(initialRoute: '/login'));
    await tester.pump();
    await _sendOtpFromLogin(tester);

    final boxes = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(boxes.at(i), '0');
    }
    await tester.pump();
    final primaryBtn = find.byType(PrimaryButton).last;
    await tester.ensureVisible(primaryBtn);
    await tester.tap(primaryBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();

    expect(find.textContaining('Invalid OTP'), findsOneWidget);

    for (var i = 0; i < 6; i++) {
      await tester.enterText(boxes.at(i), '123456'[i]);
    }
    await tester.pump();
    final primaryBtn2 = find.byType(PrimaryButton).last;
    await tester.ensureVisible(primaryBtn2);
    await tester.tap(primaryBtn2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    expect(find.byType(WorkspaceScreen), findsOneWidget);
  });

  testWidgets('workspace selection opens home', (tester) async {
    await tester.pumpWidget(flowApp(initialRoute: '/workspace-selection'));
    await tester.pump();

    final startBtn = find.byType(PrimaryButton).last;
    await tester.tap(startBtn);
    await tester.pump();
    expect(find.textContaining('at least one workspace'), findsOneWidget);

    await tester.tap(find.text('Customer'));
    await tester.pump();
    final startBtn2 = find.byType(PrimaryButton).last;
    await tester.ensureVisible(startBtn2);
    await tester.tap(startBtn2);
    await tester.pump();
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
