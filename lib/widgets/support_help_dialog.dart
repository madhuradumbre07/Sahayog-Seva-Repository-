import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SupportHelpDialog extends StatelessWidget {
  const SupportHelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const SupportHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.support_agent, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('supportHelp', fallback: 'Support & Help'),
                      style: AppTypography.heading(fontSize: 18),
                    ),
                    Text(
                      context.tr('supportSub', fallback: 'Sahayog Workers Cooperative Care'),
                      style: AppTypography.subtitle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Helpline tile
          _infoTile(
            context,
            icon: Icons.phone_in_talk,
            title: 'Toll-Free Helpline (24/7)',
            value: '1800-209-4242',
            onTap: () {
              Clipboard.setData(const ClipboardData(text: '18002094242'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Helpline number copied to clipboard')),
              );
            },
          ),
          const SizedBox(height: 10),

          // WhatsApp tile
          _infoTile(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'WhatsApp Assistant',
            value: '+91 98220 12345',
            onTap: () {
              Clipboard.setData(const ClipboardData(text: '+919822012345'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('WhatsApp number copied to clipboard')),
              );
            },
          ),
          const SizedBox(height: 10),

          // Office address tile
          _infoTile(
            context,
            icon: Icons.business,
            title: 'Cooperative Care Desk',
            value: 'Sahayog Bhavan, Warje, Pune - 411058',
            subtitle: 'Fair grievance redressal & verified worker assurance',
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(context.tr('close', fallback: 'Close')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(title, style: AppTypography.subtitle(fontSize: 11)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: AppTypography.subtitle(fontSize: 10),
              ),
          ],
        ),
        trailing: onTap != null
            ? IconButton(
                icon: const Icon(Icons.copy, size: 16, color: AppColors.primary),
                onPressed: onTap,
                tooltip: 'Copy',
              )
            : null,
      ),
    );
  }
}
