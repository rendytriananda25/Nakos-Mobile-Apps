import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_typography.dart';

class QuickActionAllocationCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;

  const QuickActionAllocationCard({
    super.key,
    required this.onTap,
    this.title = 'Atur Alokasi Kebutuhan Wajib',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        height: 48.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: AppColors.borderHairline,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCardElevated,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.tune_rounded,
                      size: 16.0,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHighContrast,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.14,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 18.0,
            ),
          ],
        ),
      ),
    );
  }
}
