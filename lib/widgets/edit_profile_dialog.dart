import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workspace_role.dart';
import '../providers/auth_provider.dart';
import '../providers/registration_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key, required this.role});

  final WorkspaceRoleId role;

  static Future<void> show(BuildContext context, WorkspaceRoleId role) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditProfileSheet(role: role),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  late final TextEditingController _orgCompanyCoopController;
  late final TextEditingController _repNameController;
  late final TextEditingController _workCategoryController;

  bool _isSaving = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    final reg = context.read<RegistrationProvider>();
    final auth = context.read<AuthProvider>();

    final initialName = reg.fullName.isNotEmpty
        ? reg.fullName
        : (widget.role == WorkspaceRoleId.customer ? auth.customerName : auth.workerName);

    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: reg.email.isNotEmpty ? reg.email : auth.registeredEmail);
    _locationController = TextEditingController(text: reg.location);
    _orgCompanyCoopController = TextEditingController(
      text: widget.role == WorkspaceRoleId.customer
          ? reg.organizationName
          : widget.role == WorkspaceRoleId.contractor
              ? reg.companyName
              : reg.cooperativeName,
    );
    _repNameController = TextEditingController(text: reg.representativeName);
    _workCategoryController = TextEditingController(text: reg.workCategory);

    // If local state fields are empty, attempt loading from saved profile
    reg.loadSavedProfile(widget.role, phone: auth.phoneDigits).then((data) {
      if (data != null && mounted) {
        setState(() {
          _nameController.text = data.fullName;
          _emailController.text = data.email;
          _locationController.text = data.location;
          if (widget.role == WorkspaceRoleId.customer) {
            _orgCompanyCoopController.text = data.organizationName;
          } else if (widget.role == WorkspaceRoleId.contractor) {
            _orgCompanyCoopController.text = data.companyName;
          } else if (widget.role == WorkspaceRoleId.cooperative) {
            _orgCompanyCoopController.text = data.cooperativeName;
            _repNameController.text = data.representativeName;
          } else if (widget.role == WorkspaceRoleId.worker) {
            _workCategoryController.text = data.workCategory;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _orgCompanyCoopController.dispose();
    _repNameController.dispose();
    _workCategoryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final reg = context.read<RegistrationProvider>();
    final auth = context.read<AuthProvider>();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMsg = 'Full Name / Entity Name is required.');
      return;
    }
    if (email.isNotEmpty && !RegistrationProvider.isValidEmail(email)) {
      setState(() => _errorMsg = 'Please enter a valid email format.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    final updatedData = reg.currentRegistrationData.copyWith(
      role: widget.role,
      mobile: reg.mobile.isNotEmpty ? reg.mobile : auth.phoneDigits,
      fullName: name,
      email: email,
      location: location,
      organizationName: widget.role == WorkspaceRoleId.customer ? _orgCompanyCoopController.text.trim() : null,
      companyName: widget.role == WorkspaceRoleId.contractor ? _orgCompanyCoopController.text.trim() : null,
      cooperativeName: widget.role == WorkspaceRoleId.cooperative ? _orgCompanyCoopController.text.trim() : null,
      representativeName: widget.role == WorkspaceRoleId.cooperative ? _repNameController.text.trim() : null,
      workCategory: widget.role == WorkspaceRoleId.worker && _workCategoryController.text.isNotEmpty
          ? _workCategoryController.text.trim()
          : null,
      isRegistered: true,
    );

    final success = await reg.updateProfile(updatedData);
    if (!mounted) return;

    if (success) {
      auth.updateProfileData(
        customerName: widget.role == WorkspaceRoleId.customer ? name : null,
        workerName: widget.role == WorkspaceRoleId.worker ? name : null,
        email: email,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        _isSaving = false;
        _errorMsg = reg.errorMessage ?? 'Failed to update profile. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: mediaQuery.viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile',
                    style: AppTypography.heading(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (_errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMsg!,
                          style: AppTypography.poppins(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Full Name Field
              _buildField('Full / Display Name', _nameController, Icons.person_outline),
              const SizedBox(height: 12),

              // Email Field
              _buildField(
                'Email Address',
                _emailController,
                Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Role specific entity field
              if (widget.role == WorkspaceRoleId.customer)
                _buildField('Organization / Business Name', _orgCompanyCoopController, Icons.business_outlined)
              else if (widget.role == WorkspaceRoleId.contractor)
                _buildField('Company / Agency Name', _orgCompanyCoopController, Icons.apartment_rounded)
              else if (widget.role == WorkspaceRoleId.cooperative) ...[
                _buildField('Co-operative Name', _orgCompanyCoopController, Icons.groups_rounded),
                const SizedBox(height: 12),
                _buildField('Representative Name', _repNameController, Icons.person_outline),
              ],
              const SizedBox(height: 12),

              // Location Field
              _buildField('Location / City', _locationController, Icons.location_on_outlined),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Save Changes',
                        style: AppTypography.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTypography.poppins(fontSize: 14, color: const Color(0xFF0F172A)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
