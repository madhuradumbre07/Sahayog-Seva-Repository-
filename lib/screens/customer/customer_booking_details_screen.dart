import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/worker_matching_model.dart';
import '../../models/booking_request_model.dart';
import '../../providers/booking_flow_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';
import 'customer_booking_confirmation_screen.dart';

class CustomerBookingDetailsScreen extends StatefulWidget {
  const CustomerBookingDetailsScreen({super.key, required this.worker});

  final WorkerMatchModel worker;
  static const String routeName = '/customer/booking-details';

  @override
  State<CustomerBookingDetailsScreen> createState() =>
      _CustomerBookingDetailsScreenState();
}

class _CustomerBookingDetailsScreenState
    extends State<CustomerBookingDetailsScreen> {
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProv = context.read<BookingFlowProvider>();
      bookingProv.initializeForWorker(widget.worker);
    });
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          ctx.tr('helpDialogTitle'),
          style: AppTypography.heading(fontSize: 16)
              .copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          ctx.tr('bookingSecurityBanner'),
          style: AppTypography.body(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              ctx.tr('gotIt'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressPickerModal(BuildContext context) {
    final bookingProv = context.read<BookingFlowProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ctx.tr('addressSection'),
                style: AppTypography.heading(fontSize: 18)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...AddressItem.defaultAddresses.map((addr) {
                final isSelected =
                    bookingProv.draft.selectedAddress.id == addr.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(
                    addr.localizedTitle(ctx),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    addr.localizedAddressLine(ctx),
                    style: AppTypography.subtitle(fontSize: 12),
                  ),
                  onTap: () {
                    bookingProv.updateAddress(addr);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showTimeSlotPickerModal(BuildContext context) {
    final bookingProv = context.read<BookingFlowProvider>();
    DateTime selectedDate = bookingProv.draft.scheduledDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ctx.tr('dateTimeSection'),
                    style: AppTypography.heading(fontSize: 18)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Date chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [0, 1, 2].map((daysAhead) {
                      final date = DateTime.now().add(
                        Duration(days: daysAhead),
                      );
                      final isSelected = selectedDate.day == date.day;
                      final label = AppFormatters.formatRelativeDays(
                        daysAhead,
                        ctx,
                        date,
                      );
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: const Color(0xFFE8F0FE),
                        onSelected: (_) {
                          setModalState(() => selectedDate = date);
                          bookingProv.updateDate(date);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    ctx.tr('availableSlotsTitle'),
                    style: AppTypography.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Slot Grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: BookingTimeSlotItem.defaultSlots.map((slot) {
                      final isSelected =
                          bookingProv.draft.timeSlot == slot.timeLabel;
                      return ChoiceChip(
                        label: Text(
                          slot.timeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: slot.isAvailable
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFFE8F5E9),
                        onSelected: slot.isAvailable
                            ? (_) {
                                bookingProv.updateTimeSlot(slot.timeLabel);
                                Navigator.pop(ctx);
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPriceBreakdownModal(BuildContext context) {
    final booking = context.read<BookingFlowProvider>().draft;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.tr('priceBreakdownTitle'),
              style: AppTypography.heading(fontSize: 18)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 12),
            _priceRow(
              ctx.tr('baseServiceCharge'),
              AppFormatters.formatPrice(booking.basePrice, ctx),
            ),
            _priceRow(
              ctx.tr('coopSupportFee'),
              AppFormatters.formatPrice(booking.cooperativeFee, ctx),
            ),
            _priceRow(
              ctx.tr('promoDiscount'),
              '-${AppFormatters.formatPrice(booking.discountAmount, ctx)}',
              isDiscount: true,
            ),
            const Divider(),
            _priceRow(
              ctx.tr('totalEstimateLabel'),
              AppFormatters.formatPrice(booking.totalPrice, ctx),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.heading(fontSize: 15)
                      .copyWith(fontWeight: FontWeight.bold)
                : AppTypography.body(fontSize: 13),
          ),
          Text(
            value,
            style: isTotal
                ? AppTypography.heading(fontSize: 16).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  )
                : (isDiscount
                      ? const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        )
                      : const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProv = context.watch<BookingFlowProvider>();
    final draft = bookingProv.draft;

    return Scaffold(
      backgroundColor: AppColors.background,
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
          context.tr('bookingDetailsTitle'),
          style: AppTypography.heading(
            fontSize: 17,
          ).copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textPrimary),
            onPressed: () => _showHelpDialog(context),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSelectorButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: Color(0xFF2E7D32), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('bookingSecurityBanner'),
                      style: AppTypography.poppins(
                        fontSize: 11,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 1. Selected Worker Card
            _buildWorkerCard(context),
            const SizedBox(height: 14),

            // 2. Service Summary Card
            _buildServiceSummaryCard(context, draft),
            const SizedBox(height: 14),

            // 3. Location / Address Card
            _buildLocationCard(context, draft),
            const SizedBox(height: 14),

            // 4. Date & Time Selection Card
            _buildDateTimeCard(context, draft),
            const SizedBox(height: 14),

            // 5. Special Instructions
            _buildInstructionsCard(context),
            const SizedBox(height: 14),

            // Price Summary Section
            _buildPriceSummaryContainer(context, draft),
          ],
        ),
      ),
      bottomSheet: _buildBottomProceedBar(context, bookingProv),
    );
  }

  // --- Section 1: Selected Worker Card ---
  Widget _buildWorkerCard(BuildContext context) {
    final activeLocale = Localizations.localeOf(context).languageCode;
    final workerName = widget.worker.localizedName(activeLocale);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('selectedWorkerSection'),
                style: AppTypography.heading(fontSize: 14)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.tr('changeWorkerBtn'),
                  style: AppTypography.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 8),
          const SizedBox(height: 6),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(widget.worker.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workerName,
                      style: AppTypography.heading(fontSize: 15)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.worker.primaryTrade} • ${widget.worker.localizedSociety(context)}',
                      style: AppTypography.subtitle(fontSize: 12),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFA000),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.worker.ratingAvg} (${widget.worker.reviewCount})',
                          style: AppTypography.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${AppFormatters.formatDistance(widget.worker.distanceKm, context)}',
                          style: AppTypography.subtitle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Section 2: Service Summary Card ---
  Widget _buildServiceSummaryCard(
    BuildContext context,
    BookingDraftModel draft,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('serviceSummarySection'),
            style: AppTypography.heading(fontSize: 14)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 12),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.plumbing,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${draft.serviceCategory} - ${draft.serviceSubcategory}',
                      style: AppTypography.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      draft.localizedProblemDescription(context),
                      style: AppTypography.subtitle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Section 3: Location Card ---
  Widget _buildLocationCard(BuildContext context, BookingDraftModel draft) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('addressSection'),
                style: AppTypography.heading(fontSize: 14)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => _showAddressPickerModal(context),
                child: Text(
                  context.tr('changeAddressBtn'),
                  style: AppTypography.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 8),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_pin, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.selectedAddress.localizedTitle(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      draft.selectedAddress.localizedAddressLine(context),
                      style: AppTypography.subtitle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Section 4: Date & Time Card ---
  Widget _buildDateTimeCard(BuildContext context, BookingDraftModel draft) {
    final date = draft.scheduledDate;
    final dateFormatted = AppFormatters.formatDate(
      date,
      Localizations.localeOf(context),
    );

    return InkWell(
      onTap: () => _showTimeSlotPickerModal(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('dateTimeSection'),
                  style: AppTypography.heading(fontSize: 14)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const Divider(height: 12),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$dateFormatted • ${draft.timeSlot}',
                        style: AppTypography.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        context.tr('selectSlotBtn'),
                        style: AppTypography.subtitle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Section 5: Special Instructions ---
  Widget _buildInstructionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('instructionsSection'),
            style: AppTypography.heading(fontSize: 14)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _instructionsController,
            maxLength: 250,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.tr('instructionsPlaceholder'),
              hintStyle: AppTypography.subtitle(fontSize: 12),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onChanged: (val) {
              context.read<BookingFlowProvider>().updateInstructions(val);
            },
          ),
        ],
      ),
    );
  }

  // --- Price Breakdown Container ---
  Widget _buildPriceSummaryContainer(
    BuildContext context,
    BookingDraftModel draft,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('priceBreakdownTitle'),
                style: AppTypography.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () => _showPriceBreakdownModal(context),
                child: Text(
                  context.tr('viewDetailsBtn'),
                  style: AppTypography.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _priceRow(
            context.tr('baseServiceCharge'),
            AppFormatters.formatPrice(draft.basePrice, context),
          ),
          _priceRow(
            context.tr('coopSupportFee'),
            AppFormatters.formatPrice(draft.cooperativeFee, context),
          ),
          _priceRow(
            context.tr('promoDiscount'),
            '-${AppFormatters.formatPrice(draft.discountAmount, context)}',
            isDiscount: true,
          ),
          const Divider(),
          _priceRow(
            context.tr('totalEstimateLabel'),
            AppFormatters.formatPrice(draft.totalPrice, context),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  // --- Bottom Proceed Bar ---
  Widget _buildBottomProceedBar(
    BuildContext context,
    BookingFlowProvider bookingProv,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('totalEstimateLabel'),
                style: AppTypography.subtitle(fontSize: 10),
              ),
              Text(
                AppFormatters.formatPrice(
                  bookingProv.draft.totalPrice,
                  context,
                ),
                style: AppTypography.heading(fontSize: 18).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: bookingProv.isSubmitting
                  ? null
                  : () async {
                      final ok = await bookingProv.submitBooking();
                      if (ok && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerBookingConfirmationScreen(
                              booking: bookingProv.draft,
                            ),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: bookingProv.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      context.tr('proceedConfirmationBtn'),
                      style: AppTypography.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
