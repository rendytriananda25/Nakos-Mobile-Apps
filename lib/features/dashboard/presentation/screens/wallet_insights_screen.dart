import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_helpers.dart';
import '../../../expense_logging/domain/entities/transaction_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';

class WalletInsightsScreen extends StatefulWidget {
  const WalletInsightsScreen({super.key});

  @override
  State<WalletInsightsScreen> createState() => _WalletInsightsScreenState();
}

class _WalletInsightsScreenState extends State<WalletInsightsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.darkHeroBg),
          );
        }

        if (state is DashboardLoaded) {
          final summary = state.summary;
          final transactions = summary.recentTransactions;

          final Map<ExpenseCategory, double> categoryTotals = {};
          for (final tx in transactions) {
            categoryTotals[tx.category] =
                (categoryTotals[tx.category] ?? 0.0) + tx.amount;
          }

          final now = DateTime.now();
          final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
          final Map<int, double> dailyExpenses = {};

          for (final tx in transactions) {
            if (tx.timestamp.year == now.year &&
                tx.timestamp.month == now.month) {
              final day = tx.timestamp.day;
              dailyExpenses[day] = (dailyExpenses[day] ?? 0.0) + tx.amount;
            }
          }

          final selectedDayTransactions = transactions.where((tx) {
            return tx.timestamp.year == _selectedDate.year &&
                tx.timestamp.month == _selectedDate.month &&
                tx.timestamp.day == _selectedDate.day;
          }).toList();

          final selectedDayTotal = selectedDayTransactions.fold(
              0.0, (acc, tx) => acc + tx.amount);

          final totalIncome = summary.monthlyIncome;
          final totalExpense = summary.totalExpense;
          final survivalBudget = summary.survivalBudget;

          final double usedPercentVal = totalIncome > 0
              ? ((totalExpense / totalIncome) * 100).clamp(0.0, 999.0)
              : 0.0;
          final double remainingPercentVal = totalIncome > 0
              ? ((survivalBudget / totalIncome) * 100).clamp(0.0, 100.0)
              : 0.0;

          return Column(
            children: [
              Container(
                color: AppColors.darkBackground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dompet & Analisis',
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.darkTextPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Pantau kantong saldo & kalender hemat harian',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.darkTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.darkHeroBg,
                        size: 22.0,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),

                      Container(
                        padding: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: AppRadii.borderLg,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Ringkasan Saldo & Penggunaan',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.darkTextSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 3.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: totalIncome > 0
                                        ? AppColors.brandPrimarySurface
                                        : AppColors.darkSurfaceVariant,
                                    borderRadius: BorderRadius.circular(999.0),
                                  ),
                                  child: Text(
                                    totalIncome > 0
                                        ? '${usedPercentVal.toStringAsFixed(0)}% Terpakai'
                                        : '0% Terpakai',
                                    style: TextStyle(
                                      color: totalIncome > 0
                                          ? AppColors.darkExpenseText
                                          : AppColors.darkTextSecondary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              CurrencyFormatter.format(summary.survivalBudget),
                              style: AppTypography.displayBalance.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontSize: 26.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999.0),
                              child: LinearProgressIndicator(
                                value: totalIncome > 0
                                    ? (totalExpense / totalIncome).clamp(0.0, 1.0)
                                    : 0.0,
                                backgroundColor: AppColors.darkSurfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  summary.isDeficit
                                      ? AppColors.darkExpenseText
                                      : const Color(0xFFFF653F),
                                ),
                                minHeight: 6.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    totalIncome > 0
                                        ? '${CurrencyFormatter.format(totalExpense)} terpakai'
                                        : 'Belum ada pengeluaran diinput',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.darkTextSecondary,
                                      fontSize: 11.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  totalIncome > 0
                                      ? 'Sisa ${remainingPercentVal.toStringAsFixed(0)}%'
                                      : '0%',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: totalIncome > 0
                                        ? const Color(0xFFFFC85C)
                                        : AppColors.darkTextSecondary,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              children: [
                                WalletPocketItem(
                                  icon: Icons.account_balance_wallet_rounded,
                                  title: 'Pemasukan',
                                  percent: totalIncome > 0 ? '100%' : '0%',
                                  amount: totalIncome,
                                  color: const Color(0xFFFFC85C),
                                ),
                                const SizedBox(width: 8.0),
                                WalletPocketItem(
                                  icon: Icons.trending_down_rounded,
                                  title: 'Pengeluaran',
                                  percent: '${usedPercentVal.toStringAsFixed(0)}%',
                                  amount: totalExpense,
                                  color: const Color(0xFFFF653F),
                                ),
                                const SizedBox(width: 8.0),
                                WalletPocketItem(
                                  icon: Icons.savings_rounded,
                                  title: 'Sisa Saldo',
                                  percent: '${remainingPercentVal.toStringAsFixed(0)}%',
                                  amount: survivalBudget,
                                  color: const Color(0xFFFFC85C),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14.0),

                      Container(
                        padding: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1A1A20),
                              Color(0xFF121216),
                            ],
                          ),
                          borderRadius: AppRadii.borderMd,
                          border: Border.all(
                            color: AppColors.darkHeroBg.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44.0,
                              height: 44.0,
                              decoration: BoxDecoration(
                                color: AppColors.darkHeroBg.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                color: AppColors.darkHeroBg,
                                size: 24.0,
                              ),
                            ),
                            const SizedBox(width: 14.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Barometer Bertahan Hidup',
                                    style: AppTypography.titleSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'Sisa ${summary.remainingDays} hari sampai siklus baru. Jatah aman ${CurrencyFormatter.format(summary.dailyAllowance)}/hari.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      Container(
                        padding: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: AppRadii.borderLg,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Kalender Hemat Bulanan',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.darkTextPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  '${DateTimeHelpers.getMonthName(now.month)} ${now.year}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.darkHeroBg,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            Row(
                              children: [
                                InsightLegendBadge(AppColors.darkHeroBg, 'Aman/Hemat'),
                                const SizedBox(width: 12.0),
                                InsightLegendBadge(AppColors.darkWarningText, 'Pas'),
                                const SizedBox(width: 12.0),
                                InsightLegendBadge(AppColors.darkExpenseText, 'Boncos'),
                              ],
                            ),
                            const SizedBox(height: 14.0),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                crossAxisSpacing: 6.0,
                                mainAxisSpacing: 6.0,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: daysInMonth,
                              itemBuilder: (context, index) {
                                final day = index + 1;
                                final isSelected = _selectedDate.day == day;
                                final expense = dailyExpenses[day] ?? 0.0;
                                final isFuture = day > now.day;

                                Color dayColor = Colors.transparent;
                                Color textColor = AppColors.darkTextPrimary;

                                if (isFuture) {
                                  textColor = AppColors.darkTextSecondary
                                      .withValues(alpha: 0.35);
                                } else if (expense > 0) {
                                  if (expense <= summary.dailyAllowance) {
                                    dayColor = AppColors.darkHeroBg
                                        .withValues(alpha: 0.25);
                                  } else if (expense <=
                                      summary.dailyAllowance * 1.3) {
                                    dayColor = AppColors.darkWarningText
                                        .withValues(alpha: 0.25);
                                  } else {
                                    dayColor = AppColors.darkExpenseText
                                        .withValues(alpha: 0.25);
                                  }
                                }

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = DateTime(
                                          now.year, now.month, day);
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.darkHeroBg
                                          : dayColor,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.darkHeroBg
                                            : Colors.white.withValues(alpha: 0.05),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$day',
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.darkHeroText
                                              : textColor,
                                          fontSize: 12.0,
                                          fontWeight: isSelected || expense > 0
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14.0),
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: AppColors.darkSurfaceVariant,
                                borderRadius: AppRadii.borderSm,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${_selectedDate.day} ${DateTimeHelpers.getMonthName(_selectedDate.month)}: ${selectedDayTransactions.length} transaksi',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.darkTextPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    CurrencyFormatter.format(selectedDayTotal),
                                    style: AppTypography.titleSmall.copyWith(
                                      color: selectedDayTotal > 0
                                          ? AppColors.darkExpenseText
                                          : AppColors.darkHeroBg,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      Container(
                        padding: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: AppRadii.borderLg,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Proporsi Kategori Pengeluaran',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14.0),
                            if (categoryTotals.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Text(
                                  'Belum ada transaksi bulan ini.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                              )
                            else
                              for (final entry in categoryTotals.entries)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(entry.key.emoji),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                entry.key.label,
                                                style: AppTypography.bodySmall
                                                    .copyWith(
                                                  color: AppColors
                                                      .darkTextPrimary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            CurrencyFormatter.format(
                                                entry.value),
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                              color: AppColors.darkTextPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6.0),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(999.0),
                                        child: LinearProgressIndicator(
                                          value: summary.totalExpense > 0
                                              ? (entry.value /
                                                      summary.totalExpense)
                                                  .clamp(0.0, 1.0)
                                              : 0.0,
                                          backgroundColor:
                                              AppColors.darkSurfaceVariant,
                                          valueColor:
                                              const AlwaysStoppedAnimation<Color>(
                                            AppColors.darkHeroBg,
                                          ),
                                          minHeight: 6.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 110.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
        }

        return const SizedBox.shrink();
      },
    );
  }

}

class WalletPocketItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String percent;
  final double amount;
  final Color color;

  const WalletPocketItem({
    super.key,
    required this.icon,
    required this.title,
    required this.percent,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 16.0, color: color),
                Text(
                  percent,
                  style: TextStyle(
                    color: color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.darkTextSecondary,
                fontSize: 11.0,
              ),
            ),
            const SizedBox(height: 2.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyFormatter.format(amount),
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InsightLegendBadge extends StatelessWidget {
  final Color color;
  final String label;

  const InsightLegendBadge(this.color, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4.0),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.darkTextSecondary,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}
