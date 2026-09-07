import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/screens/customer/customer_ai_analysis_screen.dart';
import 'package:sahayogseva/screens/customer/customer_ai_result_screen.dart';
import 'package:sahayogseva/screens/customer/customer_describe_problem_screen.dart';
import 'package:sahayogseva/screens/customer/customer_matching_workers_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    LanguageProvider.skipNativeConnectivity = true;
    SharedPreferences.setMockInitialValues({});
  });

  group('Customer Flow Step 07: Describe Problem Screen', () {
    testWidgets('renders all Step 07 elements, tabs, and suggestion chips', (
      tester,
    ) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/describe-problem'),
      );
      await tester.pumpAndSettle();

      // Header and screen
      expect(find.byType(CustomerDescribeProblemScreen), findsOneWidget);
      expect(find.text('Describe Problem (AI)'), findsOneWidget);

      // 4 Input Mode Tabs
      expect(find.text('Text'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget);
      expect(find.text('Photo'), findsOneWidget);
      expect(find.text('Video'), findsOneWidget);

      // Suggestion chips
      expect(find.text('Examples'), findsOneWidget);
      expect(find.text('Tap is leaking'), findsOneWidget);
      expect(find.text('Light not working'), findsOneWidget);
      expect(find.text('Geyser needs cleaning'), findsOneWidget);
      expect(find.text('AC is not cooling'), findsOneWidget);

      // Primary Button & Privacy Badge
      expect(find.text('✨ Start AI Analysis'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets('mode tab switching works for Voice, Photo, and Video', (
      tester,
    ) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/describe-problem'),
      );
      await tester.pumpAndSettle();

      // Switch to Voice tab
      await tester.tap(find.text('Voice'));
      await tester.pumpAndSettle();
      expect(find.text('Speak your problem clearly'), findsOneWidget);

      // Switch to Photo tab
      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();
      expect(find.text('Take with Camera'), findsOneWidget);
      expect(find.text('Pick from Gallery'), findsOneWidget);

      // Add a sample photo
      await tester.tap(find.text('Pick from Gallery'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.image), findsOneWidget);

      // Switch to Video tab
      await tester.tap(find.text('Video'));
      await tester.pumpAndSettle();
      expect(find.text('Pick Video'), findsOneWidget);

      // Add sample video
      await tester.tap(find.text('Pick Video'));
      await tester.pumpAndSettle();
      expect(find.text('video_2025_05_12.mp4'), findsOneWidget);
    });

    testWidgets('tapping example chip populates input and enables analysis', (
      tester,
    ) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/describe-problem'),
      );
      await tester.pumpAndSettle();

      // Tap Example Chip
      await tester.tap(find.text('Tap is leaking'));
      await tester.pumpAndSettle();

      // Verify text field contains chip text
      expect(find.text('Tap is leaking'), findsWidgets);
    });
  });

  group('Customer Flow Step 08: AI Analysis Breakdown Screen', () {
    testWidgets('renders all 7 structured breakdown cards and confidence bar', (
      tester,
    ) async {
      await tester.pumpWidget(flowApp(initialRoute: '/customer/ai-analysis'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerAiAnalysisScreen), findsOneWidget);
      expect(find.text('AI Analysis'), findsOneWidget);
      expect(find.text('AI Analysis of your problem is complete!'), findsOneWidget);

      // 1. Identified problem
      expect(find.text('1. Identified Problem'), findsOneWidget);

      // 2. Confidence level
      expect(find.text('2. Confidence Level'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);

      // 3. Suggested service
      expect(find.text('3. Suggested Service'), findsOneWidget);
      expect(find.text('Plumbing - Tap / Faucet Repair'), findsOneWidget);

      // 4. Required skills
      expect(find.text('4. Required Skills'), findsOneWidget);

      // 5. Estimated Time & Cost
      expect(find.text('5. Estimated Time'), findsOneWidget);
      expect(find.text('5. Estimated Cost'), findsOneWidget);
      expect(find.text('30 - 45 Minutes'), findsOneWidget);
      expect(find.text('₹250 - ₹500'), findsOneWidget);

      // 6. Urgency level & 7. AI Reasoning
      expect(find.text('6. Urgency Level'), findsOneWidget);
      expect(find.text('7. AI Explanation'), findsOneWidget);

      // Dual Action Buttons
      expect(find.text('Edit / Re-analyze'), findsOneWidget);
      expect(find.text('This problem is correct'), findsOneWidget);
    });

    testWidgets('confirm button in Step 08 proceeds to Step 09', (tester) async {
      await tester.pumpWidget(flowApp(initialRoute: '/customer/ai-analysis'));
      await tester.pumpAndSettle();

      final confirmBtn = find.text('This problem is correct');
      await tester.ensureVisible(confirmBtn);
      await tester.pumpAndSettle();

      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CustomerAiResultScreen), findsOneWidget);
    });
  });

  group('Customer Flow Step 09: AI Result & Service Recommendation', () {
    testWidgets('renders hero checkmark, recommendation, and alternative services', (
      tester,
    ) async {
      await tester.pumpWidget(flowApp(initialRoute: '/customer/ai-result'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerAiResultScreen), findsOneWidget);
      expect(find.text('AI Result'), findsOneWidget);
      expect(find.text('We found the right service!'), findsOneWidget);

      // Recommended Service
      expect(find.text('1. Recommended Service'), findsOneWidget);
      expect(find.text('High Match (92%)'), findsOneWidget);

      // Why this service expandable tile
      final whyDetails = find.text('View Details ▾');
      await tester.ensureVisible(whyDetails);
      await tester.pumpAndSettle();
      expect(whyDetails, findsOneWidget);

      await tester.tap(whyDetails);
      await tester.pumpAndSettle();
      expect(find.text('Hide Details ▴'), findsOneWidget);

      // Alternative Services
      final altTitle = find.text('7. Alternative Services (Alternatives)');
      await tester.ensureVisible(altTitle);
      await tester.pumpAndSettle();
      expect(altTitle, findsOneWidget);
      expect(find.text('Pipe Leakage Repair'), findsOneWidget);
      expect(find.text('Bathroom Plumbing'), findsOneWidget);

      // Action buttons
      final changeBtn = find.text('Change Service');
      await tester.ensureVisible(changeBtn);
      expect(changeBtn, findsOneWidget);

      final nextBtn = find.text('Confirm & Find Matching Workers ➔');
      await tester.ensureVisible(nextBtn);
      expect(nextBtn, findsOneWidget);
    });

    testWidgets('confirming Step 09 navigates to matching workers screen', (
      tester,
    ) async {
      await tester.pumpWidget(flowApp(initialRoute: '/customer/ai-result'));
      await tester.pumpAndSettle();

      final nextBtn = find.text('Confirm & Find Matching Workers ➔');
      await tester.ensureVisible(nextBtn);
      await tester.pumpAndSettle();

      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CustomerMatchingWorkersScreen), findsOneWidget);
      expect(find.text('Matching Workers'), findsOneWidget);
    });
  });

  group('Smart Dynamic 8-Language Auto-Detection', () {
    testWidgets('dynamically detects languages as user types across 8 scripts', (
      tester,
    ) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/describe-problem'),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);

      // 1. English input
      await tester.enterText(textField, 'Water is leaking from the kitchen tap');
      await tester.pumpAndSettle();
      expect(find.text('AI Language Detected: English'), findsOneWidget);

      // 2. Marathi input
      await tester.enterText(textField, 'माझ्या घरात नळ गळत आहे आणि पाणी वाहत आहे');
      await tester.pumpAndSettle();
      expect(find.text('AI Language Detected: मराठी (Marathi)'), findsOneWidget);

      // 3. Hindi input
      await tester.enterText(textField, 'किचन का नल खराब है और पानी टपक रहा है');
      await tester.pumpAndSettle();
      expect(find.text('AI Language Detected: हिंदी (Hindi)'), findsOneWidget);

      // 4. Gujarati input
      await tester.enterText(textField, 'નળમાંથી પાણી ટપકે છે અને સમારકામ જોઈએ');
      await tester.pumpAndSettle();
      expect(find.text('AI Language Detected: ગુજરાતી (Gujarati)'), findsOneWidget);

      // 5. Tamil input
      await tester.enterText(textField, 'குழாயிலிருந்து தண்ணீர் கசிகிறது');
      await tester.pumpAndSettle();
      expect(find.text('AI Language Detected: தமிழ் (Tamil)'), findsOneWidget);

      // 6. Telugu input
      await tester.enterText(textField, 'కుళాయి నుండి నీరు కారుతోంది');
      await tester.pumpAndSettle();
      expect(find.text('AI Language Detected: తెలుగు (Telugu)'), findsOneWidget);

      // 7. Kannada input
      await tester.enterText(textField, 'ನಲ್ಲಿಯಿಂದ ನೀರು ಸೋರುತ್ತಿದೆ');
      await tester.pumpAndSettle();
      expect(find.text('AI Language Detected: ಕನ್ನಡ (Kannada)'), findsOneWidget);

      // 8. Bengali input
      await tester.enterText(textField, 'কল থেকে জল পড়ছে এবং মেরামত দরকার');
      await tester.pumpAndSettle();
      expect(find.text('AI Language Detected: বাংলা (Bengali)'), findsOneWidget);

      // 9. Marathlish / Hinglish Phonetic input
      await tester.enterText(textField, 'nal galat ahe pani thambla nahi');
      await tester.pumpAndSettle();
      expect(find.text('AI Language Detected: मराठी (Marathi)'), findsOneWidget);
    });

    testWidgets('tapping detected language chip opens override sheet and allows manual selection', (
      tester,
    ) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/describe-problem'),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Water is leaking');
      await tester.pumpAndSettle();

      // Tap on detected language chip
      final chip = find.text('AI Language Detected: English');
      expect(chip, findsOneWidget);
      await tester.tap(chip);
      await tester.pumpAndSettle();

      // Verify bottom sheet appears
      expect(find.text('Select Preferred Language'), findsOneWidget);
      expect(find.text('Hindi (हिन्दी)'), findsOneWidget);
      expect(find.text('Marathi (मराठी)'), findsOneWidget);

      // Select Marathi override
      await tester.tap(find.text('Marathi (मराठी)'));
      await tester.pumpAndSettle();

      // Verify banner updated to overridden choice
      expect(find.text('AI Language Detected: मराठी (Marathi)'), findsOneWidget);
    });
  });

}
