import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/local_storage/local_storage_service.dart';
import '../../../../core/utils/date_time_helpers.dart';
import '../../../expense_logging/domain/entities/transaction_entity.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final LocalStorageService _storageService;

  DashboardBloc({LocalStorageService? storageService})
      : _storageService = storageService ?? LocalStorageService(),
        super(DashboardLoaded(_getInitialCleanSummary())) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadSummary(emit);
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadSummary(emit);
  }

  Future<void> _loadSummary(Emitter<DashboardState> emit) async {
    try {
      await _storageService.cleanLegacyDummyData();
      final rawData = await _storageService.readData();

      if (rawData != null && rawData.containsKey('budgetConfig')) {
        final budgetConfig = rawData['budgetConfig'] as Map<String, dynamic>;
        final monthlyIncome = (budgetConfig['monthlyIncome'] as num?)?.toDouble() ?? 0.0;
        final incomeSource = (budgetConfig['incomeSource'] as String?) ?? 'Kiriman Orang Tua';
        final savingsTarget = (budgetConfig['savingsTarget'] as num?)?.toDouble() ?? 0.0;
        final cycleStartDay = (budgetConfig['cycleStartDay'] as num?)?.toInt() ?? 1;

        double totalMandatory = 0.0;
        if (budgetConfig['mandatoryExpenses'] is List) {
          for (final item in budgetConfig['mandatoryExpenses']) {
            if (item is Map) {
              final id = item['id'] as String? ?? '';
              if (!['mand_01', 'mand_02', 'mand_03', 'mand_04'].contains(id)) {
                totalMandatory += (item['amount'] as num?)?.toDouble() ?? 0.0;
              }
            }
          }
        }

        final rawTransactions = rawData['transactions'] as List<dynamic>? ?? [];
        final List<TransactionEntity> transactions = [];
        double totalExpense = 0.0;

        for (final tx in rawTransactions) {
          if (tx is Map<String, dynamic>) {
            final id = tx['id'] as String? ?? '';
            if (['tx_01', 'tx_02', 'tx_03', 'tx_04'].contains(id)) {
              continue;
            }
            final amt = (tx['amount'] as num?)?.toDouble() ?? 0.0;
            totalExpense += amt;
            transactions.add(
              TransactionEntity(
                id: id.isNotEmpty ? id : DateTime.now().microsecondsSinceEpoch.toString(),
                title: tx['title'] as String? ?? 'Pengeluaran',
                amount: amt,
                category: _parseCategory(tx['category'] as String?),
                timestamp: DateTime.tryParse(tx['timestamp'] as String? ?? '') ?? DateTime.now(),
                isIncome: tx['isIncome'] as bool? ?? false,
              ),
            );
          }
        }

        final survivalBudget = monthlyIncome - (totalMandatory + savingsTarget) - totalExpense;
        final remainingDays = DateTimeHelpers.getRemainingDaysInCycle(cycleStartDay: cycleStartDay);
        final dailyAllowance = survivalBudget > 0 ? (survivalBudget / remainingDays) : 0.0;

        emit(
          DashboardLoaded(
            DashboardSummaryEntity(
              survivalBudget: survivalBudget,
              dailyAllowance: dailyAllowance,
              remainingDays: remainingDays,
              monthlyIncome: monthlyIncome,
              incomeSource: incomeSource,
              totalExpense: totalExpense,
              isDeficit: survivalBudget < 0,
              recentTransactions: transactions.reversed.take(10).toList(),
            ),
          ),
        );
      } else {
        emit(DashboardLoaded(_getInitialCleanSummary()));
      }
    } catch (_) {
      emit(DashboardLoaded(_getInitialCleanSummary()));
    }
  }

  ExpenseCategory _parseCategory(String? raw) {
    if (raw == null) return ExpenseCategory.other;
    return ExpenseCategory.values.firstWhere(
      (cat) => cat.name.toLowerCase() == raw.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }

  static DashboardSummaryEntity _getInitialCleanSummary() {
    return DashboardSummaryEntity(
      survivalBudget: 0.0,
      dailyAllowance: 0.0,
      remainingDays: DateTimeHelpers.getRemainingDaysInCycle(),
      monthlyIncome: 0.0,
      totalExpense: 0.0,
      isDeficit: false,
      recentTransactions: const [],
    );
  }
}
