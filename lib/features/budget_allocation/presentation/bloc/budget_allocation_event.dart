import 'package:equatable/equatable.dart';
import '../../domain/entities/mandatory_expense_item.dart';

abstract class BudgetAllocationEvent extends Equatable {
  const BudgetAllocationEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgetAllocationEvent extends BudgetAllocationEvent {
  const LoadBudgetAllocationEvent();
}

class UpdateMonthlyIncomeEvent extends BudgetAllocationEvent {
  final double income;
  final String? incomeSource;
  final int? cycleStartDay;
  const UpdateMonthlyIncomeEvent(
    this.income, {
    this.incomeSource,
    this.cycleStartDay,
  });

  @override
  List<Object?> get props => [income, incomeSource, cycleStartDay];
}

class UpdateIncomeSourceEvent extends BudgetAllocationEvent {
  final String incomeSource;
  const UpdateIncomeSourceEvent(this.incomeSource);

  @override
  List<Object?> get props => [incomeSource];
}

class UpdateSavingsTargetEvent extends BudgetAllocationEvent {
  final double savingsTarget;
  const UpdateSavingsTargetEvent(this.savingsTarget);

  @override
  List<Object?> get props => [savingsTarget];
}

class UpdateCycleStartDayEvent extends BudgetAllocationEvent {
  final int cycleStartDay;
  const UpdateCycleStartDayEvent(this.cycleStartDay);

  @override
  List<Object?> get props => [cycleStartDay];
}

class AddMandatoryExpenseEvent extends BudgetAllocationEvent {
  final MandatoryExpenseItem item;
  const AddMandatoryExpenseEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveMandatoryExpenseEvent extends BudgetAllocationEvent {
  final String id;
  const RemoveMandatoryExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleMandatoryExpensePaidEvent extends BudgetAllocationEvent {
  final String id;
  const ToggleMandatoryExpensePaidEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SaveBudgetAllocationEvent extends BudgetAllocationEvent {
  const SaveBudgetAllocationEvent();
}
