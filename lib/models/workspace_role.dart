import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

enum WorkspaceRoleId { customer, worker, cooperative, contractor }

class WorkspaceRole {
  const WorkspaceRole({
    required this.id,
    required this.icon,
    required this.color,
    required this.needsVerification,
    required this.titleKey,
    required this.descKey,
    required this.featuresKey,
    required this.infoKey,
  });

  final WorkspaceRoleId id;
  final IconData icon;
  final Color color;
  final bool needsVerification;
  final String titleKey;
  final String descKey;
  final String featuresKey;
  final String infoKey;

  String title(BuildContext context) => context.tr(titleKey);
  String desc(BuildContext context) => context.tr(descKey);
  String features(BuildContext context) => context.tr(featuresKey);
  String info(BuildContext context) => context.tr(infoKey);

  // Helper methods that accept BuildContext or AppStrings
  String titleOf(dynamic s) =>
      s is BuildContext ? s.tr(titleKey) : (s as AppStrings).tr(titleKey);
  String descOf(dynamic s) =>
      s is BuildContext ? s.tr(descKey) : (s as AppStrings).tr(descKey);
  String featuresOf(dynamic s) =>
      s is BuildContext ? s.tr(featuresKey) : (s as AppStrings).tr(featuresKey);
  String infoOf(dynamic s) =>
      s is BuildContext ? s.tr(infoKey) : (s as AppStrings).tr(infoKey);

  static const all = [
    WorkspaceRole(
      id: WorkspaceRoleId.worker,
      icon: Icons.handyman,
      color: Color(0xFF16A34A), // Worker Green
      needsVerification: true,
      titleKey: 'roleWorker',
      descKey: 'roleWorkerDesc',
      featuresKey: 'roleWorkerFeatures',
      infoKey: 'roleInfoWorker',
    ),
    WorkspaceRole(
      id: WorkspaceRoleId.customer,
      icon: Icons.family_restroom,
      color: Color(0xFF2563EB), // Customer Blue
      needsVerification: false,
      titleKey: 'roleCustomer',
      descKey: 'roleCustomerDesc',
      featuresKey: 'roleCustomerFeatures',
      infoKey: 'roleInfoCustomer',
    ),
    WorkspaceRole(
      id: WorkspaceRoleId.contractor,
      icon: Icons.apartment,
      color: Color(0xFF7C3AED), // Contractor Purple
      needsVerification: true,
      titleKey: 'roleContractor',
      descKey: 'roleContractorDesc',
      featuresKey: 'roleContractorFeatures',
      infoKey: 'roleInfoContractor',
    ),
    WorkspaceRole(
      id: WorkspaceRoleId.cooperative,
      icon: Icons.groups,
      color: Color(0xFF0D9488), // Cooperative Teal
      needsVerification: true,
      titleKey: 'roleCoop',
      descKey: 'roleCoopDesc',
      featuresKey: 'roleCoopFeatures',
      infoKey: 'roleInfoCoop',
    ),
  ];

  static WorkspaceRole fromId(WorkspaceRoleId id) {
    return all.firstWhere(
      (role) => role.id == id,
      orElse: () => all.first,
    );
  }
}

