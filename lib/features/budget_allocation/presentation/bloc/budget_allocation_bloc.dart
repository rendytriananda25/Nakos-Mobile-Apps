import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/local_storage/local_storage_service.dart';
import '../../domain/entities/budget_allocation_entity.dart';
import 'budget_allocation_event.dart';
import 'budget_allocation_state.dart';

class BudgetAllocationBloc
    extends Bloc<BudgetAllocationEvent, BudgetAllocationState> {
  final LocalStorageService _storageService;

  BudgetAllocationBloc({LocalStorageService? storageService})
      : _storageService = storageService ?? LocalStorageService(),
        super(BudgetAllocationLoaded(BudgetAllocationEntity.defaultInitial())) {
    on<LoadBudgetAllocationEvent>(_onLoadBudgetAllocation);
    on<UpdateMonthlyIncomeEvent>(_onUpdateMonthlyIncome);
    on<UpdateIncomeSourceEvent>(_onUpdateIncomeSource);
    on<UpdateSavingsTargetEvent>(_onUpdateSavingsTarget);
    on<UpdateCycleStartDayEvent>(_onUpdateCycleStartDay);
    on<AddMandatoryExpenseEvent>(_onAddMandatoryExpense);
    on<RemoveMandatoryExpenseEvent>(_onRemoveMandatoryExpense);
    on<ToggleMandatoryExpensePaidEvent>(_onToggleMandatoryExpensePaid);
    on<SaveBudgetAllocationEvent>(_onSaveBudgetAllocation);
  }

  Future<void> _onLoadBudgetAllocation(
    LoadBudgetAllocationEvent event,
    Emitter<BudgetAllocationState> emit,
  ) async {
    try {
      await _storageService.cleanLegacyDummyData();
      final rawData = await _storageService.readData();
      if (rawData != null && rawData.containsKey('budgetConfig')) {
        final config = rawData['budgetConfig'] as Map<String, dynamic>;
        final allocation = BudgetAllocationEntity.fromJson(config);
        final cleanExpenses = allocation.mandatoryExpenses
            .where((item) => !['mand_01', 'mand_02', 'mand_03', 'mand_04'].contains(item.id))
            .toList();
        emit(BudgetAllocationLoaded(allocation.copyWith(mandatoryExpenses: cleanExpenses)));
      } else {
        emit(BudgetAllocationLoaded(BudgetAllocationEntity.defaultInitial()));
      }
    } catch (_) {
      emit(BudgetAllocationLoaded(BudgetAllocationEntity.defaultInitial()));
    }
  }

  Future<void> _onUpdateMonthlyIncome(
    UpdateMonthlyIncomeEvent event,
    Emitter<BudgetAllocationState> emit,
  ) async {
    if (state is BudgetAllocationLoaded) {
      final current = (state as BudgetAllocationLoaded).allocation;
      final updated = current.copyWith(
        monthlyIncome: event.income,
        incomeSource: event.incomeSource ?? current.incomeSource,
        cycleStartDay: event.cycleStartDay ?? current.cycleStartDay,
      );
      emit((state as BudgetAllocationLoaded).copyWith(
        allocation: updated,
      ));
      try {
        final rawData = await _storageService.readData() ?? <String, dynamic>{};
        rawData['budgetConfig'] = updated.toJson();
        await _storageService.writeData(rawData);
      } catch (_) {}
    }
  }

  Future<void> _onUpdateIncomeSource(
    UpdateIncomeSourceEvent event,
    Emitter<BudgetAllocationState> emit,
  ) async {
    if (state is BudgetAllocationLoaded) {
      final current = (state as BudgetAllocationLoaded).allocation;
      final updated = current.copyWith(incomeSource: event.incomeSource);
      emit((state as BudgetAllocationLoaded).copyWith(
        allocation: updated,
      ));
      try {
        final rawData = await _storageService.readData() ?? <String, dynamic>{};
        rawData['budgetConfig'] = updated.toJson();
        await _storageService.writeData(rawData);
      } catch (_) {}
    }
  }

  Future<void> _onUpdateSavingsTarget(
    UpdateSavingsTargetEvent event,
    Emitter<BudgetAllocationState> emit,
  ) async {
    if (state is BudgetAllocationLoaded) {
      final current = (state as BudgetAllocationLoaded).allocation;
      final updated = current.copyWith(savingsTarget: event.savingsTarget);
      emit((state as BudgetAllocationLoaded).copyWith(
        allocation: updated,
      ));
      try {
        final rawData = await _storageService.readData() ?? <String, dynamic>{};
        rawData['budgetConfig'] = updated.toJson();
        await _storageService.writeData(rawData);
      } catch (_) {}
    }
  }

  Future<void> _onUpdateCycleStartDay(
    UpdateCycleStartDayEvent event,
    Emitter<BudgetAllocationState> emit,
  ) async {
    if (state is BudgetAllocationLoaded) {
      final current = (state as BudgetAllocationLoaded).allocation;
      final updated = current.copyWith(cycleStartDay: event.cycleStartDay);
      emit((state as BudgetAllocationLoaded).copyWith(
        allocation: updated,
      ));
      try {
        final rawData = await _storageService.readData() ?? <String, dynamic>{};
        rawData['budgetConfig'] = updated.toJson();
        await _storageService.writeData(rawData);
      } catch (_) {}
    }
  }

  void _onAddMandatoryExpense(
    AddMandatoryExpenseEvent event,
    Emitter<BudgetAllocationState> emit,
  ) {
    if (state is BudgetAllocationLoaded) {
      final current = (state as BudgetAllocationLoaded).allocation;
      final updatedList = List.of(current.mandatoryExpenses)..add(event.item);
      emit((state as BudgetAllocationLoaded).copyWith(
        allocation: current.copyWith(mandatoryExpenses: updatedList),
      ));
    }
  }

  void _onRemoveMandatoryExpense(
    RemoveMandatoryExpenseEvent event,
    Emitter<BudgetAllocationState> emit,
  ) {
    if (state is BudgetAllocationLoaded) {
      final current = (state as BudgetAllocationLoaded).allocation;
      final updatedList = current.mandatoryExpenses
          .where((item) => item.id != event.id)
          .toList();
      emit((state as BudgetAllocationLoaded).copyWith(
        allocation: current.copyWith(mandatoryExpenses: updatedList),
      ));
    }
  }

  Future<void> _onToggleMandatoryExpensePaid(
    ToggleMandatoryExpensePaidEvent event,
    Emitter<BudgetAllocationState> emit,
  ) async {
    if (state is BudgetAllocationLoaded) {
      final current = (state as BudgetAllocationLoaded).allocation;
      final updatedList = current.mandatoryExpenses.map((item) {
        if (item.id == event.id) {
          return item.copyWith(isPaid: !item.isPaid);
        }
        return item;
      }).toList();

      final updatedAllocation =
          current.copyWith(mandatoryExpenses: updatedList);
      emit((state as BudgetAllocationLoaded).copyWith(
        allocation: updatedAllocation,
      ));

      // Auto-save paid status immediately to local storage
      try {
        final rawData = await _storageService.readData() ?? <String, dynamic>{};
        rawData['budgetConfig'] = updatedAllocation.toJson();
        await _storageService.writeData(rawData);
      } catch (_) {
        // Silently handle quick auto-save
      }
    }
  }

  Future<void> _onSaveBudgetAllocation(
    SaveBudgetAllocationEvent event,
    Emitter<BudgetAllocationState> emit,
  ) async {
    if (state is BudgetAllocationLoaded) {
      final current = (state as BudgetAllocationLoaded).allocation;
      emit((state as BudgetAllocationLoaded).copyWith(isSaving: true));

      try {
        final rawData = await _storageService.readData() ?? <String, dynamic>{};
        rawData['budgetConfig'] = current.toJson();
        await _storageService.writeData(rawData);

        emit((state as BudgetAllocationLoaded).copyWith(
          isSaving: false,
          userMessage: 'Alokasi anggaran berhasil disimpan!',
        ));
      } catch (e) {
        emit((state as BudgetAllocationLoaded).copyWith(
          isSaving: false,
          userMessage: 'Gagal menyimpan: $e',
        ));
      }
    }
  }
}
