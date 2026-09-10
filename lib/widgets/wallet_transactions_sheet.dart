import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WalletTransactionsSheet extends StatefulWidget {
  const WalletTransactionsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WalletTransactionsSheet(),
    );
  }

  @override
  State<WalletTransactionsSheet> createState() => _WalletTransactionsSheetState();
}

class _WalletTransactionsSheetState extends State<WalletTransactionsSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final userId = auth.phoneDigits.isNotEmpty ? auth.phoneDigits : 'CUST-9842';
      context.read<WalletProvider>().refreshWallet(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final txns = wallet.transactions;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + bottomPadding,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.history, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment & Wallet History',
                        style: AppTypography.heading(fontSize: 16),
                      ),
                      Text(
                        'Double-entry transaction ledger',
                        style: AppTypography.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(height: 24),

          // Ledger Content
          Expanded(
            child: wallet.isLoading
                ? const Center(child: CircularProgressIndicator())
                : txns.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions recorded yet',
                              style: AppTypography.poppins(fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: txns.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = txns[index];
                          final status = item['status'] as String? ?? 'SUCCESS';
                          final isSuccess = status == 'SUCCESS';
                          final type = item['transaction_type'] as String? ?? 'CREDIT';
                          final isCredit = type == 'CREDIT';
                          final amt = (item['amount'] as num?)?.toDouble() ?? 0.0;
                          final balanceAfter = (item['balance_after'] as num?)?.toDouble() ?? 0.0;
                          final txnId = item['transaction_id'] as String? ?? '';
                          final desc = item['description'] as String? ?? 'Wallet Transaction';
                          final dateStr = item['created_at'] as String? ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: !isSuccess
                                      ? const Color(0xFFFEE2E2)
                                      : (isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7)),
                                  child: Icon(
                                    !isSuccess
                                        ? Icons.close
                                        : (isCredit ? Icons.add : Icons.remove),
                                    color: !isSuccess
                                        ? Colors.red.shade700
                                        : (isCredit ? Colors.green.shade700 : Colors.amber.shade800),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        desc,
                                        style: AppTypography.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'ID: $txnId • $dateStr',
                                        style: AppTypography.poppins(
                                          fontSize: 10,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      if (isSuccess) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Balance after: ₹${balanceAfter.toStringAsFixed(2)}',
                                          style: AppTypography.poppins(
                                            fontSize: 10,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isCredit ? "+" : "-"}₹${amt.toStringAsFixed(2)}',
                                      style: AppTypography.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: !isSuccess
                                            ? Colors.grey.shade500
                                            : (isCredit ? Colors.green.shade700 : Colors.black87),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isSuccess
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        status,
                                        style: AppTypography.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isSuccess
                                              ? Colors.green.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
