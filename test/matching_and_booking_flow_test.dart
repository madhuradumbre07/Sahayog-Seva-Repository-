import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sahayogseva/l10n/l10n.dart';
import 'package:sahayogseva/models/worker_matching_model.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/providers/booking_flow_provider.dart';
import 'package:sahayogseva/screens/customer/customer_matching_workers_screen.dart';
import 'package:sahayogseva/screens/customer/customer_worker_profile_screen.dart';
import 'package:sahayogseva/screens/customer/customer_booking_details_screen.dart';
import 'package:sahayogseva/screens/customer/customer_booking_confirmation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    LanguageProvider.skipNativeConnectivity = true;
    SharedPreferences.setMockInitialValues({});
  });

  group('Screen 10: Matching Workers Flow', () {
    testWidgets('renders Radar triage view and loads matching workers', (
      tester,
    ) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/matching-workers'),
      );
      await tester.pump();

      // Verify radar and steps
      expect(find.byType(CustomerMatchingWorkersScreen), findsOneWidget);
      expect(find.text('Matching Workers'), findsOneWidget);
      expect(find.text('Finding Best Workers...'), findsOneWidget);
      expect(find.text('Live Search Status'), findsOneWidget);

      // Fast forward past matching delays
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify match cards loaded
      expect(find.text('राहुल शर्मा'), findsOneWidget);
      expect(find.text('92% Match'), findsWidgets);
      expect(find.text('View Details'), findsWidgets);
      expect(find.text('Select'), findsWidgets);
    });

    testWidgets('toggles between List View and Map View', (tester) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/matching-workers'),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.map_outlined));
      await tester.pumpAndSettle();

      // Map view active
      expect(find.byIcon(Icons.location_pin), findsWidgets);

      // Toggle back to list
      await tester.tap(find.byIcon(Icons.view_list));
      await tester.pumpAndSettle();
      expect(find.text('राहुल शर्मा'), findsOneWidget);
    });

    testWidgets('filter sheet opens and adjusts filters', (tester) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/matching-workers'),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(find.text('Distance (Range)'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);

      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerMatchingWorkersScreen), findsOneWidget);
    });

    testWidgets('sort sheet opens and applies sort option', (tester) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/matching-workers'),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      expect(find.text('Best Match (Default)'), findsOneWidget);
      expect(find.text('Nearest to Me'), findsOneWidget);
      expect(find.text('Lowest Price'), findsOneWidget);

      await tester.tap(find.text('Nearest to Me'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerMatchingWorkersScreen), findsOneWidget);
    });

    testWidgets('tapping View Details opens Screen 11 Worker Profile', (
      tester,
    ) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/matching-workers'),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      final viewDetailsBtn = find.text('View Details').first;
      await tester.tap(viewDetailsBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CustomerWorkerProfileScreen), findsOneWidget);
      expect(find.text('Worker Profile'), findsOneWidget);
    });

    testWidgets('tapping Select opens Screen 12 Booking Details', (
      tester,
    ) async {
      await tester.pumpWidget(
        flowApp(initialRoute: '/customer/matching-workers'),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      final selectBtn = find.text('Select').first;
      await tester.tap(selectBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CustomerBookingDetailsScreen), findsOneWidget);
      expect(find.text('Booking Details'), findsOneWidget);
    });
  });

  group('Screen 11: Worker Profile Screen', () {
    testWidgets('renders all hero cards, explainability bars, skills, and CTAs', (
      tester,
    ) async {
      final worker = WorkerMatchModel.fallbackWorkers.first;

      final app = MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookingFlowProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: MaterialApp(
          home: AppLocaleScope(
            locale: const Locale('en'),
            child: CustomerWorkerProfileScreen(worker: worker),
          ),
        ),
      );
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(CustomerWorkerProfileScreen), findsOneWidget);
      expect(find.text('Worker Profile'), findsOneWidget);
      expect(find.text('Explainable Match Score'), findsOneWidget);
      expect(find.text('Skill Match'), findsOneWidget);
      expect(find.text('Proximity'), findsOneWidget);
      expect(find.text('Availability'), findsOneWidget);
      expect(find.text('Workload Balance'), findsOneWidget);
      expect(find.text('Skills & Experience'), findsOneWidget);
      expect(find.text('Cooperative Verified'), findsOneWidget);
      expect(find.text('Certifications'), findsOneWidget);
      expect(find.text('Customer Reviews'), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);
    });

    testWidgets('tapping Book Now in Screen 11 navigates to Booking Details', (
      tester,
    ) async {
      final worker = WorkerMatchModel.fallbackWorkers.first;
      final bookingProv = BookingFlowProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<BookingFlowProvider>.value(value: bookingProv),
          ],
          child: MaterialApp(
            home: AppLocaleScope(
              locale: const Locale('en'),
              child: CustomerWorkerProfileScreen(worker: worker),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Book Now'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerBookingDetailsScreen), findsOneWidget);
    });
  });

  group('Screen 12: Booking Details & Screen 13 Confirmation', () {
    testWidgets('renders all 5 section cards, security banner, and price breakdown', (
      tester,
    ) async {
      final worker = WorkerMatchModel.fallbackWorkers.first;
      final bookingProv = BookingFlowProvider()..initializeForWorker(worker);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<BookingFlowProvider>.value(value: bookingProv),
          ],
          child: MaterialApp(
            home: AppLocaleScope(
              locale: const Locale('en'),
              child: CustomerBookingDetailsScreen(worker: worker),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomerBookingDetailsScreen), findsOneWidget);
      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.text('Your booking information is encrypted & secure.'), findsOneWidget);
      expect(find.text('1. Selected Worker'), findsOneWidget);
      expect(find.text('2. Service & Problem Summary'), findsOneWidget);
      expect(find.text('3. Service Location'), findsOneWidget);
      expect(find.text('4. Date & Time'), findsOneWidget);
      expect(find.text('5. Special Instructions (Optional)'), findsOneWidget);
      expect(find.text('Estimated Cost Breakdown'), findsOneWidget);
      expect(find.text('Proceed to Confirmation →'), findsOneWidget);
    });

    testWidgets('submitting booking navigates to Booking Confirmation', (
      tester,
    ) async {
      final worker = WorkerMatchModel.fallbackWorkers.first;
      final bookingProv = BookingFlowProvider()..initializeForWorker(worker);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<BookingFlowProvider>.value(value: bookingProv),
          ],
          child: MaterialApp(
            home: AppLocaleScope(
              locale: const Locale('en'),
              child: CustomerBookingDetailsScreen(worker: worker),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Proceed to Confirmation →'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerBookingConfirmationScreen), findsOneWidget);
      expect(find.text('Booking Confirmed!'), findsWidgets);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('8-Language Translation Completeness for Screens 10, 11, 12, 13', () {
    test('all new keys translate across all 8 languages without raw key return', () {
      const languages = ['en', 'hi', 'mr', 'gu', 'ta', 'te', 'kn', 'bn'];
      const testKeys = [
        'matchingWorkersTitle',
        'findingWorkersRadar',
        'liveSearchStatus',
        'filterBtnLabel',
        'sortBtnLabel',
        'viewDetailsBtn',
        'selectWorkerBtn',
        'workerProfileTitle',
        'matchScoreBreakdownTitle',
        'skillMatchBar',
        'proximityBar',
        'availabilityBar',
        'workloadFairnessBar',
        'skillsAndExpLabel',
        'coopDetailsLabel',
        'certificationsLabel',
        'bookNowBtn',
        'bookingDetailsTitle',
        'bookingSecurityBanner',
        'selectedWorkerSection',
        'serviceSummarySection',
        'addressSection',
        'dateTimeSection',
        'instructionsSection',
        'priceBreakdownTitle',
        'proceedConfirmationBtn',
        'bookingSuccessTitle',
      ];

      for (final lang in languages) {
        for (final key in testKeys) {
          final translated = AppStringsData.translate(key, languageCode: lang);
          expect(
            translated,
            isNot(equals(key)),
            reason: 'Key "$key" should have a translation in language "$lang"',
          );
          expect(translated.isNotEmpty, true);
        }
      }
    });
  });
}
