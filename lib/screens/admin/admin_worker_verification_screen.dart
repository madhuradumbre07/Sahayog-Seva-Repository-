import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AdminWorkerVerificationScreen extends StatefulWidget {
  const AdminWorkerVerificationScreen({super.key});

  static const String routeName = '/admin/worker-verification';

  @override
  State<AdminWorkerVerificationScreen> createState() => _AdminWorkerVerificationScreenState();
}

class _AdminWorkerVerificationScreenState extends State<AdminWorkerVerificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProfileProvider>().loadPendingQueue();
    });
  }

  Future<void> _handleVerify(String workerId, String status) async {
    final provider = context.read<WorkerProfileProvider>();
    String? rejectionReason;

    if (status == 'REJECTED') {
      rejectionReason = await _showRejectionDialog();
      if (rejectionReason == null) return; // User cancelled
    }

    final success = await provider.verifyWorker(
      workerId: workerId,
      newStatus: status,
      rejectionReason: rejectionReason,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Worker status updated to $status!'),
            backgroundColor: status == 'VERIFIED' ? Colors.green : Colors.blue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Status update failed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showRejectionDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reason for Rejection', style: AppTypography.heading(fontSize: 16)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter reason (e.g. Invalid certificate format)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkerProfileProvider>();
    final pending = provider.pendingWorkers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Worker Verification Queue', style: AppTypography.heading(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: provider.isLoading && pending.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () => provider.loadPendingQueue(),
              color: AppColors.primary,
              child: pending.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF16A34A)),
                          const SizedBox(height: 12),
                          Text('No Pending Applications', style: AppTypography.heading(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('All worker registrations have been verified!', style: AppTypography.poppins(fontSize: 12, color: const Color(0xFF64748B))),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: pending.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = pending[index];
                        return _buildWorkerCard(item);
                      },
                    ),
            ),
    );
  }

  Widget _buildWorkerCard(Map<String, dynamic> item) {
    final workerId = item['user_id'] as String? ?? '${item['id']}';
    final status = item['verification_status'] as String? ?? 'PENDING';
    final skills = (item['skills'] as List?)?.cast<String>() ?? [];
    final certs = (item['certifications'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['full_name'] ?? 'Worker',
                    style: AppTypography.heading(fontSize: 16),
                  ),
                  Text(
                    'Phone: ${item['mobile']} • Exp: ${item['experience_years']} yrs',
                    style: AppTypography.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'UNDER_REVIEW' ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: AppTypography.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: status == 'UNDER_REVIEW' ? const Color(0xFFB45309) : const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text('Skills: ${skills.join(', ')}', style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
          if (certs.isNotEmpty)
            Text('Certifications: ${certs.join(', ')}', style: AppTypography.poppins(fontSize: 12, color: const Color(0xFF16A34A))),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Row(
            children: [
              if (status == 'PENDING')
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleVerify(workerId, 'UNDER_REVIEW'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB45309),
                      side: const BorderSide(color: Color(0xFFFDE68A)),
                    ),
                    child: const Text('Under Review', style: TextStyle(fontSize: 11)),
                  ),
                ),
              if (status == 'PENDING') const SizedBox(width: 8),

              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleVerify(workerId, 'VERIFIED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Verify & Approve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleVerify(workerId, 'REJECTED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Reject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
