import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';
import '../../../models/workspace_role.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/registration_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/edit_profile_dialog.dart';
import '../../../widgets/wallet_top_up_modal.dart';
import '../../../widgets/wallet_transactions_sheet.dart';
import '../../../widgets/workspace_switcher_sheet.dart';

class CustomerProfileView extends StatefulWidget {
  const CustomerProfileView({super.key});

  @override
  State<CustomerProfileView> createState() => _CustomerProfileViewState();
}

class _CustomerProfileViewState extends State<CustomerProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistrationProvider>().loadSavedProfile(WorkspaceRoleId.customer);
      final auth = context.read<AuthProvider>();
      final userId = auth.phoneDigits.isNotEmpty ? auth.phoneDigits : 'CUST-9842';
      context.read<WalletProvider>().refreshWallet(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reg = context.watch<RegistrationProvider>();
    final wallet = context.watch<WalletProvider>();

    final displayName = reg.fullName.isNotEmpty
        ? reg.fullName
        : auth.localizedCustomerName(context);
    final displayPhone = reg.mobile.isNotEmpty
        ? (reg.mobile.length == 10 ? '+91 ${reg.mobile.substring(0, 5)} ${reg.mobile.substring(5)}' : '+91 ${reg.mobile}')
        : (auth.formattedPhone.isNotEmpty ? auth.formattedPhone : '+91 98765 43210');
    final displayEmail = reg.email.isNotEmpty ? reg.email : auth.registeredEmail;
    final displayOrg = reg.organizationName;
    final displayLocation = reg.location;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header Card
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
                  child: Icon(Icons.person, color: AppColors.primary, size: 34),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTypography.heading(fontSize: 18),
                      ),
                      Text(
                        displayPhone,
                        style: AppTypography.subtitle(fontSize: 13),
                      ),
                      if (displayEmail.isNotEmpty)
                        Text(
                          displayEmail,
                          style: AppTypography.subtitle(fontSize: 12).copyWith(color: AppColors.primary),
                        ),
                      if (displayOrg.isNotEmpty || displayLocation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (displayOrg.isNotEmpty) ...[
                              const Icon(Icons.business, size: 13, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  displayOrg,
                                  style: AppTypography.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (displayLocation.isNotEmpty) ...[
                              const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                              const SizedBox(width: 2),
                              Text(
                                displayLocation,
                                style: AppTypography.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => EditProfileSheet.show(context, WorkspaceRoleId.customer),
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Wallet Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('walletBalance'),
                      style: AppTypography.subtitle(fontSize: 12),
                    ),
                    Text(
                      '₹ ${wallet.balance.toStringAsFixed(2)}',
                      style: AppTypography.heading(fontSize: 20).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => WalletTopUpModal.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    context.tr('addMoney'),
                    style: AppTypography.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Settings List
          _tile(
            context,
            Icons.person_outline,
            'Edit Profile Details',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => EditProfileSheet.show(context, WorkspaceRoleId.customer),
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
            Icons.location_on_outlined,
            context.tr('savedAddresses'),
            onTap: () {},
          ),
          _tile(
            context,
            Icons.history,
            context.tr('paymentHistory'),
            onTap: () => WalletTransactionsSheet.show(context),
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
