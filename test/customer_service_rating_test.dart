import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahayogseva/l10n/l10n.dart';
import 'package:sahayogseva/models/service_completion_model.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/providers/service_completion_provider.dart';
import 'test_app.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Customer Service Rating (Step 17) Widget Tests', () {
    testWidgets('Renders After Service summary, rating card, and info tiles in English', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = ServiceCompletionProvider();
      provider.setMockDataForTest(
        ServiceCompletionModel.mock(
          bookingCode: 'SHS-842109',
          paymentStatus: PaymentStatus.paymentSuccess,
        ),
      );

      await tester.pumpWidget(
        flowApp(
          initialRoute: '/customer/service-rating',
          initialLocale: 'en',
          serviceCompletionProvider: provider,
        ),
      );
      await tester.pumpAndSettle();

      // Check Screen Title & Hero Badge
      expect(find.text('After Service'), findsOneWidget);
      expect(find.text('Service Completed!'), findsOneWidget);

      // Check Work Summary Card
      expect(find.text('Work Summary'), findsOneWidget);
      expect(find.text('Water was leaking from the tap.'), findsOneWidget);
      expect(find.text('Joint repaired and rubber washer replaced.'), findsOneWidget);

      // Check Payment Details Card
      expect(find.text('Payment Details'), findsOneWidget);
      expect(find.text('₹420'), findsOneWidget);
      expect(find.text('INV-250531-1123'), findsOneWidget);

      // Check Interactive Rating Card
      expect(find.text('Give Rating'), findsOneWidget);
      expect(find.text('How was your experience?'), findsOneWidget);
      expect(find.text('Submit Rating'), findsOneWidget);

      // Check Information Tiles
      expect(find.text('Book Again'), findsOneWidget);
      expect(find.text('Invoice / Receipt'), findsOneWidget);
      expect(find.text('Service Warranty'), findsOneWidget);
      expect(find.text('Need Help?'), findsOneWidget);
      expect(find.text('Share Service'), findsOneWidget);

      // Check Go to Home Button
      expect(find.text('Go to Home'), findsOneWidget);
    });

    testWidgets('Submitting star rating and feedback updates rating card to rated state', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = ServiceCompletionProvider();
      provider.setMockDataForTest(
        ServiceCompletionModel.mock(
          bookingCode: 'SHS-842109',
          paymentStatus: PaymentStatus.paymentSuccess,
        ),
      );

      await tester.pumpWidget(
        flowApp(
          initialRoute: '/customer/service-rating',
          initialLocale: 'en',
          serviceCompletionProvider: provider,
        ),
      );
      await tester.pumpAndSettle();

      // Type feedback
      final textfieldFinder = find.byType(TextField);
      expect(textfieldFinder, findsOneWidget);
      await tester.enterText(textfieldFinder, 'Worker was very polite, punctual and fixed the leaking tap quickly!');
      await tester.pumpAndSettle();

      // Tap Submit Rating
      await tester.tap(find.text('Submit Rating'));
      await tester.pumpAndSettle();

      // Success message displayed
      expect(find.text('Thank you! Rating submitted successfully.'), findsWidgets);
      expect(find.text('5.0 / 5.0'), findsOneWidget);
    });

    testWidgets('Opening 7-day warranty modal displays policy details', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = ServiceCompletionProvider();
      provider.setMockDataForTest(
        ServiceCompletionModel.mock(
          bookingCode: 'SHS-842109',
          paymentStatus: PaymentStatus.paymentSuccess,
        ),
      );

      await tester.pumpWidget(
        flowApp(
          initialRoute: '/customer/service-rating',
          initialLocale: 'en',
          serviceCompletionProvider: provider,
        ),
      );
      await tester.pumpAndSettle();

      // Tap More Info on Warranty Tile
      await tester.tap(find.text('More Info →'));
      await tester.pumpAndSettle();

      expect(find.text('7-Day Service Warranty Policy'), findsOneWidget);
      expect(find.textContaining('guarantees high-quality workmanship for 7 days'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      expect(find.text('7-Day Service Warranty Policy'), findsNothing);
    });

    testWidgets('Renders properly in Marathi (mr)', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final langProvider = LanguageProvider();
      langProvider.setLanguage('mr');

      final provider = ServiceCompletionProvider();
      provider.setMockDataForTest(
        ServiceCompletionModel.mock(
          bookingCode: 'SHS-842109',
          paymentStatus: PaymentStatus.paymentSuccess,
        ),
      );

      await tester.pumpWidget(
        flowApp(
          initialRoute: '/customer/service-rating',
          initialLocale: 'mr',
          languageProvider: langProvider,
          serviceCompletionProvider: provider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('सेवा नंतर'), findsOneWidget);
      expect(find.text('कामाचा सारांश'), findsOneWidget);
      expect(find.text('पेमेंट तपशील'), findsOneWidget);
      expect(find.text('रेटिंग द्या'), findsOneWidget);
      expect(find.text('सबमिट करा'), findsOneWidget);
      expect(find.text('पुन्हा बुक करा'), findsOneWidget);
      expect(find.text('सेवा हमी'), findsOneWidget);
      expect(find.text(const AppStrings('mr').goToHomeBtn), findsOneWidget);
    });
  });
}
