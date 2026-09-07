import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/app_language.dart';
import '../../models/customer_problem_model.dart';
import '../../providers/customer_problem_provider.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';

class CustomerDescribeProblemScreen extends StatefulWidget {
  const CustomerDescribeProblemScreen({super.key});

  @override
  State<CustomerDescribeProblemScreen> createState() =>
      _CustomerDescribeProblemScreenState();
}

class _CustomerDescribeProblemScreenState
    extends State<CustomerDescribeProblemScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _textController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final prov = context.read<CustomerProblemProvider>();
    _textController = TextEditingController(text: prov.draftText);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.tr('helpDialogTitle'),
                style: AppTypography.heading(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          context.tr('helpDialogContent'),
          style: AppTypography.poppins(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr('gotIt'),
              style: AppTypography.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageOverrideSheet(
    BuildContext context,
    CustomerProblemProvider prov,
  ) {
    final activeLocale =
        context.read<LanguageProvider>().languageCode ?? 'en';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('overrideLanguageTitle'),
                    style: AppTypography.heading(fontSize: 17),
                  ),
                  if (prov.isLanguageManuallyOverridden)
                    TextButton(
                      onPressed: () {
                        prov.resetLanguageOverride(
                          activeLocaleCode: activeLocale,
                        );
                        Navigator.pop(sheetContext);
                      },
                      child: Text(
                        context.tr('autoDetect'),
                        style: AppTypography.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: AppLanguage.supported.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final lang = AppLanguage.supported[index];
                    final isSelected = prov.detectedLanguageCode == lang.code;

                    return ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      leading: Text(lang.flag, style: const TextStyle(fontSize: 20)),
                      title: Text(
                        '${lang.englishName} (${lang.nativeName})',
                        style: AppTypography.poppins(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF2E7D32),
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        prov.setManualLanguageOverride(lang.code);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Future<void> _startAnalysis() async {
    final prov = context.read<CustomerProblemProvider>();
    if (!prov.canAnalyze) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('errorInputTooShort')),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show AI Thinking Loading Modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (modalContext) {
        return Consumer<CustomerProblemProvider>(
          builder: (context, problemProv, _) {
            final steps = [
              context.tr('aiAnalyzingStep1'),
              context.tr('aiAnalyzingStep2'),
              context.tr('aiAnalyzingStep3'),
              context.tr('aiAnalyzingStep4'),
            ];

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F0FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('aiAnalyzingHeadline'),
                      textAlign: TextAlign.center,
                      style: AppTypography.heading(fontSize: 17).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('aiAnalyzingSub'),
                      style: AppTypography.subtitle(fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: problemProv.analysisProgress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: List.generate(steps.length, (index) {
                        final isDone = index < problemProv.analysisStepIndex;
                        final isCurrent = index == problemProv.analysisStepIndex;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? const Color(0xFFE8F5E9)
                                      : (isCurrent
                                          ? const Color(0xFFE8F0FE)
                                          : Colors.grey.shade100),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isDone
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Color(0xFF2E7D32),
                                        )
                                      : (isCurrent
                                          ? const SizedBox(
                                              width: 10,
                                              height: 10,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.circle,
                                              size: 6,
                                              color: Colors.grey,
                                            )),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  steps[index],
                                  style: AppTypography.poppins(
                                    fontSize: 13,
                                    fontWeight: isCurrent || isDone
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isDone
                                        ? const Color(0xFF2E7D32)
                                        : (isCurrent
                                            ? AppColors.primary
                                            : Colors.grey.shade600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Trigger analysis
    await prov.runAiAnalysis();

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      Navigator.pushNamed(context, '/customer/ai-analysis');
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerProblemProvider>();

    if (prov.isRecordingVoice) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
      }
    }

    if (_textController.text != prov.draftText) {
      _textController.text = prov.draftText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }

    final hasInput = prov.draftText.trim().isNotEmpty ||
        prov.isRecordingVoice ||
        prov.mediaList.isNotEmpty ||
        prov.videoItem != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('describeProblemTitle'),
          style: AppTypography.heading(fontSize: 17).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textPrimary),
            tooltip: context.tr('helpDialogTitle'),
            onPressed: _showHelpDialog,
          ),
          const LanguageSelectorButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              Text(
                context.tr('describeProblemHeader'),
                style: AppTypography.heading(fontSize: 20).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('describeProblemInstruction'),
                style: AppTypography.subtitle(fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Segmented Tab Bar for 4 input modes
              _buildInputModeSelector(context, prov),
              const SizedBox(height: 16),

              // Dynamic Input Body Area
              _buildActiveInputArea(context, prov),
              const SizedBox(height: 16),

              // Live Updating Dynamic Language Detected Badge
              if (hasInput)
                GestureDetector(
                  onTap: () => _showLanguageOverrideSheet(context, prov),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF81C784)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          prov.isLanguageManuallyOverridden
                              ? Icons.tune
                              : Icons.check_circle,
                          color: const Color(0xFF2E7D32),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${context.tr('aiLanguageDetected')}: ${prov.detectedLanguageDisplayName}',
                          style: AppTypography.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF2E7D32),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

              // Example Chips section
              _buildExampleChips(context, prov),
              const SizedBox(height: 24),

              // Primary Action Button
              ElevatedButton(
                onPressed: _startAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFF90CAF9),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: prov.canAnalyze ? 2 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('startAiAnalysis'),
                      style: AppTypography.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Trust & Security Note
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        context.tr('privacyBadgeFooter'),
                        textAlign: TextAlign.center,
                        style: AppTypography.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputModeSelector(
    BuildContext context,
    CustomerProblemProvider prov,
  ) {
    final modes = [
      (InputModeType.text, Icons.edit_note, context.tr('tabText')),
      (InputModeType.voice, Icons.mic, context.tr('tabVoice')),
      (InputModeType.photo, Icons.camera_alt, context.tr('tabPhoto')),
      (InputModeType.video, Icons.videocam, context.tr('tabVideo')),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: modes.map((m) {
          final isSelected = prov.activeMode == m.$1;

          return Expanded(
            child: GestureDetector(
              onTap: () => prov.setMode(m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      m.$2,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      m.$3,
                      style: AppTypography.poppins(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveInputArea(
    BuildContext context,
    CustomerProblemProvider prov,
  ) {
    switch (prov.activeMode) {
      case InputModeType.text:
        return _buildTextInputArea(context, prov);
      case InputModeType.voice:
        return _buildVoiceInputArea(context, prov);
      case InputModeType.photo:
        return _buildPhotoInputArea(context, prov);
      case InputModeType.video:
        return _buildVideoInputArea(context, prov);
    }
  }

  Widget _buildTextInputArea(
    BuildContext context,
    CustomerProblemProvider prov,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _textController,
            maxLines: 4,
            maxLength: 500,
            onChanged: (val) {
              final activeLang =
                  context.read<LanguageProvider>().languageCode ?? 'en';
              prov.setText(val, activeLocaleCode: activeLang);
            },
            decoration: InputDecoration(
              hintText: context.tr('problemPlaceholderLong'),
              hintStyle: AppTypography.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
                height: 1.4,
              ),
              border: InputBorder.none,
              counterText: '${_textController.text.length}/500',
              counterStyle:
                  AppTypography.poppins(fontSize: 11, color: Colors.grey),
            ),
            style: AppTypography.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 12),
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.tr('aiAnalysisPrivacyNote'),
                  style: AppTypography.poppins(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceInputArea(
    BuildContext context,
    CustomerProblemProvider prov,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (prov.isRecordingVoice) {
                final activeLang =
                    context.read<LanguageProvider>().languageCode ?? 'en';
                prov.stopVoiceRecording(activeLocaleCode: activeLang);
              } else {
                prov.startVoiceRecording();
              }
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = prov.isRecordingVoice
                    ? 1.0 + (_pulseController.value * 0.15)
                    : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: prov.isRecordingVoice
                          ? const Color(0xFFD32F2F)
                          : AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (prov.isRecordingVoice
                                  ? const Color(0xFFD32F2F)
                                  : AppColors.primary)
                              .withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      prov.isRecordingVoice ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Text(
            prov.isRecordingVoice
                ? '${context.tr('voiceListening')} (00:${prov.voiceRecordingSeconds.toString().padLeft(2, '0')})'
                : context.tr('speakProblemPrompt'),
            style: AppTypography.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: prov.isRecordingVoice
                  ? const Color(0xFFD32F2F)
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          if (prov.draftText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                prov.draftText,
                style: AppTypography.poppins(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoInputArea(
    BuildContext context,
    CustomerProblemProvider prov,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Thumbnails list
          if (prov.mediaList.isNotEmpty) ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: prov.mediaList.map((m) {
                return Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child:
                            Icon(Icons.image, color: AppColors.primary, size: 32),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => prov.removePhoto(m.id),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => prov.addSamplePhoto('camera_photo.jpg'),
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: Text(
                    context.tr('cameraTakeBtn'),
                    style: AppTypography.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => prov.addSamplePhoto('gallery_photo.jpg'),
                  icon: const Icon(Icons.photo_library, size: 16),
                  label: Text(
                    context.tr('galleryPickBtn'),
                    style: AppTypography.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInputArea(
    BuildContext context,
    CustomerProblemProvider prov,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          if (prov.videoItem != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.videocam, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prov.videoItem!.fileName,
                          style: AppTypography.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${prov.videoItem!.formattedDuration} • ${prov.videoItem!.formattedSize}',
                          style: AppTypography.subtitle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => prov.removeVideo(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            const Icon(Icons.videocam_outlined,
                size: 48, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              '${context.tr('videoRecordPrompt')} ${context.tr('videoLimitNote')}',
              style: AppTypography.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => prov.addSampleVideo(),
              icon: const Icon(Icons.video_library, size: 16),
              label: Text(
                context.tr('videoSelectedBtn'),
                style: AppTypography.poppins(
                    fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleChips(
    BuildContext context,
    CustomerProblemProvider prov,
  ) {
    final chips = [
      context.tr('exampleChip1'),
      context.tr('exampleChip2'),
      context.tr('exampleChip3'),
      context.tr('exampleChip4'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('exampleChipsTitle'),
          style: AppTypography.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chips.map((chipText) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(chipText),
                  labelStyle: AppTypography.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                  backgroundColor: const Color(0xFFE8F0FE),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onPressed: () {
                    final activeLang =
                        context.read<LanguageProvider>().languageCode ?? 'en';
                    prov.applyExampleChip(chipText, activeLocaleCode: activeLang);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
