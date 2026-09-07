import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/app_language.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/community_skyline.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_views.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  static const String routeName = '/language-selection';

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final _listKey = GlobalKey();
  String? _selectedCode;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LanguageProvider>();
      provider.checkConnectivity();
      if (provider.languageCode != null) {
        setState(() => _selectedCode = provider.languageCode);
      }
    });
  }

  void _onGlobePressed() {
    final context = _listKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectLanguage(String code) {
    setState(() {
      _selectedCode = code;
      _showValidation = false;
    });
  }

  Future<void> _onContinue() async {
    if (_selectedCode == null) {
      setState(() => _showValidation = true);
      return;
    }

    final provider = context.read<LanguageProvider>();
    await provider.applyLanguageWithLoading(_selectedCode!);
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  Future<void> _onTryAgain() async {
    await context.read<LanguageProvider>().checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();
    final activeCode = _selectedCode ?? provider.languageCode ?? 'en';
    final bottomIllustrationHeight = MediaQuery.sizeOf(context).height * 0.22;

    return AppLocaleScope(
      locale: Locale(activeCode),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CommunitySkyline(height: bottomIllustrationHeight),
                ),
                if (!provider.isOnline)
                  NetworkErrorView(onTryAgain: _onTryAgain)
                else
                  SafeArea(
                    child: Column(
                      children: [
                        if (_showValidation)
                          _ValidationBanner(
                            message: context.tr('selectLanguageError'),
                          ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            children: [
                              BrandHeader(
                                showGlobe: true,
                                onGlobePressed: _onGlobePressed,
                              ),
                              const SizedBox(height: 28),
                              KeyedSubtree(
                                key: _listKey,
                                child: Text(
                                  context.tr('chooseLanguage'),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.heading(fontSize: 22),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                context.tr('chooseLanguageSubtitle'),
                                textAlign: TextAlign.center,
                                style: AppTypography.subtitle(fontSize: 14),
                              ),
                              const SizedBox(height: 20),
                              RadioGroup<String>(
                                groupValue: _selectedCode,
                                onChanged: (code) {
                                  if (code != null) _selectLanguage(code);
                                },
                                child: Column(
                                  children: [
                                    ...AppLanguage.supported.map(
                                      (language) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: _LanguageTile(
                                          language: language,
                                          selected:
                                              _selectedCode == language.code,
                                          onTap: () =>
                                              _selectLanguage(language.code),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: PrimaryButton(
                            label: context.tr('continueLabel'),
                            enabled: _selectedCode != null,
                            allowTapWhenDisabled: true,
                            onPressed: _onContinue,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (provider.isSettingLanguage)
                  const _SettingLanguageOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.illustrationSoft,
                child: Text(language.flag, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  language.listLabel,
                  style: AppTypography.forLanguageScript(
                    language.code,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtitle,
                  ),
                ),
              ),
              Radio<String>(
                value: language.code,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return AppColors.border;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.errorBannerBackground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTypography.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingLanguageOverlay extends StatelessWidget {
  const _SettingLanguageOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.overlayScrim,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Material(
            color: AppColors.background,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox.square(
                    dimension: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('settingLanguage'),
                    textAlign: TextAlign.center,
                    style: AppTypography.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('pleaseWait'),
                    textAlign: TextAlign.center,
                    style: AppTypography.subtitle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

