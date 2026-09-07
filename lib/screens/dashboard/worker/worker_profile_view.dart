import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';
import '../../../models/workspace_role.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/registration_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/edit_profile_dialog.dart';
import '../../../widgets/workspace_switcher_sheet.dart';

class WorkerProfileView extends StatefulWidget {
  const WorkerProfileView({super.key});

  @override
  State<WorkerProfileView> createState() => _WorkerProfileViewState();
}

class _WorkerProfileViewState extends State<WorkerProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistrationProvider>().loadSavedProfile(WorkspaceRoleId.worker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reg = context.watch<RegistrationProvider>();

    final displayName = reg.fullName.isNotEmpty
        ? reg.fullName
        : auth.localizedWorkerName(context);
    final displayPhone = reg.mobile.isNotEmpty
        ? (reg.mobile.length == 10 ? '+91 ${reg.mobile.substring(0, 5)} ${reg.mobile.substring(5)}' : '+91 ${reg.mobile}')
        : (auth.formattedPhone.isNotEmpty ? auth.formattedPhone : '+91 98765 43210');
    final displayCategory = reg.workCategory.isNotEmpty
        ? reg.effectiveWorkCategory
        : auth.localizedWorkerTradeSubtitle(context);
    final displayLocation = reg.location;
    final displayEmail = reg.email.isNotEmpty ? reg.email : auth.registeredEmail;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE8F0FE),
                  child: Icon(Icons.handyman, color: AppColors.primary, size: 34),
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
                              displayName,
                              style: AppTypography.heading(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              context.tr('workerVerified'),
                              style: AppTypography.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        displayPhone,
                        style: AppTypography.subtitle(fontSize: 12),
                      ),
                      Text(
                        displayCategory,
                        style: AppTypography.subtitle(fontSize: 13).copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      if (displayEmail.isNotEmpty || displayLocation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (displayLocation.isNotEmpty) ...[
                              const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                              const SizedBox(width: 2),
                              Text(
                                displayLocation,
                                style: AppTypography.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (displayEmail.isNotEmpty) ...[
                              const Icon(Icons.email_outlined, size: 13, color: Color(0xFF64748B)),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  displayEmail,
                                  style: AppTypography.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFA000), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('workerRating'),
                            style: AppTypography.subtitle(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => EditProfileSheet.show(context, WorkspaceRoleId.worker),
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Actions List
          _tile(
            context,
            Icons.person_outline,
            'Edit Profile Details',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => EditProfileSheet.show(context, WorkspaceRoleId.worker),
            highlight: false,
          ),
          _tile(
            context,
            Icons.swap_horiz,
            context.tr('switchWorkspace'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => WorkspaceSwitcherSheet.show(context),
            highlight: true,
          ),
          _tile(
            context,
            Icons.account_balance_wallet_outlined,
            context.tr('payouts'),
            onTap: () {},
          ),
          _tile(
            context,
            Icons.help_outline,
            context.tr('supportHelp'),
            onTap: () {},
          ),
          _tile(
            context,
            Icons.logout,
            context.tr('logout'),
            color: Colors.red,
            onTap: () async {
              context.read<RegistrationProvider>().reset();
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
    bool highlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE8F0FE) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? AppColors.primary : Colors.grey.shade200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Icon(icon, color: color ?? AppColors.primary),
          title: Text(
            title,
            style: AppTypography.poppins(
              fontSize: 14,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
          trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
          onTap: onTap,
        ),
      ),
    );
  }
}

