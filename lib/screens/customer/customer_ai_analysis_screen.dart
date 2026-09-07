import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/customer_problem_model.dart';
import '../../providers/customer_problem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';

class CustomerAiAnalysisScreen extends StatelessWidget {
  const CustomerAiAnalysisScreen({super.key});

  void _showHelpDialog(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerProblemProvider>();
    final result = prov.analysisResult ?? AiAnalysisResultModel.createDefault();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          context.tr('aiAnalysisTitle'),
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
            onPressed: () => _showHelpDialog(context),
          ),
          const LanguageSelectorButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Bot Avatar Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F0FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.smart_toy_outlined,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('aiAnalysisCompleteHeader'),
                      textAlign: TextAlign.center,
                      style: AppTypography.heading(fontSize: 17).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('aiAnalysisCompleteSub'),
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 1. Identified Problem Card
              _buildCard(
                title: context.tr('identifiedProblemLabel'),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prov.draftText.isNotEmpty
                                ? prov.draftText
                                : context.tr(result.recognizedProblem),
                            style: AppTypography.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr(result.recognizedProblemSub),
                            style: AppTypography.subtitle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.handyman_outlined,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Confidence Level Card
              _buildCard(
                title: context.tr('confidenceLevelLabel'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF81C784)),
                          ),
                          child: Text(
                            context.tr('confidenceHighLabel'),
                            style: AppTypography.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        Text(
                          '92%',
                          style: AppTypography.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const LinearProgressIndicator(
                        value: 0.92,
                        minHeight: 8,
                        backgroundColor: Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('confidenceExplanation'),
                      style: AppTypography.subtitle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Suggested Service Card
              _buildCard(
                title: context.tr('suggestedServiceLabel'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F0FE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.plumbing,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.tr(result.suggestedCategory),
                            style: AppTypography.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: result.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Required Skills Card
              _buildCard(
                title: context.tr('requiredSkillsLabel'),
                child: Text(
                  context.tr('skillListPlumber'),
                  style: AppTypography.poppins(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 5. Estimated Time & Cost Grid
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      title: context.tr('estTimeLabel'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  context.tr(result.estimatedTime),
                                  style: AppTypography.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCard(
                      title: context.tr('estCostLabel'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.currency_rupee, size: 18, color: Color(0xFF2E7D32)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  context.tr(result.estimatedPrice),
                                  style: AppTypography.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('sampleEstCostSub'),
                            style: AppTypography.subtitle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 6. Urgency Level Card
              _buildCard(
                title: context.tr('urgencyLevelLabel'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: Text(
                        context.tr('urgencyMediumText'),
                        style: AppTypography.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 7. AI Reasoning Card
              _buildCard(
                title: context.tr('aiReasonLabel'),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFFFFA000), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr(result.aiReasoning),
                        style: AppTypography.poppins(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dual Action Bottom Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        context.tr('editReanalyzeBtn'),
                        style: AppTypography.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/customer/ai-result');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        context.tr('confirmContinueBtn'),
                        style: AppTypography.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
