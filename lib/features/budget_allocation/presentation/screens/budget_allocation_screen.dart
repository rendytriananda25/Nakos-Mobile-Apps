import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_helpers.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../domain/entities/mandatory_expense_item.dart';
import '../bloc/budget_allocation_bloc.dart';
import '../bloc/budget_allocation_event.dart';
import '../bloc/budget_allocation_state.dart';

class BudgetAllocationScreen extends StatefulWidget {
  const BudgetAllocationScreen({super.key});

  @override
  State<BudgetAllocationScreen> createState() => _BudgetAllocationScreenState();
}

class _BudgetAllocationScreenState extends State<BudgetAllocationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetAllocationBloc>().add(const LoadBudgetAllocationEvent());
  }

  void _showAddExpenseModal(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28.0)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
          ),
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 14.0,
            bottom: MediaQuery.viewInsetsOf(bottomSheetContext).bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: AppColors.darkTextSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999.0),
                  ),
                ),
              ),
              const SizedBox(height: 18.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tambah Kebutuhan Wajib',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontSize: 18.0,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.darkTextSecondary),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: titleController,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.darkTextPrimary),
                decoration: InputDecoration(
                  labelText: 'Nama Kebutuhan (misal: Laundry, Cicilan)',
                  labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
                  filled: true,
                  fillColor: AppColors.darkSurfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.borderSm,
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadii.borderSm,
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadii.borderSm,
                    borderSide:
                        BorderSide(color: AppColors.darkHeroBg, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 14.0),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.darkHeroBg,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Nominal (Rp)',
                  labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                      color: AppColors.darkHeroBg, fontWeight: FontWeight.w700),
                  filled: true,
                  fillColor: AppColors.darkSurfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.borderSm,
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadii.borderSm,
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadii.borderSm,
                    borderSide:
                        BorderSide(color: AppColors.darkHeroBg, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amount = CurrencyFormatter.parse(amountController.text);
                    if (title.isEmpty || amount <= 0) return;

                    context.read<BudgetAllocationBloc>().add(
                          AddMandatoryExpenseEvent(
                            MandatoryExpenseItem(
                              id: 'mand_${DateTime.now().microsecondsSinceEpoch}',
                              title: title,
                              amount: amount,
                              isPaid: false,
                            ),
                          ),
                        );
                    Navigator.pop(bottomSheetContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkHeroBg,
                    foregroundColor: AppColors.darkHeroText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: Text(
                    'Tambahkan Item',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.darkHeroText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditIncomeDialog(
    BuildContext context,
    double currentIncome,
    String currentSource,
    int currentCycleStartDay,
  ) {
    final incomeCtrl = TextEditingController(
      text: currentIncome > 0 ? currentIncome.toInt().toString() : '',
    );
    String selectedSource = currentSource.isNotEmpty ? currentSource : 'Kiriman Orang Tua';
    final validSources = ['Gaji', 'Kiriman Orang Tua'];
    if (!validSources.contains(selectedSource)) {
      selectedSource = 'Kiriman Orang Tua';
    }
    int selectedDay = currentCycleStartDay.clamp(1, 31);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.darkHeroBg.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.darkHeroBg,
                      size: 20.0,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    'Atur Pemasukan',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemasukan Bulanan',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    TextField(
                      controller: incomeCtrl,
                      keyboardType: TextInputType.number,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.darkHeroBg,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                          color: AppColors.darkHeroBg,
                          fontWeight: FontWeight.w700,
                        ),
                        filled: true,
                        fillColor: AppColors.darkSurfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: AppColors.darkHeroBg,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18.0),
                    Text(
                      'Sumber Pemasukan',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: AppColors.darkSurface,
                      ),
                      child: PopupMenuButton<String>(
                        key: const Key('dropdown_sumber_pemasukan'),
                        position: PopupMenuPosition.under,
                        offset: const Offset(0, 6),
                        color: AppColors.darkSurface,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.0,
                          ),
                        ),
                        onSelected: (val) {
                          setDialogState(() {
                            selectedSource = val;
                          });
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'Gaji',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.work_rounded,
                                  size: 18.0,
                                  color: AppColors.darkHeroBg,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    'Gaji (Pekerja)',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: selectedSource == 'Gaji'
                                          ? AppColors.darkHeroBg
                                          : AppColors.darkTextPrimary,
                                      fontWeight: selectedSource == 'Gaji'
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                if (selectedSource == 'Gaji')
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 18.0,
                                    color: AppColors.darkHeroBg,
                                  ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(height: 1.0),
                          PopupMenuItem<String>(
                            value: 'Kiriman Orang Tua',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.family_restroom_rounded,
                                  size: 18.0,
                                  color: AppColors.darkIncomeText,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    'Kiriman Orang Tua',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: selectedSource == 'Kiriman Orang Tua'
                                          ? AppColors.darkHeroBg
                                          : AppColors.darkTextPrimary,
                                      fontWeight: selectedSource == 'Kiriman Orang Tua'
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                if (selectedSource == 'Kiriman Orang Tua')
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 18.0,
                                    color: AppColors.darkHeroBg,
                                  ),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 13.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurfaceVariant,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selectedSource == 'Gaji'
                                    ? Icons.work_rounded
                                    : Icons.family_restroom_rounded,
                                size: 18.0,
                                color: selectedSource == 'Gaji'
                                    ? AppColors.darkHeroBg
                                    : AppColors.darkIncomeText,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  selectedSource == 'Gaji'
                                      ? 'Gaji (Pekerja)'
                                      : 'Kiriman Orang Tua',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.darkTextPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.darkHeroBg,
                                size: 22.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18.0),
                    Text(
                      'Tanggal Gajian / Awal Siklus',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onTap: () async {
                        final now = DateTime.now();
                        final maxDays = DateUtils.getDaysInMonth(now.year, now.month);
                        final initialDay = selectedDay.clamp(1, maxDays);
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(now.year, now.month, initialDay),
                          firstDate: DateTime(now.year - 1, 1, 1),
                          lastDate: DateTime(now.year + 2, 12, 31),
                          helpText: 'PILIH TANGGAL GAJIAN',
                          cancelText: 'BATAL',
                          confirmText: 'PILIH',
                          builder: (pickerContext, child) {
                            return Theme(
                              data: Theme.of(pickerContext).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.darkHeroBg,
                                  onPrimary: AppColors.darkHeroText,
                                  surface: AppColors.darkSurface,
                                  onSurface: AppColors.darkTextPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDay = picked.day;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7.0),
                              decoration: BoxDecoration(
                                color: AppColors.darkHeroBg.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                size: 18.0,
                                color: AppColors.darkHeroBg,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal $selectedDay setiap bulan',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.darkTextPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'Sisa ${DateTimeHelpers.getRemainingDaysInCycle(cycleStartDay: selectedDay)} hari ke siklus baru • Buka Kalender',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.darkHeroBg,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.edit_calendar_rounded,
                              color: AppColors.darkHeroBg,
                              size: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: AppColors.darkTextSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final income = CurrencyFormatter.parse(incomeCtrl.text);
                    context.read<BudgetAllocationBloc>().add(
                          UpdateMonthlyIncomeEvent(
                            income,
                            incomeSource: selectedSource,
                            cycleStartDay: selectedDay,
                          ),
                        );
                    Navigator.pop(dialogContext);
                    await Future.delayed(const Duration(milliseconds: 150));
                    if (context.mounted) {
                      context.read<DashboardBloc>().add(
                            const RefreshDashboardEvent(),
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkHeroBg,
                    foregroundColor: AppColors.darkHeroText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditSavingsDialog(BuildContext context, double currentSavings) {
    final savingsCtrl = TextEditingController(
      text: currentSavings > 0 ? currentSavings.toInt().toString() : '',
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.darkIncomeText.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppColors.darkIncomeText,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Target Tabungan',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target Tabungan Dingin Bulanan',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6.0),
              TextField(
                controller: savingsCtrl,
                keyboardType: TextInputType.number,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.darkIncomeText,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    color: AppColors.darkIncomeText,
                    fontWeight: FontWeight.w700,
                  ),
                  filled: true,
                  fillColor: AppColors.darkSurfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: AppColors.darkIncomeText,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.darkTextSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final savings = CurrencyFormatter.parse(savingsCtrl.text);
                context.read<BudgetAllocationBloc>().add(
                      UpdateSavingsTargetEvent(savings),
                    );
                context.read<DashboardBloc>().add(
                      const RefreshDashboardEvent(),
                    );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkHeroBg,
                foregroundColor: AppColors.darkHeroText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BudgetAllocationBloc, BudgetAllocationState>(
      listener: (context, state) {
        if (state is BudgetAllocationLoaded && state.userMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.userMessage!),
              backgroundColor: AppColors.darkSurface,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BudgetAllocationLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.darkHeroBg),
          );
        }

        if (state is BudgetAllocationError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.darkExpenseText),
            ),
          );
        }

        if (state is BudgetAllocationLoaded) {
          final allocation = state.allocation;

          return Column(
            children: [
              // Fixed Screen Header (Nametag as Fixed Header)
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
                            'Alokasi Anggaran',
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.darkTextPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Kunci kebutuhan wajib & amankan uang dingin',
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
                        Icons.receipt_long_rounded,
                        color: AppColors.darkHeroBg,
                        size: 22.0,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  slivers: [
                    // Content Body
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),

                      // Bento 1: Survival Budget Realtime Barometer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF1A1A20),
                              Color(0xFF121216),
                            ],
                          ),
                          borderRadius: AppRadii.borderLg,
                          border: Border.all(
                            color: AppColors.darkHeroBg.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkHeroBg.withValues(alpha: 0.08),
                              blurRadius: 24.0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8.0,
                                        height: 8.0,
                                        decoration: const BoxDecoration(
                                          color: AppColors.darkHeroBg,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          'SURVIVAL BUDGET (UANG DINGIN)',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.darkHeroBg,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(999.0),
                                  ),
                                  child: Text(
                                    '${CurrencyFormatter.format(allocation.dailyAllowance)} / hari',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              CurrencyFormatter.format(allocation.survivalBudget),
                              style: AppTypography.displayBalance.copyWith(
                                color: Colors.white,
                                fontSize: 32.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              'Pemasukan (${CurrencyFormatter.format(allocation.monthlyIncome)}) - Wajib (${CurrencyFormatter.format(allocation.totalMandatory)}) - Tabungan (${CurrencyFormatter.format(allocation.savingsTarget)})',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Bento 2: Dual Quick Stats (Pemasukan & Tabungan)
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: AppColors.darkSurface,
                              borderRadius: AppRadii.borderMd,
                              child: InkWell(
                                borderRadius: AppRadii.borderMd,
                                onTap: () => _showEditIncomeDialog(
                                  context,
                                  allocation.monthlyIncome,
                                  allocation.incomeSource,
                                  allocation.cycleStartDay,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.borderMd,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Pemasukan',
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.darkTextSecondary,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.edit_rounded,
                                            size: 15.0,
                                            color: AppColors.darkHeroBg,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6.0),
                                      Wrap(
                                        spacing: 6.0,
                                        runSpacing: 4.0,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                              vertical: 2.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.darkHeroBg.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6.0),
                                            ),
                                            child: Text(
                                              allocation.incomeSource,
                                              style: AppTypography.labelSmall.copyWith(
                                                color: AppColors.darkHeroBg,
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                              vertical: 2.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.darkIncomeText.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6.0),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.calendar_month_rounded,
                                                  size: 11.0,
                                                  color: AppColors.darkIncomeText,
                                                ),
                                                const SizedBox(width: 3.0),
                                                Text(
                                                  'Gajian Tgl ${allocation.cycleStartDay}',
                                                  style: AppTypography.labelSmall.copyWith(
                                                    color: AppColors.darkIncomeText,
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          CurrencyFormatter.format(
                                              allocation.monthlyIncome),
                                          style:
                                              AppTypography.headlineMedium.copyWith(
                                            color: AppColors.darkTextPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Material(
                              color: AppColors.darkSurface,
                              borderRadius: AppRadii.borderMd,
                              child: InkWell(
                                borderRadius: AppRadii.borderMd,
                                onTap: () => _showEditSavingsDialog(
                                  context,
                                  allocation.savingsTarget,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.borderMd,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tabungan',
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.darkTextSecondary,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.edit_rounded,
                                            size: 15.0,
                                            color: AppColors.darkIncomeText,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkIncomeText.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6.0),
                                        ),
                                        child: Text(
                                          'Uang Dingin',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.darkIncomeText,
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          CurrencyFormatter.format(
                                              allocation.savingsTarget),
                                          style:
                                              AppTypography.headlineMedium.copyWith(
                                            color: AppColors.darkIncomeText,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22.0),

                      // Section Header: Kebutuhan Wajib / Harga Mati
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kebutuhan Wajib (Harga Mati)',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.darkTextPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  '${allocation.mandatoryExpenses.length} pos • Total ${CurrencyFormatter.format(allocation.totalMandatory)}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.darkTextSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          TextButton.icon(
                            onPressed: () => _showAddExpenseModal(context),
                            icon: const Icon(Icons.add_rounded,
                                size: 18.0, color: AppColors.darkHeroBg),
                            label: Text(
                              'Tambah',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.darkHeroBg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),

                      // List of Mandatory Items
                      if (allocation.mandatoryExpenses.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 24.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: AppRadii.borderMd,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Center(
                            child: Text(
                              'Belum ada pos kebutuhan wajib.\nTekan "+ Tambah" di atas untuk memasukkan pengeluaran rutin.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.darkTextSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        for (final item in allocation.mandatoryExpenses)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: AppRadii.borderMd,
                            border: Border.all(
                              color: item.isPaid
                                  ? AppColors.darkHeroBg.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Paid checkbox toggle
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.read<BudgetAllocationBloc>().add(
                                        ToggleMandatoryExpensePaidEvent(item.id),
                                      );
                                },
                                child: Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: item.isPaid
                                        ? AppColors.darkHeroBg
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6.0),
                                    border: Border.all(
                                      color: item.isPaid
                                          ? AppColors.darkHeroBg
                                          : AppColors.darkTextSecondary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: item.isPaid
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 16.0,
                                          color: AppColors.darkHeroText,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              // Title & status
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: AppTypography.titleSmall.copyWith(
                                        color: item.isPaid
                                            ? AppColors.darkTextSecondary
                                            : AppColors.darkTextPrimary,
                                        fontWeight: FontWeight.w600,
                                        decoration: item.isPaid
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      item.isPaid ? 'Sudah Terbayar' : 'Belum Dibayar',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: item.isPaid
                                            ? AppColors.darkHeroBg
                                            : AppColors.darkWarningText,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Amount & delete
                              Text(
                                CurrencyFormatter.format(item.amount),
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.darkTextPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 19.0,
                                  color: AppColors.darkTextSecondary,
                                ),
                                onPressed: () {
                                  context.read<BudgetAllocationBloc>().add(
                                        RemoveMandatoryExpenseEvent(item.id),
                                      );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20.0),

                      // Save Allocation Configuration Button
                      SizedBox(
                        width: double.infinity,
                        height: 52.0,
                        child: ElevatedButton(
                          onPressed: state.isSaving
                              ? null
                              : () async {
                                  HapticFeedback.mediumImpact();
                                  context.read<BudgetAllocationBloc>().add(
                                        const SaveBudgetAllocationEvent(),
                                      );
                                  await Future.delayed(const Duration(milliseconds: 150));
                                  if (context.mounted) {
                                    context.read<DashboardBloc>().add(
                                          const RefreshDashboardEvent(),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkHeroBg,
                            foregroundColor: AppColors.darkHeroText,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          child: state.isSaving
                              ? const SizedBox(
                                  width: 22.0,
                                  height: 22.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.darkHeroText,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded,
                                        size: 20.0),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      'Simpan Alokasi Anggaran',
                                      style: AppTypography.titleSmall.copyWith(
                                        color: AppColors.darkHeroText,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      // Bottom clearance for floating navbar
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
