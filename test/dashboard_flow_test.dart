import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sahayogseva/models/worker_dashboard_data.dart';
import 'package:sahayogseva/models/workspace_role.dart';
import 'package:sahayogseva/providers/auth_provider.dart';
import 'package:sahayogseva/providers/customer_dashboard_provider.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/providers/worker_dashboard_provider.dart';
import 'package:sahayogseva/providers/worker_profile_provider.dart';
import 'package:sahayogseva/screens/dashboard/dashboard_shell.dart';
import 'package:sahayogseva/services/worker_job_api_service.dart';
import 'package:sahayogseva/widgets/ai_assist_sheet.dart';
import 'package:sahayogseva/widgets/customer/ai_problem_card.dart';
import 'package:sahayogseva/widgets/customer/greeting_header.dart';
import 'package:sahayogseva/widgets/customer/ongoing_booking_card.dart';
import 'package:sahayogseva/widgets/customer/popular_services_grid.dart';
import 'package:sahayogseva/widgets/customer/promo_banner_card.dart';
import 'package:sahayogseva/widgets/customer/trust_guarantee_card.dart';
import 'package:sahayogseva/widgets/worker/appointment_timeline_card.dart';
import 'package:sahayogseva/widgets/worker/availability_status_card.dart';
import 'package:sahayogseva/widgets/worker/job_request_alert_card.dart';
import 'package:sahayogseva/widgets/worker/metrics_summary_card.dart';
import 'package:sahayogseva/widgets/worker/worker_profile_header.dart';
import 'package:sahayogseva/widgets/language_selector_button.dart';
import 'package:sahayogseva/widgets/workspace_switcher_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

class _FakeWorkerJobApi extends WorkerJobApiService {
  @override
  Future<bool> acceptJob(String jobId) async => true;

  @override
  Future<bool> rejectJob(String jobId) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    LanguageProvider.skipNativeConnectivity = true;
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
  });

  group('Customer Dashboard UI & AI Assist Flow', () {
    testWidgets('customer dashboard displays all required cards and elements', (
      tester,
    ) async {
      await tester.pumpWidget(flowApp(initialRoute: '/home'));
      await tester.pumpAndSettle();

      // Top app bar branding
      expect(find.text('SahayogSeva'), findsWidgets);

      // Customer Greeting Header
      expect(find.byType(GreetingHeader), findsOneWidget);
      expect(find.textContaining('पूजा'), findsOneWidget);

      // AI Problem Card
      expect(find.byType(AiProblemCard), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsWidgets);

      // Popular Services Grid
      expect(find.byType(PopularServicesGrid), findsOneWidget);

      // Ongoing Booking Card with #BK12345
      expect(find.byType(OngoingBookingCard), findsOneWidget);
      expect(find.textContaining('#BK12345'), findsOneWidget);
      expect(find.textContaining('Sandeep Patil'), findsOneWidget);

      // Trust guarantee card & Promo banner
      expect(find.byType(TrustGuaranteeCard), findsOneWidget);
      expect(find.byType(PromoBannerCard), findsOneWidget);

      // Center Raised AI FAB
      expect(find.text('AI'), findsOneWidget);
    });

    testWidgets('tapping center AI FAB opens AiAssistSheet', (tester) async {
      await tester.pumpWidget(flowApp(initialRoute: '/home'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('AI'));
      await tester.pumpAndSettle();

      expect(find.byType(AiAssistSheet), findsOneWidget);
      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('top bar renders without overflow on narrow mobile screens (360px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(flowApp(initialRoute: '/home'));
      await tester.pumpAndSettle();

      expect(find.text('SahayogSeva'), findsOneWidget);
      expect(find.byType(LanguageSelectorButton), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });
  });

  group('Workspace Role Switching & Worker Dashboard Flow', () {
    testWidgets('switching from Customer to Worker role morphs dashboard shell', (
      tester,
    ) async {
      await tester.pumpWidget(flowApp(initialRoute: '/home'));
      await tester.pumpAndSettle();

      // Initially in Customer mode
      expect(find.byType(GreetingHeader), findsOneWidget);

      // Navigate to Customer Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Tap Switch Workspace tile
      await tester.tap(find.text('Switch Workspace'));
      await tester.pumpAndSettle();

      // Verify WorkspaceSwitcherSheet opened
      expect(find.byType(WorkspaceSwitcherSheet), findsOneWidget);
      expect(find.textContaining('Currently Active'), findsWidgets);

      // Select Worker role
      await tester.tap(find.byIcon(Icons.handyman).first);
      await tester.pumpAndSettle();

      // Tap Switch Context button
      await tester.tap(find.text('Switch Context'));
      await tester.pumpAndSettle();

      // Verify Worker Dashboard is now rendered
      expect(find.byType(WorkerProfileHeader), findsOneWidget);

      // Availability Status Card
      expect(find.byType(AvailabilityStatusCard), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      // Job request card is present (empty until backend jobs load)
      expect(find.byType(JobRequestAlertCard), findsOneWidget);
      expect(find.text('Accept'), findsNothing);

      // Today's Appointments Timeline Card
      expect(find.byType(AppointmentTimelineCard), findsOneWidget);

      // Metrics summary from backend (zero until completed jobs exist)
      await tester.ensureVisible(find.byType(MetricsSummaryCard));
      expect(find.byType(MetricsSummaryCard), findsOneWidget);
      expect(find.text('Availability'), findsNothing);
      expect(find.text('Job History'), findsNothing);
      expect(find.text('My Profile'), findsNothing);
    });

    testWidgets('worker can accept job request and toggle availability', (
      tester,
    ) async {
      final auth = AuthProvider();
      auth.setActiveRole(WorkspaceRoleId.worker);
      final dash = WorkerDashboardProvider(jobApi: _FakeWorkerJobApi());
      await dash.setAvailability(WorkerAvailability.online);
      dash.debugSetPendingRequests(const [
        JobRequestItem(
          id: 'job_test_1',
          title: 'Tap / Faucet Repair',
          category: 'Plumbing',
          location: 'Warje, Pune',
          distanceText: '',
          priceRange: '₹250',
          customerName: 'Test Customer',
        ),
      ]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider(create: (_) => CustomerDashboardProvider()),
            ChangeNotifierProvider<WorkerDashboardProvider>.value(value: dash),
            ChangeNotifierProvider(create: (_) => WorkerProfileProvider()),
          ],
          child: MaterialApp(
            home: const DashboardShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accept'), findsOneWidget);
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      // Request is accepted (removed from pending list)
      expect(find.text('Accept'), findsNothing);

      // Toggle availability switch
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Now offline status
      expect(find.text('Offline'), findsWidgets);
    });
  });
}
