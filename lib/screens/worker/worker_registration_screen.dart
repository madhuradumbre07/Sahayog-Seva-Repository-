import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class WorkerRegistrationScreen extends StatefulWidget {
  const WorkerRegistrationScreen({super.key});

  static const String routeName = '/worker/registration';

  @override
  State<WorkerRegistrationScreen> createState() => _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState extends State<WorkerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _coopController = TextEditingController();
  final TextEditingController _certsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final userId = auth.backendUserId;
      _mobileController.text = auth.phoneDigits;
      context.read<WorkerProfileProvider>().loadProfile(userId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _skillsController.dispose();
    _expController.dispose();
    _coopController.dispose();
    _certsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final userId = auth.backendUserId;
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before registering as a worker.')),
      );
      return;
    }
    final provider = context.read<WorkerProfileProvider>();

    final skillsList = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final certsList = _certsController.text
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    final coopId = int.tryParse(_coopController.text.trim());
    final expYears = int.tryParse(_expController.text.trim()) ?? 0;

    String? idToken;
    try {
      idToken = await auth.firebaseUser?.getIdToken();
    } catch (_) {}

    final success = await provider.registerWorker(
      userId: userId,
      fullName: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      skills: skillsList,
      experienceYears: expYears,
      cooperativeId: coopId,
      certifications: certsList,
      email: auth.registeredEmail.isNotEmpty ? auth.registeredEmail : null,
      idToken: idToken,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Worker profile registered successfully! Verification status: PENDING.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Registration failed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkerProfileProvider>();
    final profile = provider.currentProfile;
    final status = provider.verificationStatus;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Worker Registration & Status', style: AppTypography.heading(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verification Status Hero Card
            _buildStatusCard(status, profile),
            const SizedBox(height: 20),

            if (status == 'NOT_REGISTERED' || status == 'REJECTED') ...[
              Text(
                'Register Worker Profile',
                style: AppTypography.heading(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill in your trade skills and details for cooperative verification',
                style: AppTypography.poppins(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'e.g. Ramesh Patil',
                      icon: Icons.person,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Full Name is required' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      hint: '10-digit mobile number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (val) => (val == null || val.trim().length < 10) ? 'Enter valid 10-digit number' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _skillsController,
                      label: 'Trade Skills (Comma-separated)',
                      hint: 'e.g. Plumbing, Tap Repair, Pipe Leakage',
                      icon: Icons.handyman,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Specify at least 1 skill' : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _expController,
                            label: 'Experience (Years)',
                            hint: 'e.g. 5',
                            icon: Icons.work_history,
                            keyboardType: TextInputType.number,
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _coopController,
                            label: 'Cooperative ID (Optional)',
                            hint: 'e.g. 1',
                            icon: Icons.business,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _certsController,
                      label: 'Certifications (Optional)',
                      hint: 'e.g. NSDC Certified, Red Cross First Aid',
                      icon: Icons.workspace_premium,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Submit Profile for Verification',
                                style: AppTypography.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Display Registered Details
              _buildRegisteredDetails(profile!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status, Map<String, dynamic>? profile) {
    Color cardBg;
    Color borderCol;
    Color textCol;
    IconData icon;
    String statusTitle;
    String statusSubtitle;

    switch (status) {
      case 'VERIFIED':
        cardBg = const Color(0xFFDCFCE7);
        borderCol = const Color(0xFF86EFAC);
        textCol = const Color(0xFF15803D);
        icon = Icons.verified;
        statusTitle = 'Verification Status: VERIFIED';
        statusSubtitle = 'Your worker profile is fully verified by Sahayog Cooperative Admin!';
        break;
      case 'UNDER_REVIEW':
        cardBg = const Color(0xFFFEF3C7);
        borderCol = const Color(0xFFFDE68A);
        textCol = const Color(0xFFB45309);
        icon = Icons.rule;
        statusTitle = 'Verification Status: UNDER REVIEW';
        statusSubtitle = 'Cooperative Admin is actively reviewing your trade credentials.';
        break;
      case 'REJECTED':
        cardBg = const Color(0xFFFEE2E2);
        borderCol = const Color(0xFFFCA5A5);
        textCol = const Color(0xFFB91C1C);
        icon = Icons.cancel;
        statusTitle = 'Verification Status: REJECTED';
        statusSubtitle = profile?['rejection_reason'] ?? 'Profile verification was not approved. Please re-submit.';
        break;
      case 'PENDING':
        cardBg = const Color(0xFFEFF6FF);
        borderCol = const Color(0xFFBFDBFE);
        textCol = const Color(0xFF1D4ED8);
        icon = Icons.hourglass_top;
        statusTitle = 'Verification Status: PENDING';
        statusSubtitle = 'Profile submitted successfully! Awaiting Cooperative Admin review.';
        break;
      default:
        cardBg = const Color(0xFFF1F5F9);
        borderCol = const Color(0xFFE2E8F0);
        textCol = const Color(0xFF475569);
        icon = Icons.assignment_outlined;
        statusTitle = 'Verification Status: NOT REGISTERED';
        statusSubtitle = 'Submit your worker registration form below to start verification.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textCol, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: AppTypography.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: textCol),
                ),
                const SizedBox(height: 4),
                Text(
                  statusSubtitle,
                  style: AppTypography.poppins(fontSize: 12, color: textCol.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredDetails(Map<String, dynamic> profile) {
    final skills = (profile['skills'] as List?)?.cast<String>() ?? [];
    final certs = (profile['certifications'] as List?)?.cast<String>() ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registered Profile Information', style: AppTypography.heading(fontSize: 16)),
          const Divider(height: 20),
          _detailRow('Full Name', profile['full_name'] ?? 'N/A'),
          _detailRow('Mobile Number', profile['mobile'] ?? 'N/A'),
          _detailRow('Experience Years', '${profile['experience_years']} years'),
          if (profile['cooperative_id'] != null)
            _detailRow('Cooperative ID', '#${profile['cooperative_id']}'),
          const SizedBox(height: 10),
          Text('Trade Skills', style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: skills.map((s) => Chip(
              label: Text(s, style: AppTypography.poppins(fontSize: 11, color: AppColors.primary)),
              backgroundColor: const Color(0xFFEFF6FF),
            )).toList(),
          ),
          if (certs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Certifications', style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: certs.map((c) => Chip(
                label: Text(c, style: AppTypography.poppins(fontSize: 11, color: const Color(0xFF15803D))),
                backgroundColor: const Color(0xFFDCFCE7),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.poppins(fontSize: 12, color: const Color(0xFF64748B))),
          Text(value, style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
