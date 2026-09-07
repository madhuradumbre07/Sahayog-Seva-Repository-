import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/customer_dashboard_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AiAssistSheet extends StatefulWidget {
  const AiAssistSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiAssistSheet(),
    );
  }

  @override
  State<AiAssistSheet> createState() => _AiAssistSheetState();
}

class _AiAssistSheetState extends State<AiAssistSheet>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final prov = context.read<CustomerDashboardProvider>();
    _controller = TextEditingController(text: prov.aiProblemText);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (prov.isListeningVoice) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerDashboardProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F0FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('describeProblemAi'),
                      style: AppTypography.heading(fontSize: 17),
                    ),
                    Text(
                      context.tr('voiceSearchPrompt'),
                      style: AppTypography.subtitle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Animated Voice Mic Section
          Center(
            child: GestureDetector(
              onTap: () => prov.toggleVoiceListening(),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = prov.isListeningVoice
                      ? 1.0 + (_pulseController.value * 0.15)
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: prov.isListeningVoice
                            ? const Color(0xFFEF5350)
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (prov.isListeningVoice
                                    ? const Color(0xFFEF5350)
                                    : AppColors.primary)
                                .withValues(alpha: 0.35),
                            blurRadius: 20,
                            spreadRadius: prov.isListeningVoice ? 6 : 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        prov.isListeningVoice ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              prov.isListeningVoice
                  ? context.tr('listeningVoice')
                  : context.tr('tapToSpeak'),
              style: AppTypography.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: prov.isListeningVoice
                    ? const Color(0xFFEF5350)
                    : AppColors.subtitle,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Search / Query text field
          TextField(
            controller: _controller,
            onChanged: (text) => prov.setAiProblemText(text),
            decoration: InputDecoration(
              hintText: context.tr('problemPlaceholder'),
              hintStyle: AppTypography.subtitle(fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        prov.setAiProblemText('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'AI Analyzing: ${_controller.text.isEmpty ? "Tap / Plumbing Repair" : _controller.text}',
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            label: Text(
              context.tr('describeProblemAi'),
              style: AppTypography.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
