import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/workspace_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/registration_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/handshake_logo.dart';
import '../../widgets/language_selector_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, this.initialRole});

  static const String routeName = '/role-registration';
  final WorkspaceRoleId? initialRole;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();
  final _otherWorkCategoryController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _cooperativeNameController = TextEditingController();
  final _representativeNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  // Focus Nodes for blur validation
  final _fullNameFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _otherWorkCategoryFocus = FocusNode();
  final _organizationNameFocus = FocusNode();
  final _companyNameFocus = FocusNode();
  final _gstNumberFocus = FocusNode();
  final _cooperativeNameFocus = FocusNode();
  final _representativeNameFocus = FocusNode();
  final _registrationNumberFocus = FocusNode();

  final Set<String> _touchedFields = {};
  bool _submittedOnce = false;

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final reg = context.read<RegistrationProvider>();

      // Determine role from widget, auth provider, or default
      final role = widget.initialRole ?? auth.activeRole;
      reg.setRole(role);

      // Pre-fill phone if already authenticated or typed
      if (auth.phoneDigits.isNotEmpty) {
        _mobileController.text = auth.phoneDigits;
        reg.setMobile(auth.phoneDigits);
      }
    });
  }

  void _setupFocusListeners() {
    _fullNameFocus.addListener(() => _handleFieldBlur('fullName'));
    _mobileFocus.addListener(() => _handleFieldBlur('mobile'));
    _emailFocus.addListener(() => _handleFieldBlur('email'));
    _passwordFocus.addListener(() => _handleFieldBlur('password'));
    _locationFocus.addListener(() => _handleFieldBlur('location'));
    _otherWorkCategoryFocus.addListener(() => _handleFieldBlur('otherWorkCategory'));
    _organizationNameFocus.addListener(() => _handleFieldBlur('organizationName'));
    _companyNameFocus.addListener(() => _handleFieldBlur('companyName'));
    _cooperativeNameFocus.addListener(() => _handleFieldBlur('cooperativeName'));
    _representativeNameFocus.addListener(() => _handleFieldBlur('representativeName'));
    _registrationNumberFocus.addListener(() => _handleFieldBlur('registrationNumber'));
  }

  void _handleFieldBlur(String fieldKey) {
    FocusNode? node;
    switch (fieldKey) {
      case 'fullName': node = _fullNameFocus; break;
      case 'mobile': node = _mobileFocus; break;
      case 'email': node = _emailFocus; break;
      case 'password': node = _passwordFocus; break;
      case 'location': node = _locationFocus; break;
      case 'otherWorkCategory': node = _otherWorkCategoryFocus; break;
      case 'organizationName': node = _organizationNameFocus; break;
      case 'companyName': node = _companyNameFocus; break;
      case 'cooperativeName': node = _cooperativeNameFocus; break;
      case 'representativeName': node = _representativeNameFocus; break;
      case 'registrationNumber': node = _registrationNumberFocus; break;
    }

    if (node != null && !node.hasFocus) {
      final reg = context.read<RegistrationProvider>();
      final error = _getFieldValidationError(fieldKey, reg);
      setState(() {
        _touchedFields.add(fieldKey);
      });
      if (error != null) {
        _showShortToast(error);
      }
    }
  }

  String? _getFieldValidationError(String fieldKey, RegistrationProvider reg) {
    switch (fieldKey) {
      case 'fullName':
        if (reg.fullName.isEmpty) return 'Please enter your Full Name.';
        return null;
      case 'mobile':
        if (reg.mobile.isEmpty) return 'Please enter your 10-digit Mobile Number.';
        if (!RegistrationProvider.isValidMobile(reg.mobile)) {
          return 'Mobile Number must be 10 digits starting with 6, 7, 8, or 9.';
        }
        return null;
      case 'email':
        if (reg.currentRole == WorkspaceRoleId.worker) {
          if (reg.email.isNotEmpty && !RegistrationProvider.isValidEmail(reg.email)) {
            return 'Please enter a valid Email Address format.';
          }
        } else {
          if (reg.email.isEmpty) return 'Email Address is required.';
          if (!RegistrationProvider.isValidEmail(reg.email)) {
            return 'Please enter a valid Email Address format.';
          }
        }
        return null;
      case 'password':
        if (reg.password.isEmpty) return 'Please create a Password.';
        if (reg.password.length < 6) return 'Password must be at least 6 characters long.';
        return null;
      case 'location':
        if (reg.location.isEmpty) return 'Please enter your Location / City.';
        return null;
      case 'organizationName':
        if (reg.organizationName.isEmpty) return 'Please enter Organization / Individual Name.';
        return null;
      case 'companyName':
        if (reg.companyName.isEmpty) return 'Please enter Company / Agency Name.';
        return null;
      case 'cooperativeName':
        if (reg.cooperativeName.isEmpty) return 'Please enter Co-operative Society Name.';
        return null;
      case 'representativeName':
        if (reg.representativeName.isEmpty) return 'Please enter Representative Name.';
        return null;
      case 'registrationNumber':
        if (reg.registrationNumber.isEmpty) return 'Please enter Society Registration Number.';
        return null;
      case 'otherWorkCategory':
        if (reg.isOtherWorkCategorySelected && reg.otherWorkCategory.isEmpty) {
          return 'Please specify your custom Work Category.';
        }
        return null;
      default:
        return null;
    }
  }

  void _showShortToast(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTypography.poppins(color: Colors.white, fontSize: 12.5),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000), // stays only for ~2 seconds
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    _otherWorkCategoryController.dispose();
    _organizationNameController.dispose();
    _companyNameController.dispose();
    _gstNumberController.dispose();
    _cooperativeNameController.dispose();
    _representativeNameController.dispose();
    _registrationNumberController.dispose();

    _fullNameFocus.dispose();
    _mobileFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _locationFocus.dispose();
    _otherWorkCategoryFocus.dispose();
    _organizationNameFocus.dispose();
    _companyNameFocus.dispose();
    _gstNumberFocus.dispose();
    _cooperativeNameFocus.dispose();
    _representativeNameFocus.dispose();
    _registrationNumberFocus.dispose();

    super.dispose();
  }

  Color _getRoleColor(WorkspaceRoleId role) {
    switch (role) {
      case WorkspaceRoleId.worker:
        return const Color(0xFF16A34A); // Green
      case WorkspaceRoleId.customer:
        return const Color(0xFF2563EB); // Blue
      case WorkspaceRoleId.contractor:
        return const Color(0xFF7C3AED); // Purple
      case WorkspaceRoleId.cooperative:
        return const Color(0xFF0D9488); // Teal
    }
  }

  String _getRoleSubtitle(BuildContext context, WorkspaceRoleId role) {
    switch (role) {
      case WorkspaceRoleId.worker:
        return context.tr('regSubtitleWorker');
      case WorkspaceRoleId.customer:
        return context.tr('regSubtitleCustomer');
      case WorkspaceRoleId.contractor:
        return context.tr('regSubtitleContractor');
      case WorkspaceRoleId.cooperative:
        return context.tr('regSubtitleCoop');
    }
  }

  String _getWhyTitle(BuildContext context, WorkspaceRoleId role) {
    switch (role) {
      case WorkspaceRoleId.worker:
        return context.tr('regWhyWorkerTitle');
      case WorkspaceRoleId.customer:
        return context.tr('regWhyCustomerTitle');
      case WorkspaceRoleId.contractor:
        return context.tr('regWhyContractorTitle');
      case WorkspaceRoleId.cooperative:
        return context.tr('regWhyCoopTitle');
    }
  }

  String _getWhyDesc(BuildContext context, WorkspaceRoleId role) {
    switch (role) {
      case WorkspaceRoleId.worker:
        return context.tr('regWhyWorkerDesc');
      case WorkspaceRoleId.customer:
        return context.tr('regWhyCustomerDesc');
      case WorkspaceRoleId.contractor:
        return context.tr('regWhyContractorDesc');
      case WorkspaceRoleId.cooperative:
        return context.tr('regWhyCoopDesc');
    }
  }

  IconData _getWhyIcon(WorkspaceRoleId role) {
    switch (role) {
      case WorkspaceRoleId.worker:
        return Icons.verified_user_rounded;
      case WorkspaceRoleId.customer:
        return Icons.work_history_rounded;
      case WorkspaceRoleId.contractor:
        return Icons.domain_rounded;
      case WorkspaceRoleId.cooperative:
        return Icons.groups_rounded;
    }
  }

  void _showValidationErrorsPopup(List<String> errors, Color roleColor) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Incomplete Registration',
                  style: AppTypography.heading(fontSize: 17).copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please resolve the following before continuing:',
                  style: AppTypography.subtitle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                ...errors.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4, right: 6),
                            child: Icon(Icons.circle, size: 6, color: AppColors.error),
                          ),
                          Expanded(
                            child: Text(
                              e,
                              style: AppTypography.poppins(
                                fontSize: 13,
                                color: const Color(0xFF334155),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: roleColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Review & Fix'),
            ),
          ],
        );
      },
    );
  }

  void _showApiErrorPopup(String errorMsg, Color roleColor) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Registration Error',
                  style: AppTypography.heading(fontSize: 17).copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            errorMsg,
            style: AppTypography.poppins(fontSize: 13, color: const Color(0xFF334155)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _handleRegister();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: roleColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRegister() async {
    setState(() {
      _submittedOnce = true;
      _touchedFields.addAll([
        'fullName',
        'mobile',
        'email',
        'password',
        'location',
        'workCategory',
        'otherWorkCategory',
        'organizationName',
        'companyName',
        'cooperativeName',
        'representativeName',
        'registrationNumber',
      ]);
    });

    final reg = context.read<RegistrationProvider>();
    final auth = context.read<AuthProvider>();
    final roleColor = _getRoleColor(reg.currentRole);

    // 1. Client-Side Form Validation check
    final errors = reg.validateForm();
    if (errors.isNotEmpty) {
      _showShortToast(errors.first);

      // Trigger modal popup if multiple errors occur
      if (errors.length > 1) {
        _showValidationErrorsPopup(errors, roleColor);
      }
      return;
    }

    // 2. Submit to backend API & persist locally
    final success = await reg.register();
    if (!mounted) return;

    if (success) {
      // Sync phone and role to AuthProvider & mark isRegistered
      if (reg.mobile.isNotEmpty) {
        auth.setPhoneDigits(reg.mobile);
      }
      auth.setActiveRole(reg.currentRole);
      await auth.markRoleRegistered(
        reg.currentRole,
        fullName: reg.fullName.isNotEmpty
            ? reg.fullName
            : (reg.cooperativeName.isNotEmpty ? reg.cooperativeName : null),
        email: reg.email.isNotEmpty ? reg.email : null,
      );

      if (!mounted) return;

      // Navigate to dashboard
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Account created successfully! Welcome to SahayogSeva.',
                  style: AppTypography.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: roleColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2500),
        ),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } else if (reg.errorMessage != null) {
      if (!mounted) return;
      _showShortToast(reg.errorMessage!);
      _showApiErrorPopup(reg.errorMessage!, roleColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reg = context.watch<RegistrationProvider>();
    final role = reg.currentRole;
    final roleColor = _getRoleColor(role);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Logo Bar
            _buildTopBar(context, roleColor),

            // Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // Screen Header: Title & Dynamic Subtitle
                      Text(
                        context.tr('regTitle'),
                        textAlign: TextAlign.center,
                        style: AppTypography.heading(fontSize: 22).copyWith(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getRoleSubtitle(context, role),
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle(fontSize: 13).copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3-Step Progress Indicator
                      _buildProgressBar(context, roleColor),
                      const SizedBox(height: 24),

                      // Role-specific Form Fields
                      ..._buildRoleFields(context, reg, role, roleColor),
                      const SizedBox(height: 16),

                      // Terms & Conditions Checkbox
                      _buildTermsCheckbox(context, reg, roleColor),
                      const SizedBox(height: 20),

                      // Create Account Button (Dynamic Role Color)
                      _buildSubmitButton(context, reg, roleColor),
                      const SizedBox(height: 14),

                      // Login Link
                      _buildLoginLink(context, roleColor),
                      const SizedBox(height: 24),

                      // Bottom Highlight Card ("Why register as [Role]?")
                      _buildWhyRegisterCard(context, role, roleColor),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Color roleColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF334155)),
            onPressed: () => Navigator.maybePop(context),
            tooltip: context.tr('back'),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HandshakeLogo(size: 32),
              const SizedBox(width: 8),
              Text(
                context.tr('brandName'),
                style: AppTypography.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          const LanguageSelectorButton(),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, Color roleColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step 1: Register (Active)
          _buildStepItem(
            stepNumber: '1',
            label: context.tr('regStepRegister'),
            isActive: true,
            isCompleted: false,
            roleColor: roleColor,
          ),
          _buildStepConnector(isCompleted: false),

          // Step 2: Verify (Inactive)
          _buildStepItem(
            stepNumber: '2',
            label: context.tr('regStepVerify'),
            isActive: false,
            isCompleted: false,
            roleColor: roleColor,
          ),
          _buildStepConnector(isCompleted: false),

          // Step 3: Complete (Inactive)
          _buildStepItem(
            stepNumber: '3',
            label: context.tr('regStepComplete'),
            isActive: false,
            isCompleted: false,
            roleColor: roleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String label,
    required bool isActive,
    required bool isCompleted,
    required Color roleColor,
  }) {
    final bgColor = isActive
        ? roleColor
        : isCompleted
            ? roleColor
            : const Color(0xFFE2E8F0);
    final textColor = isActive || isCompleted ? Colors.white : const Color(0xFF64748B);
    final labelColor = isActive ? roleColor : const Color(0xFF94A3B8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  stepNumber,
                  style: AppTypography.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.poppins(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Container(
      width: 44,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18, left: 6, right: 6),
      color: isCompleted ? AppColors.primary : const Color(0xFFE2E8F0),
    );
  }

  List<Widget> _buildRoleFields(
    BuildContext context,
    RegistrationProvider reg,
    WorkspaceRoleId role,
    Color roleColor,
  ) {
    switch (role) {
      case WorkspaceRoleId.worker:
        return _buildWorkerFields(context, reg, roleColor);
      case WorkspaceRoleId.customer:
        return _buildCustomerFields(context, reg, roleColor);
      case WorkspaceRoleId.contractor:
        return _buildContractorFields(context, reg, roleColor);
      case WorkspaceRoleId.cooperative:
        return _buildCooperativeFields(context, reg, roleColor);
    }
  }

  // 1. WORKER FIELDS (Green): Full Name, Mobile, Email (Optional), Password, Work Category, Location
  List<Widget> _buildWorkerFields(
    BuildContext context,
    RegistrationProvider reg,
    Color roleColor,
  ) {
    final showNameError = (_submittedOnce || _touchedFields.contains('fullName')) && reg.fullName.isEmpty;
    final showEmailError = (_submittedOnce || _touchedFields.contains('email')) &&
        reg.email.isNotEmpty &&
        !RegistrationProvider.isValidEmail(reg.email);
    final showCategoryError = (_submittedOnce || _touchedFields.contains('workCategory')) && reg.workCategory.isEmpty;
    final showOtherCategoryError = (_submittedOnce || _touchedFields.contains('otherWorkCategory')) &&
        reg.isOtherWorkCategorySelected &&
        reg.otherWorkCategory.isEmpty;
    final showLocationError = (_submittedOnce || _touchedFields.contains('location')) && reg.location.isEmpty;

    return [
      _buildInputField(
        label: context.tr('regFullName'),
        hint: context.tr('regFullNameHint'),
        icon: Icons.person_outline_rounded,
        controller: _fullNameController,
        focusNode: _fullNameFocus,
        onChanged: reg.setFullName,
        hasError: showNameError,
        errorText: showNameError ? 'Full Name is required' : null,
      ),
      const SizedBox(height: 14),
      _buildMobileField(context, reg, focusNode: _mobileFocus),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regEmailOptional'),
        hint: context.tr('regEmailHint'),
        icon: Icons.mail_outline_rounded,
        controller: _emailController,
        focusNode: _emailFocus,
        keyboardType: TextInputType.emailAddress,
        onChanged: reg.setEmail,
        hasError: showEmailError,
        errorText: showEmailError ? 'Invalid email format' : null,
      ),
      const SizedBox(height: 14),
      _buildPasswordField(context, reg, focusNode: _passwordFocus),
      const SizedBox(height: 14),
      _buildWorkCategoryDropdown(context, reg, roleColor, hasError: showCategoryError),
      if (reg.isOtherWorkCategorySelected) ...[
        const SizedBox(height: 14),
        _buildInputField(
          label: context.tr('regOtherWorkCategory'),
          hint: context.tr('regOtherWorkCategoryHint'),
          icon: Icons.handyman_outlined,
          controller: _otherWorkCategoryController,
          focusNode: _otherWorkCategoryFocus,
          onChanged: reg.setOtherWorkCategory,
          hasError: showOtherCategoryError,
          errorText: showOtherCategoryError ? 'Please specify your category' : null,
        ),
      ],
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regLocation'),
        hint: context.tr('regLocationHint'),
        icon: Icons.location_on_outlined,
        controller: _locationController,
        focusNode: _locationFocus,
        onChanged: reg.setLocation,
        hasError: showLocationError,
        errorText: showLocationError ? 'Location is required' : null,
      ),
    ];
  }

  // 2. CUSTOMER FIELDS (Blue): Full Name, Mobile, Email Address, Password, Organization/Name, Location
  List<Widget> _buildCustomerFields(
    BuildContext context,
    RegistrationProvider reg,
    Color roleColor,
  ) {
    final showNameError = (_submittedOnce || _touchedFields.contains('fullName')) && reg.fullName.isEmpty;
    final showEmailError = (_submittedOnce || _touchedFields.contains('email')) &&
        (reg.email.isEmpty || !RegistrationProvider.isValidEmail(reg.email));
    final showOrgError = (_submittedOnce || _touchedFields.contains('organizationName')) && reg.organizationName.isEmpty;
    final showLocationError = (_submittedOnce || _touchedFields.contains('location')) && reg.location.isEmpty;

    return [
      _buildInputField(
        label: context.tr('regFullName'),
        hint: context.tr('regFullNameHint'),
        icon: Icons.person_outline_rounded,
        controller: _fullNameController,
        focusNode: _fullNameFocus,
        onChanged: reg.setFullName,
        hasError: showNameError,
        errorText: showNameError ? 'Full Name is required' : null,
      ),
      const SizedBox(height: 14),
      _buildMobileField(context, reg, focusNode: _mobileFocus),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regEmail'),
        hint: context.tr('regEmailHint'),
        icon: Icons.mail_outline_rounded,
        controller: _emailController,
        focusNode: _emailFocus,
        keyboardType: TextInputType.emailAddress,
        onChanged: reg.setEmail,
        hasError: showEmailError,
        errorText: showEmailError ? (reg.email.isEmpty ? 'Email is required' : 'Invalid email format') : null,
      ),
      const SizedBox(height: 14),
      _buildPasswordField(context, reg, focusNode: _passwordFocus),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regOrgName'),
        hint: context.tr('regOrgNameHint'),
        icon: Icons.business_outlined,
        controller: _organizationNameController,
        focusNode: _organizationNameFocus,
        onChanged: reg.setOrganizationName,
        hasError: showOrgError,
        errorText: showOrgError ? 'Organization / Individual name is required' : null,
      ),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regLocation'),
        hint: context.tr('regLocationHint'),
        icon: Icons.location_on_outlined,
        controller: _locationController,
        focusNode: _locationFocus,
        onChanged: reg.setLocation,
        hasError: showLocationError,
        errorText: showLocationError ? 'Location is required' : null,
      ),
    ];
  }

  // 3. CONTRACTOR FIELDS (Purple): Full Name, Mobile, Email Address, Password, Company/Business Name, GST Number (Optional), Location
  List<Widget> _buildContractorFields(
    BuildContext context,
    RegistrationProvider reg,
    Color roleColor,
  ) {
    final showNameError = (_submittedOnce || _touchedFields.contains('fullName')) && reg.fullName.isEmpty;
    final showEmailError = (_submittedOnce || _touchedFields.contains('email')) &&
        (reg.email.isEmpty || !RegistrationProvider.isValidEmail(reg.email));
    final showCompanyError = (_submittedOnce || _touchedFields.contains('companyName')) && reg.companyName.isEmpty;
    final showLocationError = (_submittedOnce || _touchedFields.contains('location')) && reg.location.isEmpty;

    return [
      _buildInputField(
        label: context.tr('regFullName'),
        hint: context.tr('regFullNameHint'),
        icon: Icons.person_outline_rounded,
        controller: _fullNameController,
        focusNode: _fullNameFocus,
        onChanged: reg.setFullName,
        hasError: showNameError,
        errorText: showNameError ? 'Contact person name is required' : null,
      ),
      const SizedBox(height: 14),
      _buildMobileField(context, reg, focusNode: _mobileFocus),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regEmail'),
        hint: context.tr('regEmailHint'),
        icon: Icons.mail_outline_rounded,
        controller: _emailController,
        focusNode: _emailFocus,
        keyboardType: TextInputType.emailAddress,
        onChanged: reg.setEmail,
        hasError: showEmailError,
        errorText: showEmailError ? (reg.email.isEmpty ? 'Email is required' : 'Invalid email format') : null,
      ),
      const SizedBox(height: 14),
      _buildPasswordField(context, reg, focusNode: _passwordFocus),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regCompanyName'),
        hint: context.tr('regCompanyNameHint'),
        icon: Icons.apartment_rounded,
        controller: _companyNameController,
        focusNode: _companyNameFocus,
        onChanged: reg.setCompanyName,
        hasError: showCompanyError,
        errorText: showCompanyError ? 'Company name is required' : null,
      ),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regGstNumber'),
        hint: context.tr('regGstNumberHint'),
        icon: Icons.receipt_long_outlined,
        controller: _gstNumberController,
        focusNode: _gstNumberFocus,
        onChanged: reg.setGstNumber,
      ),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regLocation'),
        hint: context.tr('regLocationHint'),
        icon: Icons.location_on_outlined,
        controller: _locationController,
        focusNode: _locationFocus,
        onChanged: reg.setLocation,
        hasError: showLocationError,
        errorText: showLocationError ? 'Location is required' : null,
      ),
    ];
  }

  // 4. CO-OPERATIVE FIELDS (Teal): Co-operative Name, Representative Name, Mobile Number, Email Address, Password, Registration Number, Location
  List<Widget> _buildCooperativeFields(
    BuildContext context,
    RegistrationProvider reg,
    Color roleColor,
  ) {
    final showCoopError = (_submittedOnce || _touchedFields.contains('cooperativeName')) && reg.cooperativeName.isEmpty;
    final showRepError = (_submittedOnce || _touchedFields.contains('representativeName')) && reg.representativeName.isEmpty;
    final showEmailError = (_submittedOnce || _touchedFields.contains('email')) &&
        (reg.email.isEmpty || !RegistrationProvider.isValidEmail(reg.email));
    final showRegNumError = (_submittedOnce || _touchedFields.contains('registrationNumber')) && reg.registrationNumber.isEmpty;
    final showLocationError = (_submittedOnce || _touchedFields.contains('location')) && reg.location.isEmpty;

    return [
      _buildInputField(
        label: context.tr('regCoopName'),
        hint: context.tr('regCoopNameHint'),
        icon: Icons.groups_rounded,
        controller: _cooperativeNameController,
        focusNode: _cooperativeNameFocus,
        onChanged: reg.setCooperativeName,
        hasError: showCoopError,
        errorText: showCoopError ? 'Co-operative Society name is required' : null,
      ),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regRepName'),
        hint: context.tr('regRepNameHint'),
        icon: Icons.person_outline_rounded,
        controller: _representativeNameController,
        focusNode: _representativeNameFocus,
        onChanged: reg.setRepresentativeName,
        hasError: showRepError,
        errorText: showRepError ? 'Representative name is required' : null,
      ),
      const SizedBox(height: 14),
      _buildMobileField(context, reg, focusNode: _mobileFocus),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regEmail'),
        hint: context.tr('regEmailHint'),
        icon: Icons.mail_outline_rounded,
        controller: _emailController,
        focusNode: _emailFocus,
        keyboardType: TextInputType.emailAddress,
        onChanged: reg.setEmail,
        hasError: showEmailError,
        errorText: showEmailError ? (reg.email.isEmpty ? 'Email is required' : 'Invalid email format') : null,
      ),
      const SizedBox(height: 14),
      _buildPasswordField(context, reg, focusNode: _passwordFocus),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regRegNumber'),
        hint: context.tr('regRegNumberHint'),
        icon: Icons.badge_outlined,
        controller: _registrationNumberController,
        focusNode: _registrationNumberFocus,
        onChanged: reg.setRegistrationNumber,
        hasError: showRegNumError,
        errorText: showRegNumError ? 'Society registration number is required' : null,
      ),
      const SizedBox(height: 14),
      _buildInputField(
        label: context.tr('regLocation'),
        hint: context.tr('regLocationHint'),
        icon: Icons.location_on_outlined,
        controller: _locationController,
        focusNode: _locationFocus,
        onChanged: reg.setLocation,
        hasError: showLocationError,
        errorText: showLocationError ? 'Location is required' : null,
      ),
    ];
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool hasError = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppColors.error : const Color(0xFFE2E8F0),
              width: hasError ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: AppTypography.poppins(
              fontSize: 14,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.poppins(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                icon,
                size: 20,
                color: hasError ? AppColors.error : const Color(0xFF64748B),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: AppTypography.poppins(fontSize: 11, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileField(
    BuildContext context,
    RegistrationProvider reg, {
    FocusNode? focusNode,
  }) {
    final showMobileError = (_submittedOnce || _touchedFields.contains('mobile')) &&
        (reg.mobile.isEmpty || !RegistrationProvider.isValidMobile(reg.mobile));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('regMobileNumber'),
              style: AppTypography.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            Text(
              '10 digits',
              style: AppTypography.poppins(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showMobileError ? AppColors.error : const Color(0xFFE2E8F0),
              width: showMobileError ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+91',
                      style: AppTypography.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: TextField(
                  controller: _mobileController,
                  focusNode: focusNode,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: reg.setMobile,
                  style: AppTypography.poppins(
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: context.tr('regMobileHint'),
                    hintStyle: AppTypography.poppins(
                      fontSize: 14,
                      color: const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showMobileError) ...[
          const SizedBox(height: 4),
          Text(
            reg.mobile.isEmpty
                ? 'Mobile number is required'
                : 'Must be 10 digits starting with 6, 7, 8, or 9',
            style: AppTypography.poppins(fontSize: 11, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    RegistrationProvider reg, {
    FocusNode? focusNode,
  }) {
    final showPasswordError = (_submittedOnce || _touchedFields.contains('password')) &&
        (reg.password.isEmpty || reg.password.length < 6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('regPassword'),
              style: AppTypography.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            if (reg.password.isNotEmpty)
              Text(
                'Strength: ${reg.passwordStrengthLabel}',
                style: AppTypography.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: reg.passwordStrengthColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showPasswordError ? AppColors.error : const Color(0xFFE2E8F0),
              width: showPasswordError ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: _passwordController,
            focusNode: focusNode,
            obscureText: reg.obscurePassword,
            onChanged: reg.setPassword,
            style: AppTypography.poppins(
              fontSize: 14,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: context.tr('regPasswordHint'),
              hintStyle: AppTypography.poppins(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: showPasswordError ? AppColors.error : const Color(0xFF64748B),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  reg.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: const Color(0xFF64748B),
                ),
                onPressed: reg.toggleObscurePassword,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
        // Password Strength Real-time Progress Bar
        if (reg.password.isNotEmpty) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: reg.passwordStrengthFraction,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(reg.passwordStrengthColor),
              minHeight: 4,
            ),
          ),
        ],
        if (showPasswordError) ...[
          const SizedBox(height: 4),
          Text(
            reg.password.isEmpty
                ? 'Password is required'
                : 'Password must be at least 6 characters long',
            style: AppTypography.poppins(fontSize: 11, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildWorkCategoryDropdown(
    BuildContext context,
    RegistrationProvider reg,
    Color roleColor, {
    bool hasError = false,
  }) {
    final categories = [
      {'key': 'servicePlumber', 'label': context.tr('servicePlumber')},
      {'key': 'serviceElectrician', 'label': context.tr('serviceElectrician')},
      {'key': 'serviceCleaning', 'label': context.tr('serviceCleaning')},
      {'key': 'serviceAppliance', 'label': context.tr('serviceAppliance')},
      {'key': 'servicePainting', 'label': context.tr('servicePainting')},
      {'key': 'serviceOther', 'label': context.tr('serviceOther')},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('regWorkCategory'),
          style: AppTypography.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppColors.error : const Color(0xFFE2E8F0),
              width: hasError ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              initialValue: reg.workCategory.isNotEmpty ? reg.workCategory : null,
              hint: Row(
                children: [
                  Icon(
                    Icons.work_outline_rounded,
                    size: 20,
                    color: hasError ? AppColors.error : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('regWorkCategoryHint'),
                    style: AppTypography.poppins(
                      fontSize: 14,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF64748B)),
              decoration: const InputDecoration(border: InputBorder.none),
              items: categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat['key'],
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, size: 18, color: Color(0xFF64748B)),
                      const SizedBox(width: 10),
                      Text(
                        cat['label']!,
                        style: AppTypography.poppins(
                          fontSize: 14,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) reg.setWorkCategory(val);
              },
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            'Please select your work category',
            style: AppTypography.poppins(fontSize: 11, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildTermsCheckbox(
    BuildContext context,
    RegistrationProvider reg,
    Color roleColor,
  ) {
    final hasError = _submittedOnce && !reg.agreedToTerms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: reg.agreedToTerms,
                activeColor: roleColor,
                side: BorderSide(
                  color: hasError ? AppColors.error : const Color(0xFF94A3B8),
                  width: hasError ? 2 : 1,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) => reg.setAgreedToTerms(val ?? false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '${context.tr('regTermsAgree')} ',
                  style: AppTypography.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                  children: [
                    TextSpan(
                      text: context.tr('regTermsAndConditions'),
                      style: AppTypography.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: roleColor,
                      ),
                    ),
                    TextSpan(text: ' ${context.tr('regAnd')} '),
                    TextSpan(
                      text: context.tr('regPrivacyPolicy'),
                      style: AppTypography.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: roleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            'Please agree to Terms & Conditions and Privacy Policy',
            style: AppTypography.poppins(fontSize: 11, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    RegistrationProvider reg,
    Color roleColor,
  ) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: reg.isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: roleColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: reg.isLoading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                context.tr('regCreateAccount'),
                style: AppTypography.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context, Color roleColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('regAlreadyHaveAccount'),
          style: AppTypography.poppins(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Text(
            context.tr('regLogin'),
            style: AppTypography.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: roleColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWhyRegisterCard(
    BuildContext context,
    WorkspaceRoleId role,
    Color roleColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: roleColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWhyTitle(context, role),
                  style: AppTypography.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: roleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getWhyDesc(context, role),
                  style: AppTypography.poppins(
                    fontSize: 12,
                    color: const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getWhyIcon(role),
              size: 24,
              color: roleColor,
            ),
          ),
        ],
      ),
    );
  }
}
