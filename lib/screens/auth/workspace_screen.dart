import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/workspace_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/handshake_logo.dart';
import '../../widgets/language_selector_button.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_views.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  static const String routeName = '/workspace-selection';

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  bool _showError = false;
  bool _saving = false;

  Future<void> _getStarted() async {
    final auth = context.read<AuthProvider>();
    if (!auth.hasSelectedRole) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _saving = true);
    await auth.persistRoles();
    if (!mounted) return;

    // Bypass registration if user is already registered for this active role
    if (auth.isCurrentRoleRegistered) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushNamed(context, '/role-registration');
    }
    setState(() => _saving = false);
  }

  void _showRoleInfo(WorkspaceRole role) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(role.icon, size: 40, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(role.title(context), style: AppTypography.heading(fontSize: 20)),
              const SizedBox(height: 8),
              Text(
                role.info(context),
                textAlign: TextAlign.center,
                style: AppTypography.subtitle(),
              ),
              if (role.needsVerification) ...[
                const SizedBox(height: 12),
                Text(
                  context.tr('verificationRequired'),
                  style: AppTypography.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: context.tr('gotIt'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final language = context.watch<LanguageProvider>();

    if (!language.isOnline) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: NetworkErrorView(
          onTryAgain: () => language.checkConnectivity(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  const HandshakeLogo(size: 40),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('brandName'),
                    style: AppTypography.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  const LanguageSelectorButton(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  Text(
                    context.tr('chooseWorkspace'),
                    style: AppTypography.heading(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('chooseWorkspaceSubtitle'),
                    style: AppTypography.subtitle(),
                  ),
                  const SizedBox(height: 16),
                  if (_showError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        context.tr('selectWorkspaceError'),
                        style: AppTypography.poppins(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ...WorkspaceRole.all.map((role) {
                    final selected = auth.isRoleSelected(role.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RoleCard(
                        role: role,
                        selected: selected,
                        onTap: () {
                          auth.toggleRole(role.id);
                          setState(() => _showError = false);
                        },
                        onInfo: () => _showRoleInfo(role),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  PrimaryButton(
                    label: context.tr('getStarted'),
                    enabled: auth.hasSelectedRole,
                    allowTapWhenDisabled: true,
                    loading: _saving,
                    onPressed: _getStarted,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.settings, size: 16, color: AppColors.subtitle),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          context.tr('changeLater'),
                          style: AppTypography.poppins(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SecurityBadge(label: context.tr('dataSecure')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
    required this.onInfo,
  });

  final WorkspaceRole role;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardFill,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Icon(role.icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      role.title(context),
                      style: AppTypography.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onInfo,
                    icon: const Icon(Icons.info_outline, color: AppColors.primary),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 6),
              Text(role.desc(context), style: AppTypography.subtitle(fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final feature in role.features(context).split('•'))
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          feature.trim(),
                          style: AppTypography.poppins(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (selected && role.needsVerification) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(
                    context.tr('verificationRequired'),
                    style: AppTypography.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

