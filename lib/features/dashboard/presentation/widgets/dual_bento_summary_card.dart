import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

class DualBentoSummaryCard extends StatelessWidget {
  final double monthlyIncome;
  final double totalExpense;
  final String incomeSource;

  const DualBentoSummaryCard({
    super.key,
    required this.monthlyIncome,
    required this.totalExpense,
    this.incomeSource = 'Kiriman Orang Tua',
  });

  @override
  Widget build(BuildContext context) {
    final isGaji = incomeSource.toLowerCase().contains('gaji');
    return Row(
      children: [
        Expanded(
          child: BentoMetricCard(
            label: 'Pemasukan',
            badgeText: isGaji ? 'Gaji' : 'Kiriman',
            badgeBg: AppColors.incomeSurface,
            badgeTextColor: AppColors.incomeGreen,
            amount: monthlyIncome,
            nominalColor: AppColors.incomeGreen,
            subtext: isGaji ? 'Gaji Bulanan' : 'Kiriman Ortu',
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: BentoMetricCard(
            label: 'Pengeluaran',
            badgeText: 'Terpakai',
            badgeBg: AppColors.expenseSurface,
            badgeTextColor: AppColors.expenseRed,
            amount: totalExpense,
            nominalColor: AppColors.expenseRed,
            subtext: 'Total Terpakai',
          ),
        ),
      ],
    );
  }
}

class BentoMetricCard extends StatelessWidget {
  final String label;
  final String badgeText;
  final Color badgeBg;
  final Color badgeTextColor;
  final double amount;
  final Color? nominalColor;
  final String subtext;

  const BentoMetricCard({
    super.key,
    required this.label,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.amount,
    this.nominalColor,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: AppColors.borderHairline,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(9999.0),
                ),
                child: Text(
                  badgeText,
                  style: AppTypography.labelSmall.copyWith(
                    color: badgeTextColor,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
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
              CurrencyFormatter.format(amount),
              style: AppTypography.titleSmall.copyWith(
                color: nominalColor ?? AppColors.textHighContrast,
                fontSize: 17.0,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.45,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            subtext,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
