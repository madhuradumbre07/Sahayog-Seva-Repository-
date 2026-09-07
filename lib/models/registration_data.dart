import 'workspace_role.dart';

class RegistrationData {
  const RegistrationData({
    required this.role,
    this.fullName = '',
    this.mobile = '',
    this.email = '',
    this.password = '',
    this.location = '',
    this.workCategory = '',
    this.otherWorkCategory = '',
    this.organizationName = '',
    this.companyName = '',
    this.gstNumber = '',
    this.cooperativeName = '',
    this.representativeName = '',
    this.registrationNumber = '',
    this.isRegistered = false,
  });

  final WorkspaceRoleId role;
  final String fullName;
  final String mobile;
  final String email;
  final String password;
  final String location;
  final String workCategory;
  final String otherWorkCategory;
  final String organizationName;
  final String companyName;
  final String gstNumber;
  final String cooperativeName;
  final String representativeName;
  final String registrationNumber;
  final bool isRegistered;

  /// Returns the effective work category (either selected or custom other)
  String get effectiveWorkCategory {
    if (workCategory.toLowerCase() == 'other' || workCategory == 'serviceOther') {
      return otherWorkCategory.isNotEmpty ? otherWorkCategory : 'Other';
    }
    return workCategory;
  }

  RegistrationData copyWith({
    WorkspaceRoleId? role,
    String? fullName,
    String? mobile,
    String? email,
    String? password,
    String? location,
    String? workCategory,
    String? otherWorkCategory,
    String? organizationName,
    String? companyName,
    String? gstNumber,
    String? cooperativeName,
    String? representativeName,
    String? registrationNumber,
    bool? isRegistered,
  }) {
    return RegistrationData(
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      password: password ?? this.password,
      location: location ?? this.location,
      workCategory: workCategory ?? this.workCategory,
      otherWorkCategory: otherWorkCategory ?? this.otherWorkCategory,
      organizationName: organizationName ?? this.organizationName,
      companyName: companyName ?? this.companyName,
      gstNumber: gstNumber ?? this.gstNumber,
      cooperativeName: cooperativeName ?? this.cooperativeName,
      representativeName: representativeName ?? this.representativeName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  /// Payload sent to backend for account creation
  Map<String, dynamic> toBackendJson() {
    final map = <String, dynamic>{
      'full_name': role == WorkspaceRoleId.cooperative ? (cooperativeName.isNotEmpty ? cooperativeName : fullName) : fullName,
      'mobile': mobile,
      'email': email.isNotEmpty ? email : null,
      'password': password,
      'role': role.name,
      'location': location,
      'is_registered': true,
    };

    switch (role) {
      case WorkspaceRoleId.worker:
        map['work_category'] = effectiveWorkCategory;
        break;
      case WorkspaceRoleId.customer:
        map['organization_name'] = organizationName.isNotEmpty ? organizationName : null;
        break;
      case WorkspaceRoleId.contractor:
        map['company_name'] = companyName.isNotEmpty ? companyName : null;
        map['gst_number'] = gstNumber.isNotEmpty ? gstNumber : null;
        break;
      case WorkspaceRoleId.cooperative:
        map['cooperative_name'] = cooperativeName.isNotEmpty ? cooperativeName : null;
        map['representative_name'] = representativeName.isNotEmpty ? representativeName : null;
        map['registration_number'] = registrationNumber.isNotEmpty ? registrationNumber : null;
        break;
    }

    return map;
  }

  /// Payload sent to backend for profile update
  Map<String, dynamic> toBackendUpdateJson() {
    final map = <String, dynamic>{
      'full_name': role == WorkspaceRoleId.cooperative ? (cooperativeName.isNotEmpty ? cooperativeName : fullName) : fullName,
      'email': email.isNotEmpty ? email : null,
      'location': location,
    };

    switch (role) {
      case WorkspaceRoleId.worker:
        map['work_category'] = effectiveWorkCategory;
        break;
      case WorkspaceRoleId.customer:
        map['organization_name'] = organizationName.isNotEmpty ? organizationName : null;
        break;
      case WorkspaceRoleId.contractor:
        map['company_name'] = companyName.isNotEmpty ? companyName : null;
        map['gst_number'] = gstNumber.isNotEmpty ? gstNumber : null;
        break;
      case WorkspaceRoleId.cooperative:
        map['cooperative_name'] = cooperativeName.isNotEmpty ? cooperativeName : null;
        map['representative_name'] = representativeName.isNotEmpty ? representativeName : null;
        map['registration_number'] = registrationNumber.isNotEmpty ? registrationNumber : null;
        break;
    }

    return map;
  }

  /// Local storage map (excludes raw password for security)
  Map<String, dynamic> toLocalMap() {
    return {
      'role': role.name,
      'fullName': fullName,
      'mobile': mobile,
      'email': email,
      'location': location,
      'workCategory': workCategory,
      'otherWorkCategory': otherWorkCategory,
      'organizationName': organizationName,
      'companyName': companyName,
      'gstNumber': gstNumber,
      'cooperativeName': cooperativeName,
      'representativeName': representativeName,
      'registrationNumber': registrationNumber,
      'isRegistered': isRegistered,
    };
  }

  factory RegistrationData.fromLocalMap(Map<String, dynamic> map) {
    final roleName = map['role'] as String? ?? 'customer';
    final role = WorkspaceRoleId.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => WorkspaceRoleId.customer,
    );

    return RegistrationData(
      role: role,
      fullName: map['fullName'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      email: map['email'] as String? ?? '',
      location: map['location'] as String? ?? '',
      workCategory: map['workCategory'] as String? ?? '',
      otherWorkCategory: map['otherWorkCategory'] as String? ?? '',
      organizationName: map['organizationName'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      gstNumber: map['gstNumber'] as String? ?? '',
      cooperativeName: map['cooperativeName'] as String? ?? '',
      representativeName: map['representativeName'] as String? ?? '',
      registrationNumber: map['registrationNumber'] as String? ?? '',
      isRegistered: map['isRegistered'] as bool? ?? true,
    );
  }

  factory RegistrationData.fromBackendJson(Map<String, dynamic> map) {
    final roleName = map['role'] as String? ?? 'customer';
    final role = WorkspaceRoleId.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => WorkspaceRoleId.customer,
    );

    return RegistrationData(
      role: role,
      fullName: map['full_name'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      email: map['email'] as String? ?? '',
      location: map['location'] as String? ?? '',
      workCategory: map['work_category'] as String? ?? '',
      organizationName: map['organization_name'] as String? ?? '',
      companyName: map['company_name'] as String? ?? '',
      gstNumber: map['gst_number'] as String? ?? '',
      cooperativeName: map['cooperative_name'] as String? ?? '',
      representativeName: map['representative_name'] as String? ?? '',
      registrationNumber: map['registration_number'] as String? ?? '',
      isRegistered: map['is_registered'] as bool? ?? true,
    );
  }
}
