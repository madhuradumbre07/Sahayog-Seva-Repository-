import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/customer_problem_model.dart';
import '../../providers/customer_problem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';

class CustomerAiResultScreen extends StatefulWidget {
  const CustomerAiResultScreen({super.key});

  @override
  State<CustomerAiResultScreen> createState() => _CustomerAiResultScreenState();
}

class _CustomerAiResultScreenState extends State<CustomerAiResultScreen> {
  bool _isWhyExpanded = false;

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

  void _showChangeServiceSheet(
    BuildContext context,
    CustomerProblemProvider prov,
    AiAnalysisResultModel result,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('changeServiceChoiceBtn'),
                    style: AppTypography.heading(fontSize: 18).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F0FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.plumbing, color: AppColors.primary),
                ),
                title: Text(
                  context.tr(result.suggestedCategory),
                  style: AppTypography.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${context.tr('matchConfidencePill')} • ${context.tr(result.estimatedPrice)}',
                  style: AppTypography.subtitle(fontSize: 12),
                ),
                onTap: () {
                  prov.resetAlternativeSelection();
                  Navigator.pop(ctx);
                },
                trailing: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: !prov.hasCustomAlternativeSelected
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: !prov.hasCustomAlternativeSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const Divider(),
              ...result.alternatives.map((alt) {
                final isSelected =
                    prov.hasCustomAlternativeSelected &&
                    prov.selectedAlternative?.id == alt.id;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    prov.selectAlternative(alt);
                    Navigator.pop(ctx);
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(alt.icon, color: const Color(0xFF475569)),
                  ),
                  title: Text(
                    alt.title,
                    style: AppTypography.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${context.tr(alt.matchPercentage)} • ${context.tr(alt.priceRange)}',
                    style: AppTypography.subtitle(fontSize: 12),
                  ),
                  trailing: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerProblemProvider>();
    final result = prov.analysisResult ?? AiAnalysisResultModel.createDefault();
    final activeServiceName = prov.hasCustomAlternativeSelected
        ? prov.selectedAlternative!.title
        : context.tr(result.suggestedCategory);

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
          context.tr('aiResultTitle'),
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
              // Hero Result Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF81C784)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xFF2E7D32),
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('rightServiceFoundHeader'),
                      textAlign: TextAlign.center,
                      style: AppTypography.heading(fontSize: 17).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('rightServiceFoundSub'),
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 1. Recommended Service Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('recommendedServiceSection'),
                      style: AppTypography.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Service Icon & Title Row
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F0FE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.plumbing,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeServiceName,
                                style: AppTypography.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF81C784),
                                  ),
                                ),
                                child: Text(
                                  context.tr('matchConfidencePill'),
                                  style: AppTypography.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 2. Required Skill
                    _buildSubDetailRow(
                      title: context.tr('aiSkillRequiredStep'),
                      content: context.tr('skillPlumberReq'),
                    ),
                    const Divider(height: 20),

                    // 3 & 4. Estimated Time & Cost
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('estTimeLabel'),
                                style: AppTypography.subtitle(fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.tr(result.estimatedTime),
                                    style: AppTypography.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('estCostLabel'),
                                style: AppTypography.subtitle(fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.currency_rupee, size: 16, color: Color(0xFF2E7D32)),
                                  const SizedBox(width: 2),
                                  Text(
                                    context.tr(result.estimatedPrice),
                                    style: AppTypography.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // 5. Urgency
                    _buildSubDetailRow(
                      title: context.tr('aiUrgencyStep'),
                      content: context.tr('urgencyBadgeFlame'),
                    ),
                    const Divider(height: 20),

                    // 6. Why This Service? (Expandable)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('whyThisServiceSection'),
                              style: AppTypography.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _isWhyExpanded = !_isWhyExpanded);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _isWhyExpanded
                                    ? context.tr('viewLessDetails')
                                    : context.tr('viewMoreDetails'),
                                style: AppTypography.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('whyThisServiceDetail'),
                          style: AppTypography.poppins(
                            fontSize: 12,
                            color: const Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                        if (_isWhyExpanded) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              context.tr('aiReasonBulletSummary'),
                              style: AppTypography.poppins(
                                fontSize: 11,
                                color: const Color(0xFF334155),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 7. Alternative Services Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('alternativeServicesSection'),
                      style: AppTypography.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...result.alternatives.map((alt) {
                      return GestureDetector(
                        onTap: () => prov.selectAlternative(alt),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: prov.selectedAlternative?.id == alt.id
                                ? const Color(0xFFE8F0FE)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: prov.selectedAlternative?.id == alt.id
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(alt.icon, color: AppColors.primary, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alt.title,
                                      style: AppTypography.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${context.tr(alt.matchPercentage)} • ${context.tr(alt.priceRange)}',
                                      style: AppTypography.subtitle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              if (prov.selectedAlternative?.id == alt.id)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Dual Action Footer
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showChangeServiceSheet(context, prov, result),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        context.tr('changeServiceChoiceBtn'),
                        style: AppTypography.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/customer/matching-workers');
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
                        context.tr('confirmFindMatchingWorkersBtn'),
                        style: AppTypography.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bottom Privacy Guarantee
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF2E7D32)),
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

  Widget _buildSubDetailRow({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.subtitle(fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          content,
          style: AppTypography.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
