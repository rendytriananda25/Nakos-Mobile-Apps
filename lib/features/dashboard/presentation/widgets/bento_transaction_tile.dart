import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_helpers.dart';
import '../../../expense_logging/domain/entities/transaction_entity.dart';

class BentoTransactionTile extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;

  const BentoTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = _getCategoryVisuals(transaction.category);
    final isExpense = !transaction.isIncome;
    final prefix = isExpense ? '-' : '+';
    final amountColor = isExpense ? AppColors.expenseRed : AppColors.incomeGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.0),
      child: Container(
        height: 70.0,
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: AppColors.borderHairline,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 42.0,
                    height: 42.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCardElevated,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: AppColors.borderHairline.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 20.0,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          transaction.title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textHighContrast,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          DateTimeHelpers.formatReadableDate(transaction.timestamp),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 0.12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              '$prefix${CurrencyFormatter.format(transaction.amount)}',
              style: AppTypography.bodyMedium.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getCategoryVisuals(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return (Icons.restaurant_rounded, AppColors.brandPrimary);
      case ExpenseCategory.bills:
        return (Icons.bolt_rounded, AppColors.brandPrimaryMuted);
      case ExpenseCategory.snacks:
        return (Icons.coffee_rounded, AppColors.expenseRed);
      case ExpenseCategory.transport:
        return (Icons.two_wheeler_rounded, AppColors.textSecondary);
      case ExpenseCategory.emergency:
        return (Icons.medical_services_rounded, AppColors.expenseRed);
      case ExpenseCategory.income:
        return (Icons.arrow_downward_rounded, AppColors.incomeGreen);
      case ExpenseCategory.other:
        return (Icons.shopping_bag_outlined, AppColors.brandPrimary);
    }
  }
}
