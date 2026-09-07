import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import '../../models/booking_request_model.dart';
import '../../models/booking_tracking_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';
import 'customer_track_service_screen.dart';

class CustomerBookingConfirmationScreen extends StatelessWidget {
  const CustomerBookingConfirmationScreen({
    super.key,
    required this.booking,
    this.initialState = BookingConfirmationState.confirmed,
  });

  final BookingDraftModel booking;
  final BookingConfirmationState initialState;
  static const String routeName = '/customer/booking-confirmation';

  void _showPaymentBreakdownSheet(BuildContext context, AppStrings l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.paymentBreakdownTitle,
                style: AppTypography.heading(fontSize: 18)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _summaryRow(
                l10n.priceBaseLabel,
                AppFormatters.formatPrice(booking.basePrice, ctx),
              ),
              const SizedBox(height: 12),
              _summaryRow(
                l10n.priceCoopFeeLabel,
                AppFormatters.formatPrice(booking.cooperativeFee, ctx),
              ),
              const SizedBox(height: 12),
              _summaryRow(
                l10n.priceDiscountLabel,
                '-${AppFormatters.formatPrice(booking.discountAmount, ctx)}',
                isBold: true,
                valueColor: AppColors.success,
              ),
              const Divider(height: 32),
              _summaryRow(
                l10n.priceTotalLabel,
                AppFormatters.formatPrice(booking.totalPrice, ctx),
                isBold: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    ctx.tr('close'),
                    style: AppTypography.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancellationPolicySheet(BuildContext context, AppStrings l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cancellationPolicyTitle,
                style: AppTypography.heading(fontSize: 18)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.cancellationPolicyBody,
                style: AppTypography.body(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    ctx.tr('close'),
                    style: AppTypography.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.supportTitle,
                style: AppTypography.heading(fontSize: 18)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.primary),
                title: Text(
                  l10n.supportPhoneLabel,
                  style: AppTypography.body(fontSize: 14),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: AppColors.success),
                title: Text(
                  l10n.supportWhatsAppLabel,
                  style: AppTypography.body(fontSize: 14),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStateCard(BuildContext context, AppStrings l10n) {
    switch (initialState) {
      case BookingConfirmationState.processing:
        return _buildAlertCard(
          icon: Icons.access_time_filled,
          iconColor: AppColors.warning,
          title: l10n.bookingProcessingTitle,
          subtitle: l10n.bookingProcessingSub,
        );
      case BookingConfirmationState.incomplete:
        return _buildAlertCard(
          icon: Icons.warning_rounded,
          iconColor: Colors.orange,
          title: l10n.bookingIncompleteTitle,
          subtitle: l10n.bookingIncompleteSub,
        );
      case BookingConfirmationState.offline:
        return _buildAlertCard(
          icon: Icons.wifi_off_rounded,
          iconColor: AppColors.muted,
          title: l10n.bookingOfflineTitle,
          subtitle: l10n.noInternetBody,
        );
      case BookingConfirmationState.cancelled:
        return _buildAlertCard(
          icon: Icons.cancel,
          iconColor: AppColors.error,
          title: l10n.bookingCancelledTitle,
          subtitle: l10n.cancellationPolicyBody,
        );
      case BookingConfirmationState.confirmed:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.heading(fontSize: 20)
                .copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTypography.subtitle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = Localizations.localeOf(context);
    final l10n = AppStrings.of(context);
    final workerName =
        booking.worker?.localizedName(activeLocale.languageCode) ??
        l10n.workerAssignedLabel;
    final code = booking.bookingCode ?? 'SHS-842109';
    final isConfirmed = initialState == BookingConfirmationState.confirmed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isConfirmed ? l10n.bookingConfirmTitle : l10n.bookingProcessingTitle,
          style: AppTypography.heading(
            fontSize: 17,
          ).copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showSupportSheet(context, l10n),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSelectorButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (isConfirmed) ...[
              // Hero Green Checkmark
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8F5E9),
                  border: Border.all(color: const Color(0xFF81C784), width: 2),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 54,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                l10n.bookingConfirmedHero,
                style: AppTypography.heading(fontSize: 22).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.bookingConfirmedSub,
                style: AppTypography.subtitle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ] else ...[
              _buildStateCard(context, l10n),
            ],

            // Booking ID Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.bookingIdLabel,
                        style: AppTypography.subtitle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        code,
                        style: AppTypography.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy_outlined,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.copiedToClipboard)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Worker Mini Card
            if (booking.worker != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: booking.worker!.avatarUrl.isNotEmpty
                          ? NetworkImage(booking.worker!.avatarUrl)
                          : null,
                      child: booking.worker!.avatarUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                workerName,
                                style: AppTypography.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          Text(
                            booking.worker!.localizedTradeSubtitle(context),
                            style: AppTypography.subtitle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.worker!.ratingAvg.toStringAsFixed(1),
                            style: AppTypography.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Booking Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    l10n.serviceLabel,
                    '${booking.localizedServiceName(context)} - ${booking.localizedSubcategory(context)}',
                  ),
                  const Divider(height: 24),
                  _summaryRow(
                    l10n.dateLabel,
                    AppFormatters.formatDate(
                      booking.scheduledDate,
                      activeLocale,
                    ),
                  ),
                  const Divider(height: 24),
                  _summaryRow(l10n.slotLabel, booking.timeSlot),
                  const Divider(height: 24),
                  _summaryRow(
                    l10n.addressLabel,
                    booking.selectedAddress.localizedAddressLine(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Price Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    l10n.estCostLabel,
                    AppFormatters.formatPriceRange(
                      booking.basePrice,
                      booking.basePrice + 200,
                      context,
                    ),
                    isBold: true,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _showPaymentBreakdownSheet(context, l10n),
                    child: Text(
                      l10n.viewBreakdownLink,
                      style: AppTypography.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notice Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC5E1A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFF558B2F)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.securityBadge,
                      style: AppTypography.subtitle(fontSize: 12)
                          .copyWith(color: const Color(0xFF33691E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // CTAs
            if (isConfirmed ||
                initialState == BookingConfirmationState.processing) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    CustomerTrackServiceScreen.routeName,
                    arguments: booking.bookingCode,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.trackServiceBtn,
                  style: AppTypography.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            OutlinedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.goToHomeBtn,
                style: AppTypography.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () => _showCancellationPolicySheet(context, l10n),
              child: Text(
                l10n.cancellationPolicyTitle,
                style: AppTypography.subtitle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTypography.subtitle(fontSize: 13)),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTypography.poppins(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color:
                  valueColor ??
                  (isBold ? AppColors.textPrimary : AppColors.textPrimary),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
