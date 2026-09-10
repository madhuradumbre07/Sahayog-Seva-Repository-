import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';
import '../../../models/customer_dashboard_data.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_dashboard_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class CustomerBookingsView extends StatefulWidget {
  const CustomerBookingsView({super.key});

  @override
  State<CustomerBookingsView> createState() => _CustomerBookingsViewState();
}

class _CustomerBookingsViewState extends State<CustomerBookingsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    final customerId = auth.phoneDigits.isNotEmpty ? auth.phoneDigits : 'CUST-9842';
    await context.read<CustomerDashboardProvider>().loadCustomerData(customerId);
  }

  void _confirmCancelBooking(BuildContext context, BookingItem booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(context.tr('cancelBookingTitle', fallback: 'Cancel Booking?')),
        content: Text(
          context.tr('cancelBookingConfirm', params: {'code': booking.bookingCode}, fallback: 'Are you sure you want to cancel booking ${booking.bookingCode}?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('keepBooking', fallback: 'Keep Booking')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<CustomerDashboardProvider>().cancelBooking(booking.id.isNotEmpty ? booking.id : booking.bookingCode);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? context.tr('bookingCancelledSuccess', fallback: 'Booking cancelled successfully.')
                          : context.tr('cancellationFailed', fallback: 'Failed to cancel booking.'),
                    ),
                    backgroundColor: success ? Colors.black87 : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(context.tr('cancelBooking', fallback: 'Cancel Booking')),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.accepted:
        return const Color(0xFF1976D2);
      case BookingStatus.onTheWay:
        return const Color(0xFFF57C00);
      case BookingStatus.upcoming:
        return const Color(0xFF7B1FA2);
      case BookingStatus.completed:
        return const Color(0xFF2E7D32);
      case BookingStatus.cancelled:
        return Colors.red.shade700;
    }
  }

  Color _statusBgColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.accepted:
        return const Color(0xFFE3F2FD);
      case BookingStatus.onTheWay:
        return const Color(0xFFFFF3E0);
      case BookingStatus.upcoming:
        return const Color(0xFFF3E5F5);
      case BookingStatus.completed:
        return const Color(0xFFE8F5E9);
      case BookingStatus.cancelled:
        return const Color(0xFFFFEBEE);
    }
  }

  String _statusLabel(BuildContext context, BookingStatus status) {
    switch (status) {
      case BookingStatus.accepted:
        return context.tr('statusAccepted');
      case BookingStatus.onTheWay:
        return context.tr('statusOnTheWay');
      case BookingStatus.upcoming:
        return context.tr('statusServiceStarted', fallback: 'In Progress');
      case BookingStatus.completed:
        return context.tr('statusCompleted');
      case BookingStatus.cancelled:
        return context.tr('statusCancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerDashboardProvider>();
    final activeList = prov.activeBookings;
    final pastList = prov.pastBookings;

    // If activeList is empty but activeBooking is set (e.g. from initial mock/single booking), include it
    final displayActive = activeList.isNotEmpty
        ? activeList
        : (prov.activeBooking != null && prov.activeBooking!.status != BookingStatus.completed && prov.activeBooking!.status != BookingStatus.cancelled
            ? [prov.activeBooking!]
            : <BookingItem>[]);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('myBookings'),
                  style: AppTypography.heading(fontSize: 22),
                ),
                if (prov.isLoadingBookings)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade700,
              labelStyle: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.tr('activeBookingsTab', fallback: 'Active')),
                      if (displayActive.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${displayActive.length}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(text: context.tr('historyTab', fallback: 'History')),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveList(context, displayActive),
                _buildPastList(context, pastList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveList(BuildContext context, List<BookingItem> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 52, color: Colors.grey.shade400),
              const SizedBox(height: 14),
              Text(
                context.tr('noActiveBookings', fallback: 'No active bookings'),
                style: AppTypography.heading(fontSize: 17),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('noActiveBookingsDesc', fallback: 'Need help? Describe your problem with AI or pick a service.'),
                style: AppTypography.subtitle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/customer/describe-problem');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(context.tr('bookServiceNow', fallback: 'Book a Service')),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16).copyWith(bottom: 90),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(context, booking, isActive: true);
      },
    );
  }

  Widget _buildPastList(BuildContext context, List<BookingItem> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 52, color: Colors.grey.shade400),
              const SizedBox(height: 14),
              Text(
                context.tr('noPastBookings', fallback: 'No past booking history'),
                style: AppTypography.heading(fontSize: 17),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('noPastBookingsDesc', fallback: 'Completed and past bookings will appear here.'),
                style: AppTypography.subtitle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16).copyWith(bottom: 90),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(context, booking, isActive: false);
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingItem booking, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Code & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.bookingCode,
                style: AppTypography.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor(booking.status),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusColor(booking.status).withValues(alpha: 0.4)),
                ),
                child: Text(
                  _statusLabel(context, booking.status),
                  style: AppTypography.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(booking.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Service title & address
          Text(
            context.tr(booking.serviceTitleKey),
            style: AppTypography.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                '${booking.dateText} • ${booking.timeText}',
                style: AppTypography.subtitle(fontSize: 12),
              ),
              const Spacer(),
              Text(
                '₹${booking.price}',
                style: AppTypography.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Worker Info
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE8F0FE),
                child: const Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.workerName,
                      style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      context.tr(booking.workerTradeKey),
                      style: AppTypography.subtitle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFA000), size: 13),
                    const SizedBox(width: 3),
                    Text(
                      booking.workerRating.toString(),
                      style: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFE65100)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action Buttons
          const SizedBox(height: 14),
          if (isActive) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmCancelBooking(context, booking),
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                    label: Text(
                      context.tr('cancel', fallback: 'Cancel'),
                      style: AppTypography.poppins(fontSize: 12, color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final trackCode = booking.bookingCode.isNotEmpty ? booking.bookingCode : booking.id;
                      Navigator.pushNamed(
                        context,
                        '/customer/track-service',
                        arguments: trackCode,
                      );
                    },
                    icon: const Icon(Icons.navigation_outlined, size: 16),
                    label: Text(
                      context.tr('trackService', fallback: 'Track Service'),
                      style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            if (booking.status == BookingStatus.completed)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final trackCode = booking.bookingCode.isNotEmpty ? booking.bookingCode : booking.id;
                    Navigator.pushNamed(
                      context,
                      '/customer/service-rating',
                      arguments: trackCode,
                    );
                  },
                  icon: const Icon(Icons.star_outline, size: 16, color: AppColors.primary),
                  label: Text(
                    context.tr('rateWorker', fallback: 'Rate & Review Worker'),
                    style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
