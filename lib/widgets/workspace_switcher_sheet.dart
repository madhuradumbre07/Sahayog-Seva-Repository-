import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/workspace_role.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WorkspaceSwitcherSheet extends StatefulWidget {
  const WorkspaceSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WorkspaceSwitcherSheet(),
    );
  }

  @override
  State<WorkspaceSwitcherSheet> createState() => _WorkspaceSwitcherSheetState();
}

class _WorkspaceSwitcherSheetState extends State<WorkspaceSwitcherSheet> {
  late WorkspaceRoleId _selectedRole;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _selectedRole = auth.activeRole;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final activeRole = auth.activeRole;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_horiz,
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
                      context.tr('switchWorkspace'),
                      style: AppTypography.heading(fontSize: 18),
                    ),
                    Text(
                      context.tr('switchWorkspaceDesc'),
                      style: AppTypography.subtitle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Role selection cards
          for (final role in WorkspaceRole.all) ...[
            GestureDetector(
              onTap: () {
                setState(() => _selectedRole = role.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: role.id == _selectedRole
                      ? const Color(0xFFE8F0FE)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: role.id == _selectedRole
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    width: role.id == _selectedRole ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: role.id == _selectedRole
                            ? AppColors.primary
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        role.icon,
                        color: role.id == _selectedRole
                            ? Colors.white
                            : Colors.grey.shade700,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                role.title(context),
                                style: AppTypography.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (role.id == activeRole)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF81C784),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 11,
                                        color: Color(0xFF2E7D32),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        context.tr('currentlyActive'),
                                        style: AppTypography.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            role.desc(context),
                            style: AppTypography.subtitle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: role.id == _selectedRole
                              ? AppColors.primary
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: role.id == _selectedRole
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Switch Action Button
          ElevatedButton(
            onPressed: () {
              auth.setActiveRole(_selectedRole);
              Navigator.pop(context);
              final roleName = WorkspaceRole.fromId(_selectedRole).title(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.tr('roleSwitchedTo', params: {'role': roleName}),
                  ),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              context.tr('switchContext'),
              style: AppTypography.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
