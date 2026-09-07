import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/app_language.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class LanguageSelectorButton extends StatelessWidget {
  const LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    LanguageProvider? language;
    try {
      language = context.watch<LanguageProvider?>();
    } catch (_) {}
    final code = language?.locale.languageCode ?? 'en';
    final current = AppLanguage.supported.firstWhere(
      (item) => item.code == code,
      orElse: () => AppLanguage.supported.first,
    );

    return PopupMenuButton<String>(
      tooltip: context.tr('chooseLanguage'),
      onSelected: (selectedCode) {
        language?.setLanguage(selectedCode);
        try {
          context.read<AuthProvider>().setLanguage(selectedCode);
        } catch (_) {}
      },
      offset: const Offset(0, 40),
      itemBuilder: (context) {
        return [
          for (final item in AppLanguage.supported)
            PopupMenuItem(
              value: item.code,
              child: Text(item.listLabel),
            ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: AppColors.primary, size: 16),
            const SizedBox(width: 4),
            Text(
              current.nativeName,
              style: AppTypography.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }
}
