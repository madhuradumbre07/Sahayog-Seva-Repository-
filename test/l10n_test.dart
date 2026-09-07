import 'package:sahayogseva/main.dart';
import 'package:sahayogseva/widgets/customer/ongoing_booking_card.dart';
import 'package:sahayogseva/providers/customer_dashboard_provider.dart';
import 'package:sahayogseva/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sahayogseva/l10n/app_strings.dart';
import 'package:sahayogseva/l10n/auth_strings.dart';
import 'package:sahayogseva/l10n/l10n.dart';
import 'package:sahayogseva/models/workspace_role.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const supportedLanguages = [
  'en',
  'hi',
  'mr',
  'gu',
  'ta',
  'te',
  'kn',
  'bn',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    LanguageProvider.skipNativeConnectivity = true;
    SharedPreferences.setMockInitialValues({});
  });

  group('Localization Architecture & Dictionary Completeness', () {

    test('all 8 languages exist in appStrings and authStrings', () {
      for (final lang in supportedLanguages) {
        expect(
          appStrings.containsKey(lang),
          isTrue,
          reason: 'appStrings missing $lang',
        );
        expect(
          authStrings.containsKey(lang),
          isTrue,
          reason: 'authStrings missing $lang',
        );
      }
    });

    test('all English keys exist in all other 7 languages for appStrings', () {
      final enKeys = appStrings['en']!.keys;
      for (final lang in supportedLanguages) {
        if (lang == 'en') continue;
        for (final key in enKeys) {
          expect(
            appStrings[lang]!.containsKey(key),
            isTrue,
            reason: 'Missing key "$key" in appStrings for "$lang"',
          );
          expect(
            appStrings[lang]![key]!.trim(),
            isNotEmpty,
            reason: 'Empty translation for "$key" in appStrings for "$lang"',
          );
        }
      }
    });

    test('all English keys exist in all other 7 languages for authStrings', () {
      final enKeys = authStrings['en']!.keys;
      for (final lang in supportedLanguages) {
        if (lang == 'en') continue;
        for (final key in enKeys) {
          expect(
            authStrings[lang]!.containsKey(key),
            isTrue,
            reason: 'Missing key "$key" in authStrings for "$lang"',
          );
          expect(
            authStrings[lang]![key]!.trim(),
            isNotEmpty,
            reason: 'Empty translation for "$key" in authStrings for "$lang"',
          );
        }
      }
    });

    test('AppStringsData translates keys correctly in all languages', () {
      expect(
        AppStringsData.translate('appName', languageCode: 'en'),
        'SahayogSeva',
      );
      expect(
        AppStringsData.translate('appName', languageCode: 'hi'),
        'सहयोगसेवा',
      );
      expect(
        AppStringsData.translate('appName', languageCode: 'mr'),
        'सहयोगसेवा',
      );
      expect(
        AppStringsData.translate('appName', languageCode: 'gu'),
        'સહયોગસેવા',
      );
      expect(
        AppStringsData.translate('appName', languageCode: 'ta'),
        'சஹயோக்சேவா',
      );
      expect(
        AppStringsData.translate('appName', languageCode: 'te'),
        'సహయోగ్‌సేవా',
      );
      expect(
        AppStringsData.translate('appName', languageCode: 'kn'),
        'ಸಹಯೋಗಸೇವಾ',
      );
      expect(
        AppStringsData.translate('appName', languageCode: 'bn'),
        'সহযোগসেবা',
      );
    });

    test('parameter replacement works properly', () {
      final enSent = AppStringsData.translate(
        'otpSentTo',
        languageCode: 'en',
        params: {'phone': '+91 98765 43210'},
      );
      expect(enSent, 'We have sent a 6-digit OTP to +91 98765 43210.');

      final hiSent = AppStringsData.translate(
        'otpSentTo',
        languageCode: 'hi',
        params: {'phone': '+91 98765 43210'},
      );
      expect(hiSent, 'हमने +91 98765 43210 पर 6 अंकों का OTP भेजा है।');
    });

    test('fallback works for missing keys and unknown languages', () {
      expect(
        AppStringsData.translate('nonExistentKey', languageCode: 'en'),
        'nonExistentKey',
      );
      expect(
        AppStringsData.translate(
          'nonExistentKey',
          languageCode: 'unknown',
          fallback: 'Custom Fallback',
        ),
        'Custom Fallback',
      );
    });

    test('English locale defaults contain all required keys for all screens', () {
      final requiredKeys = [
        'onboardTitle1', 'onboardBody1', 'onboardTitle2', 'onboardBody2', 'onboardTitle3', 'onboardBody3',
        'welcomeTitle', 'welcomeTagline', 'phoneHint', 'orContinueWith', 'continueWithGoogle',
        'termsDisclaimer', 'invalidNumber', 'googleSigningIn', 'tooManyAttempts', 'tryAgainIn',
        'verifyNumber', 'changeNumber', 'enterOtp', 'didntGetOtp', 'resendOtpIn', 'resendAvailableAfter',
        'chooseWorkspace', 'chooseWorkspaceSubtitle', 'selectWorkspaceError',
        'roleCustomer', 'roleCustomerDesc', 'roleWorker', 'roleWorkerDesc',
        'roleCoop', 'roleCoopDesc', 'roleContractor', 'roleContractorDesc',
        'servicePlumber', 'serviceElectrician', 'serviceCleaning', 'serviceAppliance', 'servicePainting',
        'describeProblemAI', 'describeProblemAi', 'popularServices', 'myBookings', 'todayEarnings',
      ];

      for (final key in requiredKeys) {
        final val = AppStringsData.translate(key, languageCode: 'en');
        expect(val, isNotEmpty, reason: 'Key $key returned empty string');
        expect(val, isNot(equals(key)), reason: 'Key $key was not resolved in English defaults');
      }
    });

    test('Key alias resolution works for casing and legacy differences', () {
      // describeProblemAI vs describeProblemAi
      expect(
        AppStringsData.translate('describeProblemAI', languageCode: 'en'),
        'Describe Problem (AI)',
      );
      expect(
        AppStringsData.translate('describeProblemAi', languageCode: 'en'),
        'Describe Problem (AI)',
      );

      // roleCooperative vs roleCoop
      expect(
        AppStringsData.translate('roleCooperative', languageCode: 'en'),
        'Cooperative Admin',
      );
      expect(
        AppStringsData.translate('roleCooperativeDesc', languageCode: 'en'),
        'Manage members, dispatch workers and operations.',
      );

      // servicePlumbing vs servicePlumber
      expect(
        AppStringsData.translate('servicePlumbing', languageCode: 'en'),
        'Plumbing',
      );
    });

    test('Secondary language missing key automatically falls back to English', () {
      // In a hypothetical scenario where a key only exists in English:
      final fallbackToEn = AppStringsData.translate(
        'securityBadge',
        languageCode: 'mr',
      );
      expect(fallbackToEn, isNotEmpty);
      expect(fallbackToEn, isNot(equals('securityBadge')));
    });
  });

  group('Reactive UI & context.tr Extension', () {
    testWidgets('context.tr reacts immediately when AppLocaleScope locale changes', (
      tester,
    ) async {
      final languageProvider = LanguageProvider();

      Widget testWidget() {
        return ChangeNotifierProvider<LanguageProvider>.value(
          value: languageProvider,
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return AppLocaleScope(
                locale: lang.locale,
                child: MaterialApp(
                  home: Builder(
                    builder: (context) {
                      return Scaffold(
                        body: Column(
                          children: [
                            Text(context.tr('chooseLanguage')),
                            Text(context.tr('loginTitle')),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      }

      await tester.pumpWidget(testWidget());

      // Initial English
      expect(find.text('Choose Your Language'), findsOneWidget);
      expect(find.text('Login / Register'), findsOneWidget);

      // Switch to Hindi
      await languageProvider.setLanguage('hi');
      await tester.pumpAndSettle();

      expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
      expect(find.text('लॉगिन / रजिस्टर'), findsOneWidget);

      // Switch to Marathi
      await languageProvider.setLanguage('mr');
      await tester.pumpAndSettle();

      expect(find.text('आपली भाषा निवडा'), findsOneWidget);
      expect(find.text('लॉगिन / नोंदणी'), findsOneWidget);

      // Switch to Gujarati
      await languageProvider.setLanguage('gu');
      await tester.pumpAndSettle();

      expect(find.text('તમારી ભાષા પસંદ કરો'), findsOneWidget);
      expect(find.text('લોગિન / નોંધણી'), findsOneWidget);

      // Switch to Tamil
      await languageProvider.setLanguage('ta');
      await tester.pumpAndSettle();

      expect(find.text('உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்'), findsOneWidget);
      expect(find.text('உள்நுழை / பதிவு'), findsOneWidget);

      // Switch to Telugu
      await languageProvider.setLanguage('te');
      await tester.pumpAndSettle();

      expect(find.text('మీ భాషను ఎంచుకోండి'), findsOneWidget);
      expect(find.text('లాగిన్ / నమోదు'), findsOneWidget);

      // Switch to Kannada
      await languageProvider.setLanguage('kn');
      await tester.pumpAndSettle();

      expect(find.text('ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ'), findsOneWidget);
      expect(find.text('ಲಾಗಿನ್ / ನೋಂದಣಿ'), findsOneWidget);

      // Switch to Bengali
      await languageProvider.setLanguage('bn');
      await tester.pumpAndSettle();

      expect(find.text('আপনার ভাষা বেছে নিন'), findsOneWidget);
      expect(find.text('লগইন / নিবন্ধন'), findsOneWidget);
    });


    test('Promo and Trust keys exist and translate in all 8 languages without raw key fallback', () {
      final keys = [
        'firstBookingPromoTitle',
        'firstBookingPromoDesc',
        'trustVerifiedWorkers',
        'trustFairPricing',
        'trustOnTime',
        'trustSecurePay',
      ];
      for (final lang in supportedLanguages) {
        for (final k in keys) {
          final res = AppStringsData.translate(k, languageCode: lang);
          expect(res, isNot(equals(k)), reason: 'Raw key $k returned for language $lang');
          expect(res.trim(), isNotEmpty);
        }
      }

      // Specific language checks
      expect(AppStringsData.translate('firstBookingPromoTitle', languageCode: 'mr'), 'पहिली बुकिंग ऑफर');
      expect(AppStringsData.translate('firstBookingPromoDesc', languageCode: 'mr'), 'आजच 10% सूट मिळवा!');
      expect(AppStringsData.translate('trustVerifiedWorkers', languageCode: 'mr'), 'पडताळलेले कामगार');
      expect(AppStringsData.translate('trustFairPricing', languageCode: 'mr'), 'योग्य आणि पारदर्शक दर');
      expect(AppStringsData.translate('trustOnTime', languageCode: 'mr'), 'वेळेवर सेवा');
      expect(AppStringsData.translate('trustSecurePay', languageCode: 'mr'), 'सुरक्षित पेमेंट');

      expect(AppStringsData.translate('firstBookingPromoTitle', languageCode: 'en'), 'First Booking Offer');
      expect(AppStringsData.translate('trustVerifiedWorkers', languageCode: 'en'), 'Verified Workers');
    });

    testWidgets('dynamic user greeting updates prefix according to locale while preserving name', (
      tester,
    ) async {
      final languageProvider = LanguageProvider();

      Widget testWidget() {
        return ChangeNotifierProvider<LanguageProvider>.value(
          value: languageProvider,
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return AppLocaleScope(
                locale: lang.locale,
                child: MaterialApp(
                  home: Builder(
                    builder: (context) {
                      const userName = 'पूजा देशमुख';
                      return Scaffold(
                        body: Column(
                          children: [
                            Text(context.tr('greetingCustomer', params: {'name': userName})),
                            Text(AppStrings.of(context).greeting(userName)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      }

      await tester.pumpWidget(testWidget());

      // English
      expect(find.text('Hello, पूजा देशमुख!'), findsNWidgets(2));

      // Marathi
      await languageProvider.setLanguage('mr');
      await tester.pumpAndSettle();
      expect(find.text('नमस्कार, पूजा देशमुख!'), findsNWidgets(2));

      // Hindi
      await languageProvider.setLanguage('hi');
      await tester.pumpAndSettle();
      expect(find.text('नमस्ते, पूजा देशमुख!'), findsNWidgets(2));
    });

    testWidgets('WorkspaceRole translates dynamically with context', (
      tester,
    ) async {
      final languageProvider = LanguageProvider();

      Widget testWidget() {
        return ChangeNotifierProvider<LanguageProvider>.value(
          value: languageProvider,
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return AppLocaleScope(
                locale: lang.locale,
                child: MaterialApp(
                  home: Builder(
                    builder: (context) {
                      final customer = WorkspaceRole.all.first;
                      return Scaffold(
                        body: Column(
                          children: [
                            Text(customer.title(context)),
                            Text(customer.desc(context)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      }

      await tester.pumpWidget(testWidget());

      // English
      expect(find.text('Customer'), findsOneWidget);
      expect(
        find.text('Book services, manage household needs.'),
        findsOneWidget,
      );

      // Hindi
      await languageProvider.setLanguage('hi');
      await tester.pumpAndSettle();

      expect(find.text('ग्राहक'), findsOneWidget);
      expect(
        find.text('सेवाएँ बुक करें, घरेलू ज़रूरतें प्रबंधित करें।'),
        findsOneWidget,
      );
    });

    testWidgets('OngoingBookingCard dynamically translates dateLabel across languages without hardcoded दिनांक', (
      tester,
    ) async {
      final languageProvider = LanguageProvider();
      final dashboardProvider = CustomerDashboardProvider();

      Widget testWidget() {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
            ChangeNotifierProvider<CustomerDashboardProvider>.value(value: dashboardProvider),
          ],
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return AppLocaleScope(
                locale: lang.locale,
                child: const MaterialApp(
                  home: Scaffold(
                    body: OngoingBookingCard(),
                  ),
                ),
              );
            },
          ),
        );
      }

      await tester.pumpWidget(testWidget());

      // English
      expect(find.textContaining('Date:'), findsOneWidget);
      expect(find.textContaining('दिनांक:'), findsNothing);

      // Marathi
      await languageProvider.setLanguage('mr');
      await tester.pumpAndSettle();
      expect(find.textContaining('दिनांक:'), findsOneWidget);

      // Gujarati
      await languageProvider.setLanguage('gu');
      await tester.pumpAndSettle();
      expect(find.textContaining('તારીખ:'), findsOneWidget);
    });

    testWidgets('SahayogSevaApp root switches all 8 languages without localization exceptions or crash', (
      tester,
    ) async {
      final languageProvider = LanguageProvider();
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        SahayogSevaApp(
          languageProvider: languageProvider,
          authProvider: authProvider,
        ),
      );
      await tester.pumpAndSettle();

      for (final code in supportedLanguages) {
        await languageProvider.setLanguage(code);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Language $code threw an exception');
      }
    });

  });
}
