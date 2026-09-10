import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/notification_model.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final userId = auth.phoneDigits.isNotEmpty ? auth.phoneDigits : 'CUST-9842';
      context.read<NotificationProvider>().loadNotifications(userId);
    });
  }

  IconData _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'BOOKING':
        return Icons.event_available;
      case 'WALLET':
        return Icons.account_balance_wallet_outlined;
      case 'ALERT':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_none;
    }
  }

  Color _colorForType(String type) {
    switch (type.toUpperCase()) {
      case 'BOOKING':
        return AppColors.primary;
      case 'WALLET':
        return const Color(0xFF2E7D32);
      case 'ALERT':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFF1976D2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProv = context.watch<NotificationProvider>();
    final notifications = notifProv.notifications;
    final auth = context.read<AuthProvider>();
    final userId = auth.phoneDigits.isNotEmpty ? auth.phoneDigits : 'CUST-9842';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('notifications', fallback: 'Notifications'),
                      style: AppTypography.heading(fontSize: 18),
                    ),
                    if (notifProv.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${notifProv.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                if (notifications.any((n) => !n.isRead))
                  TextButton(
                    onPressed: () => notifProv.markAllAsRead(userId),
                    child: Text(
                      context.tr('markAllRead', fallback: 'Mark all as read'),
                      style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Notification List
          Flexible(
            child: notifProv.isLoading && notifications.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : notifications.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                context.tr('noNotifications', fallback: 'No notifications yet'),
                                style: AppTypography.heading(fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                context.tr('noNotificationsDesc', fallback: 'Updates on your bookings and wallet will show up here.'),
                                style: AppTypography.subtitle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: n.isRead ? Colors.white : const Color(0xFFF4F8FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: n.isRead ? Colors.grey.shade200 : const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              leading: CircleAvatar(
                                backgroundColor: _colorForType(n.type).withValues(alpha: 0.12),
                                child: Icon(_iconForType(n.type), color: _colorForType(n.type), size: 20),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: AppTypography.poppins(
                                        fontSize: 13,
                                        fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  n.message,
                                  style: AppTypography.subtitle(fontSize: 12).copyWith(
                                    color: n.isRead ? const Color(0xFF64748B) : Colors.black87,
                                  ),
                                ),
                              ),
                              onTap: () {
                                notifProv.markAsRead(n.id);
                                if (n.relatedId != null && n.relatedId!.isNotEmpty) {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/customer/track-service',
                                    arguments: n.relatedId,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
