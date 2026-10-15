import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../expense_logging/domain/entities/transaction_entity.dart';
import 'bento_transaction_tile.dart';

class RecentActivitySection extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final VoidCallback? onViewAllTap;
  final void Function(TransactionEntity)? onTransactionTap;

  const RecentActivitySection({
    super.key,
    required this.transactions,
    this.onViewAllTap,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Aktivitas Terakhir',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textHighContrast,
                  fontSize: 18.0,
                  letterSpacing: -0.18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8.0),
            InkWell(
              onTap: onViewAllTap,
              borderRadius: BorderRadius.circular(6.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.24,
                      ),
                    ),
                    const SizedBox(width: 2.0),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16.0,
                      color: AppColors.brandPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        if (transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: AppColors.borderHairline,
                width: 1.0,
              ),
            ),
            child: Center(
              child: Text(
                'Belum ada transaksi pengeluaran.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10.0),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return BentoTransactionTile(
                transaction: tx,
                onTap: () => onTransactionTap?.call(tx),
              );
            },
          ),
      ],
    );
  }
}
