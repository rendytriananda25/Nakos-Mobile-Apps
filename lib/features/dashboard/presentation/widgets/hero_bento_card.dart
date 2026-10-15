import 'package:flutter/material.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

class HeroBentoCard extends StatelessWidget {
  final double survivalBudget;
  final double dailyAllowance;
  final VoidCallback? onMenuTap;

  const HeroBentoCard({
    super.key,
    required this.survivalBudget,
    required this.dailyAllowance,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A20),
            Color(0xFF121216),
          ],
        ),
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: AppColors.borderHairline,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withValues(alpha: 0.12),
            blurRadius: 32.0,
            offset: const Offset(0, 12),
            spreadRadius: -4.0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30.0,
            bottom: -30.0,
            child: Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPrimary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimarySurface,
                      borderRadius: BorderRadius.circular(9999.0),
                      border: Border.all(
                        color: AppColors.brandPrimaryMuted.withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Saldo Terkini',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.brandPrimary,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onMenuTap,
                    borderRadius: BorderRadius.circular(9999.0),
                    child: Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceInteractive.withValues(alpha: 0.5),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        color: AppColors.textSecondary,
                        size: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  CurrencyFormatter.format(survivalBudget),
                  style: AppTypography.displayBalance.copyWith(
                    color: AppColors.textHighContrast,
                    fontSize: 32.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCardElevated,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: AppColors.borderHairline,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_outlined,
                            size: 14.0,
                            color: AppColors.brandPrimary,
                          ),
                          const SizedBox(width: 6.0),
                          Flexible(
                            child: Text(
                              'Jatah Harian',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyFormatter.format(dailyAllowance),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textHighContrast,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '/hari',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
