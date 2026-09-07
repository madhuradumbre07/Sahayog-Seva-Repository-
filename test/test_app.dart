import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahayogseva/l10n/l10n.dart';
import 'package:sahayogseva/providers/auth_provider.dart';
import 'package:sahayogseva/providers/customer_dashboard_provider.dart';
import 'package:sahayogseva/providers/customer_problem_provider.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/providers/worker_dashboard_provider.dart';
import 'package:sahayogseva/screens/auth/language_selection_screen.dart';
import 'package:sahayogseva/screens/auth/login_screen.dart';
import 'package:sahayogseva/screens/auth/onboarding_screen.dart';
import 'package:sahayogseva/screens/auth/otp_screen.dart';
import 'package:sahayogseva/screens/auth/workspace_screen.dart';
import 'package:sahayogseva/screens/customer/customer_ai_analysis_screen.dart';
import 'package:sahayogseva/screens/customer/customer_ai_result_screen.dart';
import 'package:sahayogseva/screens/customer/customer_describe_problem_screen.dart';
import 'package:sahayogseva/providers/matching_provider.dart';
import 'package:sahayogseva/providers/booking_flow_provider.dart';
import 'package:sahayogseva/screens/customer/customer_matching_workers_screen.dart';
import 'package:sahayogseva/screens/customer/customer_booking_confirmation_screen.dart';
import 'package:sahayogseva/screens/customer/customer_track_service_screen.dart';
import 'package:sahayogseva/screens/customer/customer_service_completion_screen.dart';
import 'package:sahayogseva/screens/customer/customer_service_rating_screen.dart';
import 'package:sahayogseva/providers/booking_tracking_provider.dart';
import 'package:sahayogseva/providers/service_completion_provider.dart';
import 'package:sahayogseva/providers/worker_job_provider.dart';
import 'package:sahayogseva/screens/worker/worker_new_job_request_screen.dart';
import 'package:sahayogseva/screens/worker/worker_job_details_screen.dart';
import 'package:sahayogseva/screens/worker/worker_job_response_result_screen.dart';
import 'package:sahayogseva/screens/worker/worker_job_in_progress_screen.dart';
import 'package:sahayogseva/screens/worker/worker_job_completion_summary_screen.dart';
import 'package:sahayogseva/screens/home/home_screen.dart';

Widget flowApp({
  String initialRoute = '/language-selection',
  String initialLocale = 'en',
  LanguageProvider? languageProvider,
  AuthProvider? authProvider,
  MatchingProvider? matchingProvider,
  BookingFlowProvider? bookingFlowProvider,
  BookingTrackingProvider? bookingTrackingProvider,
  ServiceCompletionProvider? serviceCompletionProvider,
  WorkerJobProvider? workerJobProvider,
}) {
  final langProv = languageProvider ?? LanguageProvider();
  if (languageProvider == null && initialLocale != 'mr') {
    langProv.setLanguage(initialLocale);
  }

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LanguageProvider>.value(value: langProv),
      if (authProvider != null)
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider)
      else
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => CustomerDashboardProvider()),
      ChangeNotifierProvider(create: (_) => CustomerProblemProvider()),
      ChangeNotifierProvider(create: (_) => WorkerDashboardProvider()),
      if (matchingProvider != null)
        ChangeNotifierProvider<MatchingProvider>.value(value: matchingProvider)
      else
        ChangeNotifierProvider(create: (_) => MatchingProvider()),
      if (bookingFlowProvider != null)
        ChangeNotifierProvider<BookingFlowProvider>.value(value: bookingFlowProvider)
      else
        ChangeNotifierProvider(create: (_) => BookingFlowProvider()),
      if (bookingTrackingProvider != null)
        ChangeNotifierProvider<BookingTrackingProvider>.value(value: bookingTrackingProvider)
      else
        ChangeNotifierProvider(create: (_) => BookingTrackingProvider()),
      if (serviceCompletionProvider != null)
        ChangeNotifierProvider<ServiceCompletionProvider>.value(value: serviceCompletionProvider)
      else
        ChangeNotifierProvider(create: (_) => ServiceCompletionProvider()),
      if (workerJobProvider != null)
        ChangeNotifierProvider<WorkerJobProvider>.value(value: workerJobProvider)
      else
        ChangeNotifierProvider(create: (_) => WorkerJobProvider()),
    ],
    child: MaterialApp(
      initialRoute: initialRoute,
      builder: (context, child) {
        final language = context.watch<LanguageProvider>();
        return AppLocaleScope(
          locale: language.locale,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routes: {
        '/language-selection': (context) => const LanguageSelectionScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/otp-verification': (context) => const OtpScreen(),
        '/workspace-selection': (context) => const WorkspaceScreen(),
        '/home': (context) => const HomeScreen(),
        '/customer/describe-problem': (context) =>
            const CustomerDescribeProblemScreen(),
        '/customer/ai-analysis': (context) => const CustomerAiAnalysisScreen(),
        '/customer/ai-result': (context) => const CustomerAiResultScreen(),
        '/customer/matching-workers': (context) =>
            const CustomerMatchingWorkersScreen(),
        '/customer/booking-confirmation': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return CustomerBookingConfirmationScreen(booking: args as dynamic);
        },
        '/customer/track-service': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return CustomerTrackServiceScreen(bookingId: args ?? 'SHS-842109');
        },
        '/customer/service-completion': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return CustomerServiceCompletionScreen(bookingId: args ?? 'SHS-842109');
        },
        '/customer/service-rating': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return CustomerServiceRatingScreen(bookingId: args ?? 'SHS-842109');
        },
        WorkerNewJobRequestScreen.routeName: (context) =>
            const WorkerNewJobRequestScreen(),
        WorkerJobDetailsScreen.routeName: (context) =>
            const WorkerJobDetailsScreen(),
        WorkerJobResponseResultScreen.routeName: (context) =>
          const WorkerJobResponseResultScreen(),
        WorkerJobNavigationScreen.routeName: (context) =>
          const WorkerJobNavigationScreen(),
        WorkerJobOtpVerifyScreen.routeName: (context) =>
          const WorkerJobOtpVerifyScreen(),
        WorkerJobInProgressScreen.routeName: (context) =>
          const WorkerJobInProgressScreen(),
        WorkerJobCompletionSummaryScreen.routeName: (context) =>
          const WorkerJobCompletionSummaryScreen(),
      },
    ),
  );
}


