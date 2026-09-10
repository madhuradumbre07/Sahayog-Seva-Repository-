import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'providers/auth_provider.dart';
import 'providers/customer_dashboard_provider.dart';
import 'providers/customer_problem_provider.dart';
import 'providers/language_provider.dart';
import 'providers/worker_dashboard_provider.dart';
import 'providers/matching_provider.dart';
import 'providers/booking_flow_provider.dart';
import 'providers/registration_provider.dart';
import 'screens/auth/language_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/workspace_screen.dart';
import 'screens/customer/customer_ai_analysis_screen.dart';
import 'screens/customer/customer_ai_result_screen.dart';
import 'screens/customer/customer_describe_problem_screen.dart';
import 'screens/customer/customer_matching_workers_screen.dart';
import 'screens/customer/customer_booking_confirmation_screen.dart';
import 'screens/customer/customer_track_service_screen.dart';
import 'screens/customer/customer_service_completion_screen.dart';
import 'screens/customer/customer_service_rating_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_colors.dart';
import 'providers/booking_tracking_provider.dart';
import 'providers/service_completion_provider.dart';
import 'providers/cooperative_dashboard_provider.dart';
import 'providers/worker_job_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/worker_profile_provider.dart';
import 'screens/cooperative/cooperative_dashboard_screen.dart';
import 'screens/worker/worker_new_job_request_screen.dart';
import 'screens/worker/worker_job_details_screen.dart';
import 'screens/worker/worker_job_response_result_screen.dart';
import 'screens/worker/worker_job_in_progress_screen.dart';
import 'screens/worker/worker_job_completion_summary_screen.dart';
import 'screens/worker/worker_registration_screen.dart';
import 'screens/admin/admin_worker_verification_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final languageProvider = LanguageProvider();
  final authProvider = AuthProvider();
  await languageProvider.init();
  await authProvider.loadPersisted();
  runApp(
    SahayogSevaApp(
      languageProvider: languageProvider,
      authProvider: authProvider,
    ),
  );
}

class SahayogSevaApp extends StatelessWidget {
  const SahayogSevaApp({
    super.key,
    this.languageProvider,
    this.authProvider,
  });

  final LanguageProvider? languageProvider;
  final AuthProvider? authProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (languageProvider != null)
          ChangeNotifierProvider<LanguageProvider>.value(
            value: languageProvider!,
          )
        else
          ChangeNotifierProvider(create: (_) => LanguageProvider()..init()),
        if (authProvider != null)
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider!)
        else
          ChangeNotifierProvider(create: (_) => AuthProvider()..loadPersisted()),
        ChangeNotifierProvider(create: (_) => CustomerDashboardProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProblemProvider()),
        ChangeNotifierProvider(create: (_) => WorkerDashboardProvider()),
        ChangeNotifierProvider(create: (_) => MatchingProvider()),
        ChangeNotifierProvider(create: (_) => BookingFlowProvider()),
        ChangeNotifierProvider(create: (_) => BookingTrackingProvider()),
        ChangeNotifierProvider(create: (_) => ServiceCompletionProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => WorkerJobProvider()),
        ChangeNotifierProvider(create: (_) => CooperativeDashboardProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProfileProvider()),
      ],
      child: Consumer2<LanguageProvider, AuthProvider>(
        builder: (context, language, auth, _) {
          final locale = language.locale;
          return MaterialApp(
            title: 'SahayogSeva',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('mr'),
              Locale('gu'),
              Locale('ta'),
              Locale('te'),
              Locale('kn'),
              Locale('bn'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (deviceLocale != null) {
                for (final supported in supportedLocales) {
                  if (supported.languageCode == deviceLocale.languageCode) {
                    return supported;
                  }
                }
              }
              return const Locale('en');
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                surface: AppColors.background,
              ),
              scaffoldBackgroundColor: AppColors.background,
              textTheme: GoogleFonts.poppinsTextTheme(),
              useMaterial3: true,
            ),
            builder: (context, child) {
              return AppLocaleScope(
                locale: locale,
                child: child ?? const SizedBox.shrink(),
              );
            },
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              LanguageSelectionScreen.routeName: (context) =>
                  const LanguageSelectionScreen(),
              OnboardingScreen.routeName: (context) => const OnboardingScreen(),
              LoginScreen.routeName: (context) => const LoginScreen(),
              OtpScreen.routeName: (context) => const OtpScreen(),
              WorkspaceScreen.routeName: (context) => const WorkspaceScreen(),
              RegistrationScreen.routeName: (context) => const RegistrationScreen(),
              HomeScreen.routeName: (context) => const HomeScreen(),
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
              CooperativeDashboardScreen.routeName: (context) =>
                  const CooperativeDashboardScreen(),
              WorkerRegistrationScreen.routeName: (context) =>
                  const WorkerRegistrationScreen(),
              AdminWorkerVerificationScreen.routeName: (context) =>
                  const AdminWorkerVerificationScreen(),
            },
          );
        },
      ),

    );
  }
}
