import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_allocation_entity.dart';

abstract class BudgetAllocationState extends Equatable {
  const BudgetAllocationState();

  @override
  List<Object?> get props => [];
}

class BudgetAllocationInitial extends BudgetAllocationState {
  const BudgetAllocationInitial();
}

class BudgetAllocationLoading extends BudgetAllocationState {
  const BudgetAllocationLoading();
}

class BudgetAllocationLoaded extends BudgetAllocationState {
  final BudgetAllocationEntity allocation;
  final bool isSaving;
  final String? userMessage;

  const BudgetAllocationLoaded(
    this.allocation, {
    this.isSaving = false,
    this.userMessage,
  });

  BudgetAllocationLoaded copyWith({
    BudgetAllocationEntity? allocation,
    bool? isSaving,
    String? userMessage,
  }) {
    return BudgetAllocationLoaded(
      allocation ?? this.allocation,
      isSaving: isSaving ?? this.isSaving,
      userMessage: userMessage,
    );
  }

  @override
  List<Object?> get props => [allocation, isSaving, userMessage];
}

class BudgetAllocationError extends BudgetAllocationState {
  final String message;
  const BudgetAllocationError(this.message);

  @override
  List<Object?> get props => [message];
}
