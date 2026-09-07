import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/service_completion_model.dart';
import '../../providers/service_completion_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';
import 'customer_service_rating_screen.dart';

class CustomerServiceCompletionScreen extends StatefulWidget {
  const CustomerServiceCompletionScreen({
    super.key,
    this.bookingId = 'SHS-842109',
  });

  final String bookingId;
  static const String routeName = '/customer/service-completion';

  @override
  State<CustomerServiceCompletionScreen> createState() =>
      _CustomerServiceCompletionScreenState();
}

class _CustomerServiceCompletionScreenState
    extends State<CustomerServiceCompletionScreen> {
  PaymentMethodType _selectedPaymentMethod = PaymentMethodType.upiGpay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ServiceCompletionProvider>();
      if (provider.completionData == null ||
          provider.completionData!.bookingCode != widget.bookingId) {
        provider.initFromBookingId(widget.bookingId);
      }
    });
  }

  void _showHelpSupportSheet(BuildContext context, AppStrings l10n) {
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

  void _showBreakdownSheet(
      BuildContext context, ServiceCompletionModel data, AppStrings l10n) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.billSummaryTitle,
                      style: AppTypography.heading(fontSize: 18)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _breakdownRow(
                  l10n.baseAmountLabel,
                  AppFormatters.formatPrice(data.basePrice, ctx),
                ),
                const SizedBox(height: 10),
                _breakdownRow(
                  l10n.materialsCostLabel,
                  AppFormatters.formatPrice(data.materialsCost, ctx),
                ),
                const SizedBox(height: 10),
                _breakdownRow(
                  l10n.serviceFeeLabel,
                  AppFormatters.formatPrice(data.platformFee, ctx),
                ),
                const SizedBox(height: 10),
                _breakdownRow(
                  l10n.discountLabel,
                  '-${AppFormatters.formatPrice(data.discountAmount, ctx)}',
                  valueColor: AppColors.success,
                  isBold: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(),
                ),
                _breakdownRow(
                  l10n.totalAmountLabel,
                  AppFormatters.formatPrice(data.totalPrice, ctx),
                  isBold: true,
                  fontSize: 17,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.close,
                      style: AppTypography.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentModal(
      BuildContext context, ServiceCompletionModel data, AppStrings l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.paymentModalTitle,
                          style: AppTypography.heading(fontSize: 18)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.totalAmountLabel}: ${AppFormatters.formatPrice(data.totalPrice, modalCtx)}',
                      style: AppTypography.subtitle(fontSize: 15).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...PaymentMethodType.values.map((method) {
                      final isSelected = _selectedPaymentMethod == method;
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            _selectedPaymentMethod = method;
                          });
                          setState(() {});
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                method.icon,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  method.label,
                                  style: AppTypography.body(fontSize: 15).copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Consumer<ServiceCompletionProvider>(
                      builder: (c, provider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.isProcessingPayment
                                ? null
                                : () async {
                                    final nav = Navigator.of(modalCtx);
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final success = await context
                                        .read<ServiceCompletionProvider>()
                                        .processPayment(
                                          paymentMethod:
                                              _selectedPaymentMethod.label,
                                        );
                                    if (success) {
                                      nav.pop();
                                      messenger.showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.success,
                                          content: Text(
                                              l10n.paymentSuccessfulBadge),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: provider.isProcessingPayment
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Text(
                                    '${l10n.payNowBtn} • ${AppFormatters.formatPrice(data.totalPrice, modalCtx)}',
                                    style: AppTypography.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _breakdownRow(String label, String value,
      {bool isBold = false, Color? valueColor, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body(fontSize: fontSize).copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.body(fontSize: fontSize).copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
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
          l10n.serviceCompletionTitle,
          style: AppTypography.heading(fontSize: 18)
              .copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.primary),
            onPressed: () => _showHelpSupportSheet(context, l10n),
          ),
          const LanguageSelectorButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ServiceCompletionProvider>(
        builder: (context, provider, _) {
          final data =
              provider.completionData ?? ServiceCompletionModel.mock();
          final isPaymentSuccess =
              data.paymentStatus == PaymentStatus.paymentSuccess ||
                  data.paymentStatus == PaymentStatus.rated;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Completion Badge
                _buildHeroCompletionBadge(l10n),
                const SizedBox(height: 16),

                // 2. Worker Info Card
                _buildWorkerCard(data, l10n),
                const SizedBox(height: 16),

                // 3. Service Details & Price Summary Card
                _buildServiceDetailsCard(data, l10n),
                const SizedBox(height: 16),

                // 4. Before / After Photos Grid
                _buildBeforeAfterPhotos(data, l10n),
                const SizedBox(height: 16),

                // 5. Materials Used & Duration Cards
                _buildMaterialsAndDuration(data, l10n),
                const SizedBox(height: 16),

                // 6. Payment Status / Info Card
                if (isPaymentSuccess) _buildPaymentInfoCard(data, l10n),
                const SizedBox(height: 24),

                // 7. Action CTA Section
                _buildActionButtons(data, isPaymentSuccess, provider, l10n),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCompletionBadge(AppStrings l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 52,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.serviceCompletedTitle,
            style: AppTypography.heading(fontSize: 22)
                .copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.serviceCompletedSubtitle,
            style: AppTypography.body(fontSize: 14)
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
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: NetworkImage(data.workerAvatarUrl),
            onBackgroundImageError: (_, _) {},
            child: const Icon(Icons.person, color: AppColors.primary, size: 30),
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
                        style: AppTypography.heading(fontSize: 16)
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
                  style: AppTypography.body(fontSize: 13)
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
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
            icon: const Icon(Icons.phone, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard(
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
            l10n.serviceDetailsTitle,
            style: AppTypography.heading(fontSize: 16)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dateTimeLabel,
                      style: AppTypography.body(fontSize: 12)
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.scheduledDate}\n${data.scheduledTimeSlot}',
                      style: AppTypography.body(fontSize: 14)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addressLabel,
                      style: AppTypography.body(fontSize: 12)
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.customerAddress,
                      style: AppTypography.body(fontSize: 13)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.totalAmountLabel,
                    style: AppTypography.body(fontSize: 12)
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    AppFormatters.formatPrice(data.totalPrice, context),
                    style: AppTypography.heading(fontSize: 20).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showBreakdownSheet(context, data, l10n),
                icon: const Icon(Icons.receipt_long, size: 16),
                label: Text(
                  l10n.viewBreakdownBtn,
                  style: AppTypography.body(fontSize: 14)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
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
            style: AppTypography.heading(fontSize: 16)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _photoComparisonCard(
                  url: data.beforePhotoUrl,
                  tag: l10n.beforeTag,
                  badgeColor: Colors.grey.shade800,
                  fallbackIcon: Icons.water_drop_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _photoComparisonCard(
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

  Widget _photoComparisonCard({
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
            height: 130,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: Colors.blueGrey.shade100,
                child: Icon(fallbackIcon, size: 40, color: Colors.blueGrey),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tag,
                style: AppTypography.body(fontSize: 11).copyWith(
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

  Widget _buildMaterialsAndDuration(
      ServiceCompletionModel data, AppStrings l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Materials used
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.handyman_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.materialsUsedTitle,
                        style: AppTypography.heading(fontSize: 13)
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...data.materialsUsed.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            m.name,
                            style: AppTypography.body(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${m.quantity} ${l10n.unitNos}',
                          style: AppTypography.body(fontSize: 12).copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Duration
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.serviceDurationTitle,
                        style: AppTypography.heading(fontSize: 13)
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${l10n.totalDurationLabel}: ${data.actualDurationMinutes} mins',
                  style: AppTypography.body(fontSize: 12)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.startTimeLabel}: 11:00 AM',
                  style: AppTypography.body(fontSize: 12)
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.endTimeLabel}: 11:45 AM',
                  style: AppTypography.body(fontSize: 12)
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoCard(ServiceCompletionModel data, AppStrings l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.paymentSuccessfulBadge,
                    style: AppTypography.heading(fontSize: 15).copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                AppFormatters.formatPrice(data.totalPrice, context),
                style: AppTypography.heading(fontSize: 16).copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${data.paymentMethod} • ${l10n.txnIdLabel}: ${data.txnId}',
            style: AppTypography.body(fontSize: 13)
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.dateLabel}: ${data.completionTime}',
            style: AppTypography.body(fontSize: 12)
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    ServiceCompletionModel data,
    bool isPaymentSuccess,
    ServiceCompletionProvider provider,
    AppStrings l10n,
  ) {
    if (!isPaymentSuccess) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showPaymentModal(context, data, l10n),
          icon: const Icon(Icons.payment),
          label: Text(l10n.proceedToPaymentBtn),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                AppTypography.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Primary CTA: Rate Experience
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                CustomerServiceRatingScreen.routeName,
                arguments: data.bookingCode,
              );
            },
            icon: const Icon(Icons.star_rate),
            label: Text(l10n.rateExperienceBtn),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: AppTypography.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Secondary CTA: Download Invoice
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: provider.isDownloadingInvoice
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await provider.downloadInvoice();
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.success,
                        content: Text(l10n.invoiceDownloaded),
                      ),
                    );
                  },
            icon: provider.isDownloadingInvoice
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download, color: AppColors.primary),
            label: Text(l10n.downloadInvoiceBtn),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: AppTypography.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
