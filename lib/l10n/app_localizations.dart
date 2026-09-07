import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import 'l10n.dart';

/// Legacy translation accessor that forwards to [AppStrings] and [AppStringsData].
class AppLocalizations {
  static AppStrings of(BuildContext context, {bool listen = true}) {
    final scope = AppLocaleScope.maybeOf(context, listen: listen);
    if (scope != null) {
      return AppStrings(scope.languageCode);
    }
    final provider = Provider.of<LanguageProvider>(context, listen: listen);
    return AppStrings(provider.locale.languageCode);
  }
}
