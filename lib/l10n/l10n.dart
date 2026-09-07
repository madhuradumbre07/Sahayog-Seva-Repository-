import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import 'app_strings.dart';
import 'auth_strings.dart';

/// Combined translation dictionaries across all domains and 8 supported languages.
class AppStringsData {
  static const fallbackLanguage = 'en';

  static final Map<String, Map<String, String>> _mergedStrings = _buildMerged();

  static const Map<String, List<String>> _keyAliases = {
    'describeProblemAI': ['describeProblemAi', 'describeProblemTitle'],
    'describeProblemAi': ['describeProblemAI', 'describeProblemTitle'],
    'describeProblemTitle': ['describeProblemAi', 'describeProblemAI'],
    'roleCoop': ['roleCooperative'],
    'roleCooperative': ['roleCoop'],
    'roleCoopDesc': ['roleCooperativeDesc', 'roleCooperativeDescLong'],
    'roleCooperativeDesc': ['roleCoopDesc', 'roleCooperativeDescLong'],
    'roleCoopFeatures': ['roleCooperativeFeatures'],
    'roleCooperativeFeatures': ['roleCoopFeatures'],
    'roleInfoCoop': ['roleInfoCooperative'],
    'roleInfoCooperative': ['roleInfoCoop'],
    'servicePlumber': ['servicePlumbing'],
    'servicePlumbing': ['servicePlumber'],
    'navJobs': ['navAppointments'],
    'navAppointments': ['navJobs'],
    'viewAll': ['viewAllServices'],
    'viewAllServices': ['viewAll'],
  };

  static Map<String, Map<String, String>> _buildMerged() {
    final result = <String, Map<String, String>>{};
    const allLanguages = ['en', 'hi', 'mr', 'gu', 'ta', 'te', 'kn', 'bn'];
    for (final lang in allLanguages) {
      result[lang] = {
        ...?appStrings[lang],
        ...?authStrings[lang],
      };
    }
    return result;
  }

  static String? _lookup(String langCode, String key) {
    final direct = _mergedStrings[langCode]?[key];
    if (direct != null && direct.isNotEmpty) return direct;

    final aliases = _keyAliases[key];
    if (aliases != null) {
      for (final alias in aliases) {
        final aliasVal = _mergedStrings[langCode]?[alias];
        if (aliasVal != null && aliasVal.isNotEmpty) return aliasVal;
      }
    }
    return null;
  }

  static String translate(
    String key, {
    String? languageCode,
    Map<String, String>? params,
    String? fallback,
  }) {
    final code = languageCode ?? fallbackLanguage;

    // 1. Direct or alias in target language
    var value = _lookup(code, key);

    // 2. Automatic Fallback to English (if requested language is secondary and key is missing)
    if (value == null && code != fallbackLanguage) {
      value = _lookup(fallbackLanguage, key);
    }

    // 3. Fallback parameter or raw key
    value ??= (fallback != null && fallback.isNotEmpty) ? fallback : key;

    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, paramVal) {
        value = value!.replaceAll('{$paramKey}', paramVal);
      });
    }
    return value!;
  }

  static Map<String, String> forLanguage(String? code) {
    return _mergedStrings[code ?? fallbackLanguage] ??
        _mergedStrings[fallbackLanguage]!;
  }
}

/// Reactive InheritedWidget root provider that propagates the current [Locale]
/// down the widget tree so that all `context.tr('key')` calls automatically rebuild on locale change.
class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.locale,
    required super.child,
  });

  final Locale locale;

  static Locale? maybeOf(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<AppLocaleScope>()?.locale;
    }
    return context.getInheritedWidgetOfExactType<AppLocaleScope>()?.locale;
  }

  static Locale of(BuildContext context, {bool listen = true}) {
    final loc = maybeOf(context, listen: listen);
    if (loc != null) return loc;
    final provider = Provider.of<LanguageProvider>(context, listen: listen);
    return provider.locale;
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) =>
      oldWidget.locale != locale;
}

/// Backward compatibility alias for [AppLocaleScope].
typedef L10nScope = AppLocaleScope;

/// Main translation extension on [BuildContext].
extension LocalizationExtension on BuildContext {
  /// Translate a [key] into the current locale's string, replacing optional [params].
  String tr(String key, {Map<String, String>? params, String? fallback}) {
    String? langCode;
    final scope = dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    if (scope != null) {
      langCode = scope.locale.languageCode;
    } else {
      try {
        final provider = Provider.of<LanguageProvider>(this, listen: true);
        langCode = provider.locale.languageCode;
      } catch (_) {
        langCode = AppStringsData.fallbackLanguage;
      }
    }

    return AppStringsData.translate(
      key,
      languageCode: langCode,
      params: params,
      fallback: fallback,
    );
  }
}

/// Localized formatting utility for dates, times, distances, and prices.
class AppFormatters {
  static String formatDate(DateTime date, Locale locale) {
    try {
      return DateFormat.yMMMd(locale.languageCode).format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static String formatTime(DateTime time, Locale locale) {
    try {
      return DateFormat.jm(locale.languageCode).format(time);
    } catch (_) {
      final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
      final period = time.hour >= 12 ? 'PM' : 'AM';
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    }
  }

  static String formatDistance(double km, BuildContext context) {
    return context.tr('awayDistance', params: {'dist': km.toStringAsFixed(1)});
  }

  static String formatPrice(num amount, BuildContext context) {
    return context.tr('priceAmount', params: {'amount': amount.toString()});
  }

  static String formatPriceRange(num min, num max, BuildContext context) {
    return context.tr('priceRangeAmount', params: {'min': min.toString(), 'max': max.toString()});
  }

  static String formatRelativeDays(int daysAhead, BuildContext context, DateTime date) {
    if (daysAhead == 0) {
      return context.tr('todayLabel');
    } else if (daysAhead == 1) {
      return context.tr('tomorrowLabel');
    }
    return '${date.day}/${date.month}';
  }

  static String formatEtaMinutes(int minutes, BuildContext context) {
    return context.tr('etaMinutesAway', params: {'minutes': minutes.toString()});
  }

  static String formatDateTime(DateTime date, Locale locale) {
    final d = formatDate(date, locale);
    final t = formatTime(date, locale);
    return '$d, $t';
  }
}

/// Wrapper class for accessing typed getters or direct dictionary.
class AppStrings {
  const AppStrings(this.languageCode);

  final String languageCode;

  String tr(String key, {Map<String, String>? params}) =>
      AppStringsData.translate(key, languageCode: languageCode, params: params);

  String get appName => tr('appName');
  String get brandName => tr('brandName');
  String get taglineLine1 => tr('taglineLine1');
  String get taglineLine2 => tr('taglineLine2');
  String get taglineFull => '${tr('taglineLine1')} ${tr('taglineLine2')}';
  String get chooseLanguage => tr('chooseLanguage');
  String get chooseLanguageSubtitle => tr('chooseLanguageSubtitle');
  String get continueLabel => tr('continueLabel');
  String get settingLanguage => tr('settingLanguage');
  String get pleaseWait => tr('pleaseWait');
  String get selectLanguageError => tr('selectLanguageError');
  String get noInternetTitle => tr('noInternetTitle');
  String get noInternetBody => tr('noInternetBody');
  String get tryAgain => tr('tryAgain');
  String get skip => tr('skip');
  String get next => tr('next');
  String get getStarted => tr('getStarted');
  String get loginTitle => tr('loginTitle');
  String get loginSubtitle => tr('loginSubtitle');
  String get welcomeTitle => tr('welcomeTitle');
  String get welcomeTagline => tr('welcomeTagline');
  String get phoneHint => tr('phoneHint');
  String get sendOtp => tr('sendOtp');
  String get orContinueWith => tr('orContinueWith');
  String get continueWithGoogle => tr('continueWithGoogle');
  String get termsDisclaimer => tr('termsDisclaimer');
  String get invalidNumber => tr('invalidNumber');
  String get googleSigningIn => tr('googleSigningIn');
  String get tooManyAttempts => tr('tooManyAttempts');
  String get tryAgainIn => tr('tryAgainIn');
  String get verifyNumber => tr('verifyNumber');
  String otpSentTo(String phone) => tr('otpSentTo', params: {'phone': phone});
  String get changeNumber => tr('changeNumber');
  String get enterOtp => tr('enterOtp');
  String get didntGetOtp => tr('didntGetOtp');
  String get resendOtp => tr('resendOtp');
  String resendOtpIn(String time) => tr('resendOtpIn', params: {'time': time});
  String resendAvailableAfter(String time) =>
      tr('resendAvailableAfter', params: {'time': time});
  String get verifyOtp => tr('verifyOtp');
  String get verifyingOtp => tr('verifyingOtp');
  String get invalidOtp => tr('invalidOtp');
  String get otpExpired => tr('otpExpired');
  String get digitsOnly => tr('digitsOnly');
  String get success => tr('success');
  String get redirecting => tr('redirecting');
  String get contactUs => tr('contactUs');
  String get securityBadge => tr('securityBadge');
  String get chooseWorkspace => tr('chooseWorkspace');
  String get chooseWorkspaceSubtitle => tr('chooseWorkspaceSubtitle');
  String get changeLater => tr('changeLater');
  String get dataSecure => tr('dataSecure');
  String get roleCustomer => tr('roleCustomer');
  String get roleCustomerDesc => tr('roleCustomerDesc');
  String get roleCustomerFeatures => tr('roleCustomerFeatures');
  String get roleWorker => tr('roleWorker');
  String get roleWorkerDesc => tr('roleWorkerDesc');
  String get roleWorkerFeatures => tr('roleWorkerFeatures');
  String get roleCoop => tr('roleCoop');
  String get roleCoopDesc => tr('roleCoopDesc');
  String get roleCoopFeatures => tr('roleCoopFeatures');
  String get roleContractor => tr('roleContractor');
  String get roleContractorDesc => tr('roleContractorDesc');
  String get roleContractorFeatures => tr('roleContractorFeatures');
  String get verificationRequired => tr('verificationRequired');
  String get gotIt => tr('gotIt');
  String get homeTitle => tr('homeTitle');
  String get selectWorkspaceError => tr('selectWorkspaceError');
  String get roleInfoCustomer => tr('roleInfoCustomer');
  String get roleInfoWorker => tr('roleInfoWorker');
  String get roleInfoCoop => tr('roleInfoCoop');
  String get roleInfoContractor => tr('roleInfoContractor');
  String get onboardTitle1 => tr('onboardTitle1');
  String get onboardBody1 => tr('onboardBody1');
  String get onboardTitle2 => tr('onboardTitle2');
  String get onboardBody2 => tr('onboardBody2');
  String get onboardTitle3 => tr('onboardTitle3');
  String get onboardBody3 => tr('onboardBody3');
  String get describeProblemAI => tr('describeProblemAI');
  String get describeProblemAi => tr('describeProblemAi');
  String get servicePlumber => tr('servicePlumber');
  String get serviceElectrician => tr('serviceElectrician');
  String get serviceCleaning => tr('serviceCleaning');
  String get serviceAppliance => tr('serviceAppliance');
  String get servicePainting => tr('servicePainting');
  String get allServicesCatalog => tr('allServicesCatalog');
  String get popularServices => tr('popularServices');
  String get myBookings => tr('myBookings');
  String get todayEarnings => tr('todayEarnings');
  String get firstBookingPromoTitle => tr('firstBookingPromoTitle');
  String get firstBookingPromoDesc => tr('firstBookingPromoDesc');
  String get trustVerifiedWorkers => tr('trustVerifiedWorkers');
  String get trustFairPricing => tr('trustFairPricing');
  String get trustOnTime => tr('trustOnTime');
  String get trustSecurePay => tr('trustSecurePay');
  String get whyTrustUs => tr('whyTrustUs');
  String get howCanWeHelp => tr('howCanWeHelp');
  String greeting(String name) => tr('greetingCustomer', params: {'name': name});
  String workerGreeting(String name) => tr('workerGreeting', params: {'name': name});

  // Additional Typed Getters
  String get workerLabel => tr('workerLabel');
  String get serviceLabel => tr('serviceLabel');
  String get slotLabel => tr('slotLabel');
  String get addressLabel => tr('addressLabel');
  String get totalEstimateLabel => tr('totalEstimateLabel');
  String get noJobRequests => tr('noJobRequests');
  String get monthlyTotalEarnings => tr('monthlyTotalEarnings');
  String get shareWorkerProfile => tr('shareWorkerProfile');
  String get viewDetailsBtn => tr('viewDetailsBtn');
  String get availableSlotsTitle => tr('availableSlotsTitle');
  String get todayLabel => tr('todayLabel');
  String get tomorrowLabel => tr('tomorrowLabel');
  String get dateLabel => tr('dateLabel');
  String get estCostLabel => tr('estCostLabel');

  String get bookingConfirmTitle => tr('bookingConfirmTitle');
  String get bookingConfirmedHero => tr('bookingConfirmedHero');
  String get bookingConfirmedSub => tr('bookingConfirmedSub');
  String get bookingIdLabel => tr('bookingIdLabel');
  String get copiedToClipboard => tr('copiedToClipboard');
  String get workerAssignedLabel => tr('workerAssignedLabel');
  String get viewBreakdownLink => tr('viewBreakdownLink');
  String get bookingProcessingTitle => tr('bookingProcessingTitle');
  String get bookingProcessingSub => tr('bookingProcessingSub');
  String get bookingIncompleteTitle => tr('bookingIncompleteTitle');
  String get bookingIncompleteSub => tr('bookingIncompleteSub');
  String get bookingOfflineTitle => tr('bookingOfflineTitle');
  String get bookingCancelledTitle => tr('bookingCancelledTitle');
  String get priceBaseLabel => tr('priceBaseLabel');
  String get priceCoopFeeLabel => tr('priceCoopFeeLabel');
  String get priceDiscountLabel => tr('priceDiscountLabel');
  String get priceTotalLabel => tr('priceTotalLabel');
  String get paymentBreakdownTitle => tr('paymentBreakdownTitle');
  String get trackServiceTitle => tr('trackServiceTitle');
  String get trackServiceSub => tr('trackServiceSub');
  String get etaLabel => tr('etaLabel');
  String etaMinutesAway(int minutes) => tr('etaMinutesAway', params: {'minutes': minutes.toString()});
  String get workerOnTheWayMsg => tr('workerOnTheWayMsg');
  String get workerArrivedMsg => tr('workerArrivedMsg');
  String get serviceStartedMsg => tr('serviceStartedMsg');
  String get serviceCompletedMsg => tr('serviceCompletedMsg');
  String get stageAccepted => tr('stageAccepted');
  String get stageWorkerAssigned => tr('stageWorkerAssigned');
  String get stageOnTheWay => tr('stageOnTheWay');
  String get stageArrived => tr('stageArrived');
  String get stageServiceStarted => tr('stageServiceStarted');
  String get stageCompleted => tr('stageCompleted');
  String get shareOtpBtn => tr('shareOtpBtn');
  String get rateServiceBtn => tr('rateServiceBtn');
  String get callWorkerBtn => tr('callWorkerBtn');
  String get chatWorkerBtn => tr('chatWorkerBtn');
  String get reportIssueBtn => tr('reportIssueBtn');
  String get trackServiceBtn => tr('trackServiceBtn');
  String get goToHomeBtn => tr('goToHomeBtn');
  String get reportIssueTitle => tr('reportIssueTitle');
  String get reportIssueSub => tr('reportIssueSub');
  String get issueWorkerLate => tr('issueWorkerLate');
  String get issueWrongWorker => tr('issueWrongWorker');
  String get issueOtherProblem => tr('issueOtherProblem');
  String get cancellationPolicyTitle => tr('cancellationPolicyTitle');
  String get cancellationPolicyBody => tr('cancellationPolicyBody');
  String get supportTitle => tr('supportTitle');
  String get supportPhoneLabel => tr('supportPhoneLabel');
  String get supportWhatsAppLabel => tr('supportWhatsAppLabel');
  String get noTrackingDataFound => tr('noTrackingDataFound');

  // Registration Flow Getters
  String get regTitle => tr('regTitle');
  String get regSubtitleWorker => tr('regSubtitleWorker');
  String get regSubtitleCustomer => tr('regSubtitleCustomer');
  String get regSubtitleContractor => tr('regSubtitleContractor');
  String get regSubtitleCoop => tr('regSubtitleCoop');
  String get regStepRegister => tr('regStepRegister');
  String get regStepVerify => tr('regStepVerify');
  String get regStepComplete => tr('regStepComplete');
  String get regFullName => tr('regFullName');
  String get regFullNameHint => tr('regFullNameHint');
  String get regMobileNumber => tr('regMobileNumber');
  String get regMobileHint => tr('regMobileHint');
  String get regEmail => tr('regEmail');
  String get regEmailOptional => tr('regEmailOptional');
  String get regEmailHint => tr('regEmailHint');
  String get regPassword => tr('regPassword');
  String get regPasswordHint => tr('regPasswordHint');
  String get regWorkCategory => tr('regWorkCategory');
  String get regWorkCategoryHint => tr('regWorkCategoryHint');
  String get regOtherWorkCategory => tr('regOtherWorkCategory');
  String get regOtherWorkCategoryHint => tr('regOtherWorkCategoryHint');
  String get regLocation => tr('regLocation');
  String get regLocationHint => tr('regLocationHint');
  String get regOrgName => tr('regOrgName');
  String get regOrgNameHint => tr('regOrgNameHint');
  String get regCompanyName => tr('regCompanyName');
  String get regCompanyNameHint => tr('regCompanyNameHint');
  String get regGstNumber => tr('regGstNumber');
  String get regGstNumberHint => tr('regGstNumberHint');
  String get regCoopName => tr('regCoopName');
  String get regCoopNameHint => tr('regCoopNameHint');
  String get regRepName => tr('regRepName');
  String get regRepNameHint => tr('regRepNameHint');
  String get regRegNumber => tr('regRegNumber');
  String get regRegNumberHint => tr('regRegNumberHint');
  String get regTermsAgree => tr('regTermsAgree');
  String get regTermsAndConditions => tr('regTermsAndConditions');
  String get regAnd => tr('regAnd');
  String get regPrivacyPolicy => tr('regPrivacyPolicy');
  String get regCreateAccount => tr('regCreateAccount');
  String get regAlreadyHaveAccount => tr('regAlreadyHaveAccount');
  String get regLogin => tr('regLogin');
  String regWhyRegisterAs(String role) => tr('regWhyRegisterAs', params: {'role': role});
  String get regWhyWorkerTitle => tr('regWhyWorkerTitle');
  String get regWhyWorkerDesc => tr('regWhyWorkerDesc');
  String get regWhyCustomerTitle => tr('regWhyCustomerTitle');
  String get regWhyCustomerDesc => tr('regWhyCustomerDesc');
  String get regWhyContractorTitle => tr('regWhyContractorDesc');
  String get regWhyCoopTitle => tr('regWhyCoopTitle');
  String get regWhyCoopDesc => tr('regWhyCoopDesc');
  String get serviceOther => tr('serviceOther');

  // Step 16 & Step 17 (Completion, Payment, After Service & Rating) Getters
  String get close => tr('close');
  String get serviceCompletionTitle => tr('serviceCompletionTitle');
  String get serviceCompletedTitle => tr('serviceCompletedTitle');
  String get serviceCompletedSubtitle => tr('serviceCompletedSubtitle');
  String get serviceDetailsTitle => tr('serviceDetailsTitle');
  String get dateTimeLabel => tr('dateTimeLabel');
  String get totalAmountLabel => tr('totalAmountLabel');
  String get viewBreakdownBtn => tr('viewBreakdownBtn');
  String get beforeAfterPhotosTitle => tr('beforeAfterPhotosTitle');
  String get beforeTag => tr('beforeTag');
  String get afterTag => tr('afterTag');
  String get proceedToPaymentBtn => tr('proceedToPaymentBtn');
  String get rateExperienceBtn => tr('rateExperienceBtn');
  String get downloadInvoiceBtn => tr('downloadInvoiceBtn');
  String get billSummaryTitle => tr('billSummaryTitle');
  String get baseAmountLabel => tr('baseAmountLabel');
  String get materialsCostLabel => tr('materialsCostLabel');
  String get serviceFeeLabel => tr('serviceFeeLabel');
  String get discountLabel => tr('discountLabel');
  String get paymentInfoTitle => tr('paymentInfoTitle');
  String get paymentSuccessfulBadge => tr('paymentSuccessfulBadge');
  String get paymentPendingBadge => tr('paymentPendingBadge');
  String get txnIdLabel => tr('txnIdLabel');

  String get materialsUsedTitle => tr('materialsUsedTitle');
  String get materialsIncludedNote => tr('materialsIncludedNote');
  String get serviceDurationTitle => tr('serviceDurationTitle');
  String get totalDurationLabel => tr('totalDurationLabel');
  String get startTimeLabel => tr('startTimeLabel');
  String get endTimeLabel => tr('endTimeLabel');
  String get rebookTileTitle => tr('rebookTileTitle');
  String get rebookTileDesc => tr('rebookTileDesc');
  String get rebookWithWorkerDesc => tr('rebookWithWorkerDesc');
  String get invoiceTileTitle => tr('invoiceTileTitle');
  String get invoiceTileDesc => tr('invoiceTileDesc');
  String get helpTileTitle => tr('helpTileTitle');
  String get helpTileDesc => tr('helpTileDesc');
  String get contactBtn => tr('contactBtn');
  String get serviceWarrantyTitle => tr('serviceWarrantyTitle');
  String get serviceWarrantyDesc => tr('serviceWarrantyDesc');
  String get moreInfoBtn => tr('moreInfoBtn');
  String get shareServiceTitle => tr('shareServiceTitle');
  String get shareServiceDesc => tr('shareServiceDesc');
  String get shareBtn => tr('shareBtn');
  String get afterServiceTitle => tr('afterServiceTitle');
  String get workSummaryTitle => tr('workSummaryTitle');
  String get problemLabel => tr('problemLabel');
  String get workDoneLabel => tr('workDoneLabel');
  String get actualDurationLabel => tr('actualDurationLabel');
  String get completionTimeLabel => tr('completionTimeLabel');
  String get paymentDetailsTitle => tr('paymentDetailsTitle');
  String get paymentMethodLabel => tr('paymentMethodLabel');
  String get paymentStatusLabel => tr('paymentStatusLabel');
  String get invoiceNumberLabel => tr('invoiceNumberLabel');
  String get rateAndFeedbackBtn => tr('rateAndFeedbackBtn');
  String get rateWorkerTitle => tr('rateWorkerTitle');
  String get howWasExperience => tr('howWasExperience');
  String rateWorkerPrompt(String name) => tr('rateWorkerPrompt', params: {'name': name});
  String get writeFeedbackHint => tr('writeFeedbackHint');
  String get submitRatingBtn => tr('submitRatingBtn');
  String get step15ProceedToPayment => tr('step15ProceedToPayment');
  String get paymentModalTitle => tr('paymentModalTitle');
  String get payNowBtn => tr('payNowBtn');
  String get ratingSubmittedSuccess => tr('ratingSubmittedSuccess');
  String get ratingStar1 => tr('ratingStar1');
  String get ratingStar2 => tr('ratingStar2');
  String get ratingStar3 => tr('ratingStar3');
  String get ratingStar4 => tr('ratingStar4');
  String get ratingStar5 => tr('ratingStar5');
  String get unitNos => tr('unitNos');
  String get paymentProcessing => tr('paymentProcessing');
  String get ratingSubmitting => tr('ratingSubmitting');
  String get invoiceDownloading => tr('invoiceDownloading');
  String get invoiceDownloaded => tr('invoiceDownloaded');
  String get warrantyModalTitle => tr('warrantyModalTitle');
  String get warrantyModalContent => tr('warrantyModalContent');
  String get sampleProblemDesc => tr('sampleProblemDesc');
  String get sampleWorkDoneDesc => tr('sampleWorkDoneDesc');

  // Screen 19 & Screen 20 Worker Job Flow Getters
  String get newJobRequestTitle => tr('newJobRequestTitle');
  String expiresIn(String time) => tr('expiresInLabel', params: {'time': time});
  String get verifiedBadge => tr('verifiedBadge');
  String reviewsCount(int count) => tr('reviewsCountText', params: {'count': count.toString()});
  String get jobProblemTapDesc => tr('jobProblemTapDesc');
  String get mapBtnLabel => tr('mapBtnLabel');
  String get distanceLabel => tr('distanceLabel');
  String get estimatedPriceLabel => tr('estimatedPriceLabel');
  String get priorityLabel => tr('priorityLabel');
  String get priorityHigh => tr('priorityHigh');
  String get priorityMedium => tr('priorityMedium');
  String get priorityLow => tr('priorityLow');
  String get priorityUrgent => tr('priorityUrgent');
  String get timeLabel => tr('timeLabel');
  String get jobScheduledTimeToday => tr('jobScheduledTimeToday');
  String get flexibility30mins => tr('flexibility30mins');
  String get customerRequestLabel => tr('customerRequestLabel');
  String get jobCustomerNoteText => tr('jobCustomerNoteText');
  String get rejectJobBtn => tr('rejectJobBtn');
  String get acceptJobBtn => tr('acceptJobBtn');
  String get normalStateHeadline => tr('normalStateHeadline');
  String get normalStateSub => tr('normalStateSub');
  String get expiringStateHeadline => tr('expiringStateHeadline');
  String get expiringStateSub => tr('expiringStateSub');
  String get expiredStateHeadline => tr('expiredStateHeadline');
  String get expiredStateSub => tr('expiredStateSub');
  String get acceptedByOtherHeadline => tr('acceptedByOtherHeadline');
  String get acceptedByOtherSub => tr('acceptedByOtherSub');
  String get youAcceptedHeadline => tr('youAcceptedHeadline');
  String get youAcceptedSub => tr('youAcceptedSub');
  String get youRejectedHeadline => tr('youRejectedHeadline');
  String get youRejectedSub => tr('youRejectedSub');
  String get viewJobDetailsBtn => tr('viewJobDetailsBtn');
  String get dismissBtn => tr('dismissBtn');
  String get customerInfoTitle => tr('customerInfoTitle');
  String get customerSandeepPatil => tr('customerSandeepPatil');
  String get totalJobsLabel => tr('totalJobsLabel');
  String get membershipLabel => tr('membershipLabel');
  String get lastJobLabel => tr('lastJobLabel');
  String get cancelledJobsLabel => tr('cancelledJobsLabel');
  String get memberTwoMonthsAgo => tr('memberTwoMonthsAgo');
  String get viewProfileBtn => tr('viewProfileBtn');
  String get categoryLabel => tr('categoryLabel');
  String get skillLabel => tr('skillLabel');
  String get estTimeLabel => tr('estTimeLabel');
  String get requiredToolsLabel => tr('requiredToolsLabel');
  String get basicToolsValue => tr('basicToolsValue');
  String get locationInfoTitle => tr('locationInfoTitle');
  String get jobAddressGaneshApts => tr('jobAddressGaneshApts');
  String get premiseApartment => tr('premiseApartment');
  String get floorSecond => tr('floorSecond');
  String get viewMapBtn => tr('viewMapBtn');
  String get openMapBtn => tr('openMapBtn');
  String get estPriceTitle => tr('estPriceTitle');
  String get serviceChargeLabel => tr('serviceChargeLabel');
  String get visitingChargeLabel => tr('visitingChargeLabel');
  String get materialsEstLabel => tr('materialsEstLabel');
  String get priorityInfoTitle => tr('priorityInfoTitle');
  String get priorityUrgentDesc => tr('priorityUrgentDesc');
  String get ratingStatusTitle => tr('ratingStatusTitle');
  String get ratingKeepItUp => tr('ratingKeepItUp');
  String get jobDetailsTitle => tr('jobDetailsTitle');
  String get highPriorityBadge => tr('highPriorityBadge');
  String requestExpiresIn(String time) => tr('requestExpiresInBanner', params: {'time': time});
  String get callCustomerBtn => tr('callCustomerBtn');
  String get chatCustomerBtn => tr('chatCustomerBtn');
  String get customerProfileBtn => tr('customerProfileBtn');
  String get problemAndAiSection => tr('problemAndAiSection');
  String get customerReportedProblem => tr('customerReportedProblem');
  String get aiAnalysisLabel => tr('aiAnalysisLabel');
  String get jobAiAnalysisDesc => tr('jobAiAnalysisDesc');
  String get recommendedService => tr('recommendedService');
  String get estDurationLabel => tr('estDurationLabel');
  String get estDuration30to45 => tr('estDuration30to45');
  String get difficultyLabel => tr('difficultyLabel');
  String get difficultyEasy => tr('difficultyEasy');
  String get scopeOfWorkSection => tr('scopeOfWorkSection');
  String get scopeTapInspection => tr('scopeTapInspection');
  String get scopeWasherReplacement => tr('scopeWasherReplacement');
  String get scopeStopLeakage => tr('scopeStopLeakage');
  String get scopeWaterFlowTest => tr('scopeWaterFlowTest');
  String get scopeCleanupPostWork => tr('scopeCleanupPostWork');
  String get requiredToolsSection => tr('requiredToolsSection');
  String get toolAdjustableWrench => tr('toolAdjustableWrench');
  String get toolScrewdriver => tr('toolScrewdriver');
  String get toolTapKey => tr('toolTapKey');
  String get toolPlumberTape => tr('toolPlumberTape');
  String get toolBasinWrench => tr('toolBasinWrench');
  String get locationAndMapSection => tr('locationAndMapSection');
  String get premiseTypeLabel => tr('premiseTypeLabel');
  String get floorLabel => tr('floorLabel');
  String get earningsAndMaterialsSection => tr('earningsAndMaterialsSection');
  String get estEarningsLabel => tr('estEarningsLabel');
  String get laborChargeLabel => tr('laborChargeLabel');
  String get materialsChargeLabel => tr('materialsChargeLabel');
  String get totalExpectedLabel => tr('totalExpectedLabel');
  String get pricingDisclaimerNote => tr('pricingDisclaimerNote');
  String get materialsRequiredSection => tr('materialsRequiredSection');
  String get matWasherOring => tr('matWasherOring');
  String get matPlumberTape => tr('matPlumberTape');
  String get matOtherRequired => tr('matOtherRequired');
  String get customerNotesSection => tr('customerNotesSection');
  String get safetyGuidelinesSection => tr('safetyGuidelinesSection');
  String get safetyElectricalPrecaution => tr('safetyElectricalPrecaution');
  String get safetyTurnOffMainValve => tr('safetyTurnOffMainValve');
  String get safetyUseProtectiveGear => tr('safetyUseProtectiveGear');
  String get safetyPoliteCommunication => tr('safetyPoliteCommunication');
  String get additionalInfoSection => tr('additionalInfoSection');
  String get payMethodOnlineUpi => tr('payMethodOnlineUpi');
  String get jobCancelPolicy2Hours => tr('jobCancelPolicy2Hours');
  String get support24x7Available => tr('support24x7Available');
  String get customerProfileSummaryTitle => tr('customerProfileSummaryTitle');
  String get successfulJobsCount => tr('successfulJobsCount');
  String get cancelledJobsCount => tr('cancelledJobsCount');
  String get decideLaterBtn => tr('decideLaterBtn');
  String get acceptSubtitleNote => tr('acceptSubtitleNote');


  static AppStrings of(BuildContext context) {
    final scope = AppLocaleScope.maybeOf(context);
    if (scope != null) {
      return AppStrings(scope.languageCode);
    }
    final langProvider = context.watch<LanguageProvider?>();
    if (langProvider != null) {
      return AppStrings(langProvider.locale.languageCode);
    }
    return const AppStrings('en');
  }
}

/// Backward compatibility alias for [AppStrings].
typedef L10n = AppStrings;


