import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahayogseva/models/service_completion_model.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/providers/service_completion_provider.dart';
import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Customer Service Completion (Step 16) Widget Tests', () {
    testWidgets('Renders all completion details and breakdown in English', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = ServiceCompletionProvider();
      provider.setMockDataForTest(
        ServiceCompletionModel.mock(
          bookingCode: 'SHS-842109',
          paymentStatus: PaymentStatus.paymentPending,
        ),
      );

      await tester.pumpWidget(
        flowApp(
          initialRoute: '/customer/service-completion',
          initialLocale: 'en',
          serviceCompletionProvider: provider,
        ),
      );
      await tester.pumpAndSettle();

      // Check Hero Badge
      expect(find.text('Service Completed!'), findsOneWidget);
      expect(find.text('Thank you! Your service has been completed successfully.'), findsOneWidget);

      // Check Worker Info Card
      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);

      // Check Service Details & Bill
      expect(find.text('Service Details'), findsOneWidget);
      expect(find.text('₹420'), findsOneWidget);
      expect(find.text('View Breakdown'), findsOneWidget);

      // Check Before / After Photos
      expect(find.text('Work Photos (Before / After)'), findsOneWidget);
      expect(find.text('Before'), findsOneWidget);
      expect(find.text('After'), findsOneWidget);

      // Check Materials and Duration
      expect(find.text('Materials Used'), findsOneWidget);
      expect(find.text('Service Duration'), findsOneWidget);
      expect(find.text('Total Duration: 45 mins'), findsOneWidget);

      // Check Payment CTA
      expect(find.text('Proceed to Payment ➔'), findsOneWidget);

      // Open Breakdown Modal
      await tester.tap(find.text('View Breakdown'));
      await tester.pumpAndSettle();
      expect(find.text('Bill Summary'), findsOneWidget);
      expect(find.text('Base Amount'), findsOneWidget);
      expect(find.text('₹350'), findsOneWidget);
      expect(find.text('₹50'), findsOneWidget);

      // Close Breakdown Modal
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('Payment flow completes and transitions to invoice + rate experience state', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = ServiceCompletionProvider();
      provider.setMockDataForTest(
        ServiceCompletionModel.mock(
          bookingCode: 'SHS-842109',
          paymentStatus: PaymentStatus.paymentPending,
        ),
      );

      await tester.pumpWidget(
        flowApp(
          initialRoute: '/customer/service-completion',
          initialLocale: 'en',
          serviceCompletionProvider: provider,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Proceed to Payment
      await tester.tap(find.text('Proceed to Payment ➔'));
      await tester.pumpAndSettle();

      // Payment modal shows options
      expect(find.text('Make Payment'), findsOneWidget);
      expect(find.text('UPI (Google Pay)'), findsOneWidget);

      // Tap Pay Now
      final payNowFinder = find.widgetWithText(ElevatedButton, 'Pay Now • ₹420');
      expect(payNowFinder, findsOneWidget);
      await tester.tap(payNowFinder);
      await tester.pumpAndSettle();

      // Should now show Payment Successful and Action buttons
      expect(find.text('Payment Successful'), findsWidgets);
      expect(find.text('Download Invoice'), findsOneWidget);
      expect(find.text('Rate Experience'), findsOneWidget);
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
          paymentStatus: PaymentStatus.paymentPending,
        ),
      );

      await tester.pumpWidget(
        flowApp(
          initialRoute: '/customer/service-completion',
          initialLocale: 'mr',
          languageProvider: langProvider,
          serviceCompletionProvider: provider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('सेवा पूर्ण झाली!'), findsOneWidget);
      expect(find.text('धन्यवाद! आपली सेवा यशस्वीरीत्या पूर्ण झाली.'), findsOneWidget);
      expect(find.text('सेवा तपशील'), findsOneWidget);
      expect(find.text('तपशील पहा'), findsOneWidget);
      expect(find.text('पेमेंट करा ➔'), findsOneWidget);
    });
  });
}
