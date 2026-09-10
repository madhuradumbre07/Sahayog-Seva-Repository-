import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WalletTopUpModal extends StatefulWidget {
  const WalletTopUpModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WalletTopUpModal(),
    );
  }

  @override
  State<WalletTopUpModal> createState() => _WalletTopUpModalState();
}

class _WalletTopUpModalState extends State<WalletTopUpModal> {
  final TextEditingController _amountController = TextEditingController(text: '500');
  double _selectedAmount = 500.0;
  bool _isProcessing = false;
  String? _statusMessage;
  bool? _isSuccessStatus;

  final List<double> _presetAmounts = [100, 500, 1000, 2000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onPresetSelected(double amt) {
    setState(() {
      _selectedAmount = amt;
      _amountController.text = amt.toStringAsFixed(0);
    });
  }

  Future<void> _handlePayment() async {
    final amtText = _amountController.text.trim();
    final amt = double.tryParse(amtText);

    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than ₹0.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = null;
    });

    final auth = context.read<AuthProvider>();
    final userId = auth.phoneDigits.isNotEmpty ? auth.phoneDigits : 'CUST-9842';
    final walletProvider = context.read<WalletProvider>();

    final success = await walletProvider.processTopUp(
      userId: userId,
      amount: amt,
      simulateFailure: false,
    );

    if (mounted) {
      if (success) {
        // Automatically trigger WalletProvider to re-fetch dynamic balance and transactions
        await walletProvider.refreshWallet(userId);
      }

      setState(() {
        _isProcessing = false;
        _isSuccessStatus = success;
        if (success) {
          _statusMessage = '₹${amt.toStringAsFixed(2)} added successfully to your wallet!';
        } else {
          _statusMessage = walletProvider.errorMessage ?? 'Payment failed. Please check backend connection.';
        }
      });

      if (success) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      child: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Money to Wallet',
                          style: AppTypography.heading(fontSize: 16),
                        ),
                        Text(
                          'Instant & Secure Wallet Top-Up',
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

            // Amount Input
            Text(
              'Enter Amount (₹)',
              style: AppTypography.subtitle(fontSize: 13).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: AppTypography.heading(fontSize: 18).copyWith(color: AppColors.primary),
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
              onChanged: (val) {
                final d = double.tryParse(val);
                if (d != null) {
                  setState(() => _selectedAmount = d);
                }
              },
            ),
            const SizedBox(height: 12),

            // Preset Amount Chips
            Wrap(
              spacing: 8,
              children: _presetAmounts.map((amt) {
                final isSelected = (_selectedAmount == amt);
                return ChoiceChip(
                  label: Text('+$amt'),
                  selected: isSelected,
                  selectedColor: const Color(0xFFE8F0FE),
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: AppTypography.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : Colors.black87,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  onSelected: (_) => _onPresetSelected(amt),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Payment Method Selection Tile
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Payment Method',
                              style: AppTypography.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: AppTypography.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF15803D)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Instant UPI (Google Pay / PhonePe / Paytm / BHIM)',
                          style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Security Trust Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  '256-Bit Encrypted • Powered by Sahayog Gateway',
                  style: AppTypography.poppins(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Feedback Status Banner
            if (_statusMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_isSuccessStatus == true)
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (_isSuccessStatus == true)
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFFCA5A5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      (_isSuccessStatus == true) ? Icons.check_circle : Icons.error,
                      color: (_isSuccessStatus == true) ? Colors.green.shade800 : Colors.red.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: AppTypography.poppins(
                          fontSize: 12,
                          color: (_isSuccessStatus == true) ? Colors.green.shade900 : Colors.red.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Proceed to Pay ₹${_selectedAmount.toStringAsFixed(0)}',
                        style: AppTypography.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
