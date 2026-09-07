import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/service_completion_model.dart';
import '../../providers/service_completion_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';

class CustomerServiceRatingScreen extends StatefulWidget {
  const CustomerServiceRatingScreen({
    super.key,
    this.bookingId = 'SHS-842109',
  });

  final String bookingId;
  static const String routeName = '/customer/service-rating';

  @override
  State<CustomerServiceRatingScreen> createState() =>
      _CustomerServiceRatingScreenState();
}

class _CustomerServiceRatingScreenState
    extends State<CustomerServiceRatingScreen> {
  double _selectedRating = 5.0;
  final TextEditingController _feedbackController = TextEditingController();
  final int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ServiceCompletionProvider>();
      if (provider.completionData == null ||
          provider.completionData!.bookingCode != widget.bookingId) {
        provider.initFromBookingId(
          widget.bookingId,
          status: PaymentStatus.paymentSuccess,
        );
      }
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  String _getRatingLabel(double rating, AppStrings l10n) {
    if (rating >= 5.0) return l10n.ratingStar5;
    if (rating >= 4.0) return l10n.ratingStar4;
    if (rating >= 3.0) return l10n.ratingStar3;
    if (rating >= 2.0) return l10n.ratingStar2;
    return l10n.ratingStar1;
  }

  void _showWarrantyModal(BuildContext context, AppStrings l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.verified_user, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.warrantyModalTitle,
                style: AppTypography.heading(fontSize: 16)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.warrantyModalContent,
          style: AppTypography.body(fontSize: 14)
              .copyWith(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.gotIt, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSupportSheet(BuildContext context, AppStrings l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.headset_mic_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.helpTileTitle,
                        style: AppTypography.heading(fontSize: 18)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.helpTileDesc,
                  style: AppTypography.body(fontSize: 14)
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone, color: AppColors.primary),
                  title: Text(l10n.supportPhoneLabel,
                      style: AppTypography.body(fontSize: 14)
                          .copyWith(fontWeight: FontWeight.w600)),
                  subtitle: const Text('+91 1800 209 8421'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.supportPhoneLabel}: +91 1800 209 8421')),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.chat_bubble_outline, color: AppColors.success),
                  title: Text(l10n.supportWhatsAppLabel,
                      style: AppTypography.body(fontSize: 14)
                          .copyWith(fontWeight: FontWeight.w600)),
                  subtitle: const Text('+91 98220 99999'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.supportWhatsAppLabel}: +91 98220 99999')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.afterServiceTitle,
          style: AppTypography.heading(fontSize: 18)
              .copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.primary),
            onPressed: () => _showSupportSheet(context, l10n),
          ),
          const LanguageSelectorButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ServiceCompletionProvider>(
        builder: (context, provider, _) {
          final data =
              provider.completionData ?? ServiceCompletionModel.mock();
          final isRated = data.paymentStatus == PaymentStatus.rated;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Completion Badge
                _buildHeroCard(l10n),
                const SizedBox(height: 16),

                // 2. Worker Card
                _buildWorkerCard(data, l10n),
                const SizedBox(height: 16),

                // 3. Work Summary Card
                _buildWorkSummaryCard(data, l10n),
                const SizedBox(height: 16),

                // 4. Before / After Photos
                _buildBeforeAfterPhotos(data, l10n),
                const SizedBox(height: 16),

                // 5. Payment Details Card
                _buildPaymentDetailsCard(data, l10n),
                const SizedBox(height: 16),

                // 6. Rating & Review Interactive Section
                _buildRatingCard(data, isRated, provider, l10n),
                const SizedBox(height: 20),

                // 7. Information Cards Grid / List
                _buildInformationCards(data, provider, l10n),
                const SizedBox(height: 24),

                // 8. Go to Home Action
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: Text(l10n.goToHomeBtn),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTypography.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(AppStrings l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 44,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.serviceCompletedTitle,
            style: AppTypography.heading(fontSize: 20)
                .copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.serviceCompletedSubtitle,
            style: AppTypography.body(fontSize: 13)
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(ServiceCompletionModel data, AppStrings l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: NetworkImage(data.workerAvatarUrl),
            onBackgroundImageError: (_, _) {},
            child: const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        data.localizedWorkerName(context),
                        style: AppTypography.heading(fontSize: 15)
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (data.isVerified) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified,
                                color: AppColors.success, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              'Verified',
                              style: AppTypography.body(fontSize: 10).copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  data.localizedServiceSubcategory(context),
                  style: AppTypography.body(fontSize: 12)
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${data.workerRating} (${data.reviewCount} reviews)',
                      style: AppTypography.body(fontSize: 12).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${data.localizedWorkerName(context)} (${data.workerPhone})')),
              );
            },
            icon: const Icon(Icons.phone, color: AppColors.primary, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkSummaryCard(ServiceCompletionModel data, AppStrings l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.workSummaryTitle,
            style: AppTypography.heading(fontSize: 15)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _summaryRow(l10n.problemLabel, l10n.sampleProblemDesc),
          const SizedBox(height: 8),
          _summaryRow(l10n.workDoneLabel, l10n.sampleWorkDoneDesc),
          const SizedBox(height: 8),
          _summaryRow(
              l10n.actualDurationLabel, '${data.actualDurationMinutes} mins'),
          const SizedBox(height: 8),
          _summaryRow(l10n.completionTimeLabel, data.completionTime),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: AppTypography.body(fontSize: 13)
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.body(fontSize: 13)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildBeforeAfterPhotos(ServiceCompletionModel data, AppStrings l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.beforeAfterPhotosTitle,
            style: AppTypography.heading(fontSize: 15)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _photoThumbnail(
                  url: data.beforePhotoUrl,
                  tag: l10n.beforeTag,
                  badgeColor: Colors.grey.shade800,
                  fallbackIcon: Icons.water_drop_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _photoThumbnail(
                  url: data.afterPhotoUrl,
                  tag: l10n.afterTag,
                  badgeColor: AppColors.success,
                  fallbackIcon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photoThumbnail({
    required String url,
    required String tag,
    required Color badgeColor,
    required IconData fallbackIcon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            height: 110,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: Colors.blueGrey.shade100,
                child: Icon(fallbackIcon, size: 36, color: Colors.blueGrey),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: AppTypography.body(fontSize: 10).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(
      ServiceCompletionModel data, AppStrings l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentDetailsTitle,
            style: AppTypography.heading(fontSize: 15)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            l10n.totalAmountLabel,
            AppFormatters.formatPrice(data.totalPrice, context),
          ),
          const SizedBox(height: 8),
          _summaryRow(l10n.paymentMethodLabel, data.paymentMethod),
          const SizedBox(height: 8),
          _summaryRow(l10n.paymentStatusLabel, '✓ ${l10n.paymentSuccessfulBadge}'),
          const SizedBox(height: 8),
          _summaryRow(l10n.invoiceNumberLabel, data.invoiceNumber),
        ],
      ),
    );
  }

  Widget _buildRatingCard(
    ServiceCompletionModel data,
    bool isRated,
    ServiceCompletionProvider provider,
    AppStrings l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRated
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRated ? Icons.check_circle : Icons.star_rate_rounded,
                color: isRated ? AppColors.success : Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.rateWorkerTitle,
                style: AppTypography.heading(fontSize: 16)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isRated) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < data.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 22,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${data.rating.toStringAsFixed(1)} / 5.0',
                        style: AppTypography.body(fontSize: 14)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.ratingSubmittedSuccess,
                    style: AppTypography.body(fontSize: 13).copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (data.reviewComment.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '"${data.reviewComment}"',
                      style: AppTypography.body(fontSize: 13)
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            Text(
              l10n.howWasExperience,
              style: AppTypography.body(fontSize: 14)
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            // Star rating selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1.0;
                final isSelected = _selectedRating >= starVal;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedRating = starVal;
                    });
                  },
                  icon: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isSelected ? Colors.amber : Colors.grey.shade400,
                    size: 38,
                  ),
                );
              }),
            ),
            Center(
              child: Text(
                _getRatingLabel(_selectedRating, l10n),
                style: AppTypography.body(fontSize: 14).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.rateWorkerPrompt(data.localizedWorkerName(context)),
              style: AppTypography.body(fontSize: 13)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            // Textarea feedback
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              maxLength: _maxChars,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.writeFeedbackHint,
                hintStyle: AppTypography.body(fontSize: 13)
                    .copyWith(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isSubmittingRating
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await provider.submitRating(
                          rating: _selectedRating,
                          reviewText: _feedbackController.text.trim(),
                        );
                        if (success) {
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.success,
                              content: Text(l10n.ratingSubmittedSuccess),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: provider.isSubmittingRating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        l10n.submitRatingBtn,
                        style: AppTypography.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInformationCards(
    ServiceCompletionModel data,
    ServiceCompletionProvider provider,
    AppStrings l10n,
  ) {
    return Column(
      children: [
        // 1. Rebook Service Tile
        _infoTile(
          icon: Icons.calendar_month_outlined,
          iconColor: AppColors.primary,
          title: l10n.rebookTileTitle,
          description: l10n.rebookWithWorkerDesc,
          buttonLabel: l10n.rebookTileTitle,
          onTap: () {
            Navigator.pushNamed(context, '/customer/describe-problem');
          },
        ),
        const SizedBox(height: 12),

        // 2. PDF Invoice Download Tile
        _infoTile(
          icon: Icons.picture_as_pdf_outlined,
          iconColor: Colors.deepOrange,
          title: l10n.invoiceTileTitle,
          description: l10n.invoiceTileDesc,
          buttonLabel: l10n.downloadInvoiceBtn,
          isLoading: provider.isDownloadingInvoice,
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            await provider.downloadInvoice();
            messenger.showSnackBar(
              SnackBar(
                backgroundColor: AppColors.success,
                content: Text(l10n.invoiceDownloaded),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // 3. Service Warranty Card
        _infoTile(
          icon: Icons.verified_user_outlined,
          iconColor: AppColors.success,
          title: l10n.serviceWarrantyTitle,
          description: l10n.serviceWarrantyDesc,
          buttonLabel: l10n.moreInfoBtn,
          onTap: () => _showWarrantyModal(context, l10n),
        ),
        const SizedBox(height: 12),

        // 4. Support Contact Card
        _infoTile(
          icon: Icons.support_agent_outlined,
          iconColor: Colors.teal,
          title: l10n.helpTileTitle,
          description: l10n.helpTileDesc,
          buttonLabel: l10n.contactBtn,
          onTap: () => _showSupportSheet(context, l10n),
        ),
        const SizedBox(height: 12),

        // 5. Share Service Card
        _infoTile(
          icon: Icons.share_outlined,
          iconColor: Colors.indigo,
          title: l10n.shareServiceTitle,
          description: l10n.shareServiceDesc,
          buttonLabel: l10n.shareBtn,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sharing SahayogSeva app link...')),
            );
          },
        ),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.heading(fontSize: 14)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.body(fontSize: 12)
                      .copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: isLoading ? null : onTap,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            '$buttonLabel →',
                            style: AppTypography.body(fontSize: 13).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
