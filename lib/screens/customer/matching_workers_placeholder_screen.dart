import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';

class MatchingWorkersPlaceholderScreen extends StatelessWidget {
  const MatchingWorkersPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('matchingWorkersTitle'),
          style: AppTypography.heading(fontSize: 17).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: const [
          LanguageSelectorButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F0FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group_outlined,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('matchingWorkersHeader'),
                textAlign: TextAlign.center,
                style: AppTypography.heading(fontSize: 18).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Locating nearby verified cooperative workers and service partners...',
                textAlign: TextAlign.center,
                style: AppTypography.subtitle(fontSize: 13),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Back to Home Dashboard',
                  style: AppTypography.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
