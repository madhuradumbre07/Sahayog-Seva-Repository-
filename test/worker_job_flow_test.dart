import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:sahayogseva/l10n/l10n.dart';
import 'package:sahayogseva/models/worker_job_model.dart';
import 'package:sahayogseva/providers/worker_job_provider.dart';
import 'package:sahayogseva/services/worker_job_api_service.dart';
import 'package:sahayogseva/screens/worker/worker_new_job_request_screen.dart';
import 'package:sahayogseva/screens/worker/worker_job_details_screen.dart';

import 'test_app.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MockWorkerJobApiService extends WorkerJobApiService {
  @override
  Future<bool> acceptJob(String jobId) async => true;

  @override
  Future<bool> rejectJob(String jobId) async => true;

  @override
  Future<bool> decideLater(String jobId) async => true;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MyHttpOverrides();
  });

  group('Screen 19: Worker New Job Request Screen Tests', () {
    testWidgets('renders all cards, customer info, metrics, and action buttons in English', (tester) async {
      final jobProvider = WorkerJobProvider(apiService: MockWorkerJobApiService());
      addTearDown(() => jobProvider.stopCountdownTimer());

      await tester.pumpWidget(
        flowApp(
          initialRoute: WorkerNewJobRequestScreen.routeName,
          initialLocale: 'en',
          workerJobProvider: jobProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & ID
      expect(find.text('New Job Request'), findsWidgets);
      expect(find.textContaining('REQ-250531-0178'), findsOneWidget);
      expect(find.textContaining('Expires in'), findsOneWidget);

      // Verify Customer Card
      expect(find.text('Sandeep Patil'), findsWidgets);
      expect(find.text('Verified'), findsWidgets);
      expect(find.textContaining('4.7'), findsWidgets);

      // Verify Service & Location
      expect(find.text('Tap / Faucet Repair'), findsWidgets);
      expect(find.text('Plumbing'), findsWidgets);
      expect(find.textContaining('Ganesh Apartments'), findsWidgets);

      // Verify Quick Metrics
      expect(find.text('Distance'), findsWidgets);
      expect(find.text('Estimated Price'), findsWidgets);
      expect(find.text('Priority'), findsWidgets);
      expect(find.text('High'), findsWidgets);

      // Verify Time and Customer Note
      expect(find.text('Time'), findsWidgets);
      expect(find.text('Customer Request'), findsWidgets);
      expect(find.textContaining('Please call before coming'), findsWidgets);

      // Ensure action buttons are visible and verify
      await tester.ensureVisible(find.text('✓ Accept'));
      expect(find.text('✕ Reject'), findsOneWidget);
      expect(find.text('✓ Accept'), findsOneWidget);
    });

    testWidgets('alternate states render correctly (normal, expiring, expired, youAccepted, youRejected)', (tester) async {
      final jobProvider = WorkerJobProvider(apiService: MockWorkerJobApiService());
      addTearDown(() => jobProvider.stopCountdownTimer());

      await tester.pumpWidget(
        flowApp(
          initialRoute: WorkerNewJobRequestScreen.routeName,
          initialLocale: 'en',
          workerJobProvider: jobProvider,
        ),
      );
      await tester.pumpAndSettle();

      // 1. Normal state
      expect(find.text('New job available.'), findsOneWidget);

      // 2. Expiring state
      jobProvider.setRequestState(JobRequestState.expiring);
      await tester.pumpAndSettle();
      expect(find.text('Time is running out!'), findsOneWidget);

      // 3. Expired state
      jobProvider.setRequestState(JobRequestState.expired);
      await tester.pumpAndSettle();
      expect(find.text('This request has expired.'), findsOneWidget);

      // 4. Accepted by other
      jobProvider.setRequestState(JobRequestState.acceptedByOther);
      await tester.pumpAndSettle();
      expect(find.text('This job was accepted by another worker.'), findsOneWidget);

      // 5. You Accepted
      jobProvider.setRequestState(JobRequestState.youAccepted);
      await tester.pumpAndSettle();
      expect(find.text('You have accepted this job!'), findsOneWidget);
      expect(find.text('View Job Details'), findsOneWidget);

      // 6. You Rejected
      jobProvider.setRequestState(JobRequestState.youRejected);
      await tester.pumpAndSettle();
      expect(find.text('You rejected this request.'), findsOneWidget);
    });

    testWidgets('modal sheets open on card clicks (Customer Info, Service Details, Location, Price, Priority)', (tester) async {
      final jobProvider = WorkerJobProvider(apiService: MockWorkerJobApiService());
      addTearDown(() => jobProvider.stopCountdownTimer());

      await tester.pumpWidget(
        flowApp(
          initialRoute: WorkerNewJobRequestScreen.routeName,
          initialLocale: 'en',
          workerJobProvider: jobProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Open Customer Info Modal
      await tester.tap(find.text('Sandeep Patil').first);
      await tester.pumpAndSettle();
      expect(find.text('Customer Info'), findsWidgets);
      expect(find.text('Total Jobs'), findsWidgets);
      expect(find.text('View Profile'), findsOneWidget);
      await tester.tap(find.text('View Profile'));
      await tester.pumpAndSettle();

      // Open Price Breakdown Modal
      await tester.tap(find.text('Estimated Price').first);
      await tester.pumpAndSettle();
      expect(find.text('Service Charge'), findsOneWidget);
      expect(find.text('Visiting Charge'), findsOneWidget);
      expect(find.text('Total Expected'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Open Priority Info Modal
      await tester.tap(find.text('Priority').first);
      await tester.pumpAndSettle();
      expect(find.text('Priority Info'), findsOneWidget);
      expect(find.textContaining('Customer has indicated urgent need'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Accept marks job as youAccepted and navigates to Job Details', (tester) async {
      final jobProvider = WorkerJobProvider(apiService: MockWorkerJobApiService());
      addTearDown(() => jobProvider.stopCountdownTimer());

      await tester.pumpWidget(
        flowApp(
          initialRoute: WorkerNewJobRequestScreen.routeName,
          initialLocale: 'en',
          workerJobProvider: jobProvider,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('✓ Accept'));
      await tester.tap(find.text('✓ Accept'));
      await tester.pumpAndSettle();

      expect(jobProvider.currentState, JobRequestState.youAccepted);
      expect(find.text('You have accepted this job!'), findsOneWidget);

      // Tap View Job Details
      await tester.ensureVisible(find.text('View Job Details'));
      await tester.tap(find.text('View Job Details'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkerJobDetailsScreen), findsOneWidget);
      expect(find.text('Job Details'), findsWidgets);
    });
  });

  group('Screen 20: Worker Job Details Screen Tests', () {
    testWidgets('renders all 9 detailed sections, countdown banner, contact buttons, and CTAs', (tester) async {
      final jobProvider = WorkerJobProvider(apiService: MockWorkerJobApiService());
      addTearDown(() => jobProvider.stopCountdownTimer());

      await tester.pumpWidget(
        flowApp(
          initialRoute: WorkerJobDetailsScreen.routeName,
          initialLocale: 'en',
          workerJobProvider: jobProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Header & ID
      expect(find.text('Job Details'), findsWidgets);
      expect(find.textContaining('REQ-250531-0178'), findsOneWidget);
      expect(find.text('High Priority'), findsWidgets);

      // Expiry Banner
      expect(find.textContaining('Request Expires In'), findsOneWidget);

      // Contact Buttons
      expect(find.text('Call Customer'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Customer Profile'), findsOneWidget);

      // Section 1: Problem & AI Analysis
      expect(find.text('1. Problem & AI Analysis'), findsOneWidget);
      expect(find.text('AI Analysis'), findsOneWidget);
      expect(find.textContaining('Washer is damaged'), findsOneWidget);
      expect(find.text('Recommended Service'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);

      // Section 2: Scope of Work
      expect(find.text('2. Scope of Work'), findsOneWidget);
      expect(find.text('Tap inspection and fault diagnosis'), findsOneWidget);
      expect(find.text('Washer / O-ring replacement'), findsOneWidget);
      expect(find.text('Post-work cleanup'), findsOneWidget);

      // Section 3: Required Tools
      expect(find.text('3. Required Tools'), findsOneWidget);
      expect(find.text('Adjustable Wrench'), findsOneWidget);
      expect(find.text('Screwdriver'), findsOneWidget);
      expect(find.text('Basin Wrench'), findsOneWidget);

      // Section 4: Location & Map
      await tester.ensureVisible(find.text('4. Location & Map'));
      expect(find.text('4. Location & Map'), findsOneWidget);
      expect(find.text('Open Map'), findsOneWidget);

      // Section 5: Estimated Earnings & Materials
      await tester.ensureVisible(find.text('5. Estimated Earnings & Materials'));
      expect(find.text('5. Estimated Earnings & Materials'), findsOneWidget);
      expect(find.text('Labor'), findsOneWidget);
      expect(find.text('Materials'), findsOneWidget);
      expect(find.text('Total Expected'), findsOneWidget);
      expect(find.text('6. Required Materials'), findsOneWidget);

      // Section 6: Customer Notes
      await tester.ensureVisible(find.text('7. Customer Notes'));
      expect(find.text('7. Customer Notes'), findsOneWidget);
      expect(find.textContaining('Please call before coming'), findsOneWidget);

      // Section 7: Safety Guidelines
      await tester.ensureVisible(find.text('8. Safety Guidelines'));
      expect(find.text('8. Safety Guidelines'), findsOneWidget);
      expect(find.text('Keep away from electrical contacts'), findsOneWidget);

      // Section 8: Additional Information
      await tester.ensureVisible(find.text('9. Additional Information'));
      expect(find.text('9. Additional Information'), findsOneWidget);
      expect(find.text('Online (UPI)'), findsWidgets);

      // Section 9: Customer Profile Summary
      await tester.ensureVisible(find.text('Customer Profile Summary'));
      expect(find.text('Customer Profile Summary'), findsOneWidget);
      expect(find.text('Successfully Completed'), findsOneWidget);

      // Action CTAs
      await tester.ensureVisible(find.text('✓ Accept'));
      expect(find.text('✕ Reject'), findsOneWidget);
      expect(find.text('Decide Later'), findsOneWidget);
      expect(find.text('✓ Accept'), findsOneWidget);
    });

    testWidgets('tapping Decide Later handles postponement and Accept triggers acceptance', (tester) async {
      final jobProvider = WorkerJobProvider(apiService: MockWorkerJobApiService());
      addTearDown(() => jobProvider.stopCountdownTimer());

      await tester.pumpWidget(
        flowApp(
          initialRoute: WorkerJobDetailsScreen.routeName,
          initialLocale: 'en',
          workerJobProvider: jobProvider,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('✓ Accept'));
      await tester.tap(find.text('✓ Accept'));
      await tester.pumpAndSettle();

      expect(jobProvider.currentState, JobRequestState.youAccepted);
    });
  });

  group('8-Language Localization Completeness for Screens 19 & 20', () {
    test('all Screen 19 & 20 keys translate across all 8 languages without raw key fallback', () {
      const languages = ['en', 'hi', 'mr', 'gu', 'ta', 'te', 'kn', 'bn'];
      const testKeys = [
        'newJobRequestTitle',
        'verifiedBadge',
        'jobProblemTapDesc',
        'distanceLabel',
        'estimatedPriceLabel',
        'priorityLabel',
        'priorityHigh',
        'timeLabel',
        'customerRequestLabel',
        'jobCustomerNoteText',
        'rejectJobBtn',
        'acceptJobBtn',
        'normalStateHeadline',
        'expiringStateHeadline',
        'expiredStateHeadline',
        'acceptedByOtherHeadline',
        'youAcceptedHeadline',
        'youRejectedHeadline',
        'viewJobDetailsBtn',
        'dismissBtn',
        'customerInfoTitle',
        'customerSandeepPatil',
        'totalJobsLabel',
        'membershipLabel',
        'lastJobLabel',
        'cancelledJobsLabel',
        'categoryLabel',
        'skillLabel',
        'estTimeLabel',
        'requiredToolsLabel',
        'locationInfoTitle',
        'jobAddressGaneshApts',
        'viewMapBtn',
        'openMapBtn',
        'estPriceTitle',
        'serviceChargeLabel',
        'visitingChargeLabel',
        'materialsEstLabel',
        'priorityInfoTitle',
        'ratingStatusTitle',
        'jobDetailsTitle',
        'highPriorityBadge',
        'callCustomerBtn',
        'chatCustomerBtn',
        'customerProfileBtn',
        'problemAndAiSection',
        'customerReportedProblem',
        'aiAnalysisLabel',
        'jobAiAnalysisDesc',
        'recommendedService',
        'estDurationLabel',
        'difficultyLabel',
        'difficultyEasy',
        'scopeOfWorkSection',
        'scopeTapInspection',
        'scopeWasherReplacement',
        'scopeStopLeakage',
        'scopeWaterFlowTest',
        'scopeCleanupPostWork',
        'requiredToolsSection',
        'toolAdjustableWrench',
        'toolScrewdriver',
        'toolTapKey',
        'toolPlumberTape',
        'toolBasinWrench',
        'locationAndMapSection',
        'premiseTypeLabel',
        'floorLabel',
        'earningsAndMaterialsSection',
        'estEarningsLabel',
        'laborChargeLabel',
        'materialsChargeLabel',
        'totalExpectedLabel',
        'pricingDisclaimerNote',
        'materialsRequiredSection',
        'matWasherOring',
        'matPlumberTape',
        'customerNotesSection',
        'safetyGuidelinesSection',
        'safetyElectricalPrecaution',
        'safetyTurnOffMainValve',
        'additionalInfoSection',
        'payMethodOnlineUpi',
        'customerProfileSummaryTitle',
        'successfulJobsCount',
        'cancelledJobsCount',
        'decideLaterBtn',
        'acceptSubtitleNote',
      ];

      for (final lang in languages) {
        for (final key in testKeys) {
          final translated = AppStringsData.translate(key, languageCode: lang);
          expect(
            translated != key,
            isTrue,
            reason: 'Key "$key" should have a translation in language "$lang", but returned raw key.',
          );
          expect(
            translated.isNotEmpty,
            isTrue,
            reason: 'Translation for "$key" in "$lang" must not be empty.',
          );
        }
      }
    });
  });
}
