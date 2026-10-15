import 'package:equatable/equatable.dart';
import '../../../../core/utils/date_time_helpers.dart';
import 'mandatory_expense_item.dart';

class BudgetAllocationEntity extends Equatable {
  final double monthlyIncome;
  final String incomeSource;
  final double savingsTarget;
  final int cycleStartDay;
  final List<MandatoryExpenseItem> mandatoryExpenses;

  const BudgetAllocationEntity({
    required this.monthlyIncome,
    this.incomeSource = 'Kiriman Orang Tua',
    required this.savingsTarget,
    this.cycleStartDay = 1,
    required this.mandatoryExpenses,
  });

  double get totalMandatory =>
      mandatoryExpenses.fold(0.0, (acc, item) => acc + item.amount);

  double get totalPaidMandatory => mandatoryExpenses
      .where((item) => item.isPaid)
      .fold(0.0, (acc, item) => acc + item.amount);

  double get totalUnpaidMandatory => mandatoryExpenses
      .where((item) => !item.isPaid)
      .fold(0.0, (acc, item) => acc + item.amount);

  double get survivalBudget =>
      monthlyIncome - (totalMandatory + savingsTarget);

  double get dailyAllowance {
    final remainingDays =
        DateTimeHelpers.getRemainingDaysInCycle(cycleStartDay: cycleStartDay);
    return survivalBudget > 0 ? (survivalBudget / remainingDays) : 0.0;
  }

  bool get isDeficit => survivalBudget < 0;

  BudgetAllocationEntity copyWith({
    double? monthlyIncome,
    String? incomeSource,
    double? savingsTarget,
    int? cycleStartDay,
    List<MandatoryExpenseItem>? mandatoryExpenses,
  }) {
    return BudgetAllocationEntity(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      incomeSource: incomeSource ?? this.incomeSource,
      savingsTarget: savingsTarget ?? this.savingsTarget,
      cycleStartDay: cycleStartDay ?? this.cycleStartDay,
      mandatoryExpenses: mandatoryExpenses ?? this.mandatoryExpenses,
    );
  }

  Map<String, dynamic> toJson() => {
        'monthlyIncome': monthlyIncome,
        'incomeSource': incomeSource,
        'savingsTarget': savingsTarget,
        'cycleStartDay': cycleStartDay,
        'mandatoryExpenses': mandatoryExpenses.map((e) => e.toJson()).toList(),
      };

  factory BudgetAllocationEntity.fromJson(Map<String, dynamic> json) {
    final rawMandatory = json['mandatoryExpenses'] as List<dynamic>? ?? [];
    return BudgetAllocationEntity(
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      incomeSource: (json['incomeSource'] as String?) ?? 'Kiriman Orang Tua',
      savingsTarget: (json['savingsTarget'] as num?)?.toDouble() ?? 0.0,
      cycleStartDay: (json['cycleStartDay'] as num?)?.toInt() ?? 1,
      mandatoryExpenses: rawMandatory
          .map((item) =>
              MandatoryExpenseItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static BudgetAllocationEntity defaultInitial() {
    return const BudgetAllocationEntity(
      monthlyIncome: 0.0,
      incomeSource: 'Kiriman Orang Tua',
      savingsTarget: 0.0,
      cycleStartDay: 1,
      mandatoryExpenses: [],
    );
  }

  @override
  List<Object?> get props => [
        monthlyIncome,
        incomeSource,
        savingsTarget,
        cycleStartDay,
        mandatoryExpenses,
      ];
}
