import 'package:equatable/equatable.dart';
import '../../../expense_logging/domain/entities/transaction_entity.dart';

class DashboardSummaryEntity extends Equatable {
  final double survivalBudget;
  final double dailyAllowance;
  final int remainingDays;
  final double monthlyIncome;
  final String incomeSource;
  final double totalExpense;
  final bool isDeficit;
  final List<TransactionEntity> recentTransactions;

  const DashboardSummaryEntity({
    required this.survivalBudget,
    required this.dailyAllowance,
    required this.remainingDays,
    required this.monthlyIncome,
    this.incomeSource = 'Kiriman Orang Tua',
    required this.totalExpense,
    required this.isDeficit,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        survivalBudget,
        dailyAllowance,
        remainingDays,
        monthlyIncome,
        incomeSource,
        totalExpense,
        isDeficit,
        recentTransactions,
      ];
}
