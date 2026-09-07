import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sahayogseva/l10n/l10n.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/providers/booking_tracking_provider.dart';
import 'package:sahayogseva/models/booking_request_model.dart';
import 'package:sahayogseva/models/booking_tracking_model.dart';
import 'package:sahayogseva/models/worker_matching_model.dart';
import 'package:sahayogseva/screens/customer/customer_booking_confirmation_screen.dart';
import 'package:sahayogseva/screens/customer/customer_track_service_screen.dart';

import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MyHttpOverrides();
  });
  
  group('Booking Confirmation & Tracking Flow Tests', () {
    late BookingDraftModel mockBooking;

    setUp(() {
      mockBooking = BookingDraftModel(
        serviceCategory: 'Plumbing',
        serviceSubcategory: 'Tap & Faucet Repair',
        problemDescription: 'Tap is leaking heavily',
        worker: WorkerMatchModel.fallbackWorkers.first,
        selectedAddress: AddressItem(
          id: 'ADDR-TEST',
          title: 'Home',
          addressLine: '123 Test St, Pune',
          latitude: 18.5,
          longitude: 73.8,
        ),
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '10:00 AM - 11:00 AM',
        bookingCode: 'SHS-TEST12',
      );
    });

    Widget buildTestApp(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()..init()),
          ChangeNotifierProvider(create: (_) => BookingTrackingProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(builder: (context) {
            return AppLocaleScope(
              locale: const Locale('en'),
              child: child,
            );
          }),
        ),
      );
    }

    testWidgets('Step 14: Booking Confirmation Screen Renders Success Elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          CustomerBookingConfirmationScreen(
            booking: mockBooking,
            initialState: BookingConfirmationState.confirmed,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.check_circle), findsWidgets); // Hero checkmark
      expect(find.text('SHS-TEST12'), findsOneWidget); // Booking ID
      expect(find.textContaining('Plumbing'), findsOneWidget); // Summary
    });

    testWidgets('Step 15: Track Service Screen Renders', (WidgetTester tester) async {
      await tester.runAsync(() async {
        final mockProvider = BookingTrackingProvider();
        mockProvider.setMockDataForTest(BookingTrackingModel.fallback().copyWith(
          bookingCode: 'SHS-TEST12',
          workerAvatarUrl: '',
        ));

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => LanguageProvider()..init()),
              ChangeNotifierProvider<BookingTrackingProvider>.value(value: mockProvider),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              home: Builder(builder: (context) {
                return const AppLocaleScope(
                  locale: Locale('en'),
                  child: CustomerTrackServiceScreen(bookingId: 'SHS-TEST12'),
                );
              }),
            ),
          ),
        );
        
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.textContaining('SHS-TEST12'), findsWidgets);

        mockProvider.stopPolling();
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
      });
    });

  });
}
