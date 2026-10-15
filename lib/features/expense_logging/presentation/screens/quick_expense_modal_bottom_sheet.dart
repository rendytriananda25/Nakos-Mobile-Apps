import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/services/local_storage/local_storage_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../domain/entities/transaction_entity.dart';

class QuickExpenseModalBottomSheet extends StatefulWidget {
  const QuickExpenseModalBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => BlocProvider.value(
        value: context.read<DashboardBloc>(),
        child: const QuickExpenseModalBottomSheet(),
      ),
    );
  }

  @override
  State<QuickExpenseModalBottomSheet> createState() =>
      _QuickExpenseModalBottomSheetState();
}

class _QuickExpenseModalBottomSheetState
    extends State<QuickExpenseModalBottomSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  final FocusNode _amountFocusNode = FocusNode();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  bool _isSaving = false;

  final List<ExpenseCategory> _categories = const [
    ExpenseCategory.food,
    ExpenseCategory.snacks,
    ExpenseCategory.transport,
    ExpenseCategory.bills,
    ExpenseCategory.emergency,
    ExpenseCategory.other,
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _titleController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 220), () {
        if (mounted) {
          _amountFocusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal pengeluaran yang valid'),
          backgroundColor: AppColors.darkExpenseBadgeBg,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final storage = LocalStorageService();
      final data = await storage.readData() ?? <String, dynamic>{};

      final transactions = (data['transactions'] as List<dynamic>? ?? [])
          .toList();
      final title = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : _selectedCategory.label;

      transactions.add({
        'id': 'tx_${DateTime.now().microsecondsSinceEpoch}',
        'amount': amount,
        'category': _selectedCategory.name,
        'title': title,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'isIncome': false,
      });

      data['transactions'] = transactions;
      await storage.writeData(data);

      if (mounted) {
        FocusScope.of(context).unfocus();
        context.read<DashboardBloc>().add(const RefreshDashboardEvent());
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tercatat: ${CurrencyFormatter.format(amount)} ($title)',
            ),
            backgroundColor: AppColors.darkSurface,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan transaksi: $e'),
            backgroundColor: AppColors.darkExpenseBadgeBg,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return RepaintBoundary(
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: bottomInset),
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutQuad,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16.0,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: AppColors.darkTextSecondary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Catat Pengeluaran',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.darkTextPrimary,
                          fontSize: 18.0,
                          letterSpacing: -0.2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.darkTextSecondary,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceVariant,
                      borderRadius: AppRadii.borderMd,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Rp',
                          style: AppTypography.displayBalance.copyWith(
                            color: AppColors.darkHeroBg,
                            fontSize: 26.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: AppTypography.displayBalance.copyWith(
                              color: AppColors.darkTextPrimary,
                              fontSize: 28.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: AppTypography.displayBalance.copyWith(
                                color: AppColors.darkTextSecondary.withValues(
                                  alpha: 0.4,
                                ),
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                              ),
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Kategori Pengeluaran',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () {
                              if (!isSelected) {
                                setState(() => _selectedCategory = cat);
                              }
                            },
                            borderRadius: BorderRadius.circular(999.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.darkHeroBg
                                    : AppColors.darkSurfaceVariant,
                                borderRadius: BorderRadius.circular(999.0),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.darkHeroBg
                                      : Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Text(
                                cat.label,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isSelected
                                      ? AppColors.darkHeroText
                                      : AppColors.darkTextPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  TextField(
                    controller: _titleController,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '(misal: Nasi Padang rendang)',
                      prefixIcon: const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.darkTextSecondary,
                        size: 22.0,
                      ),
                      filled: true,
                      fillColor: AppColors.darkSurfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: AppRadii.borderSm,
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadii.borderSm,
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: AppRadii.borderSm,
                        borderSide: BorderSide(
                          color: AppColors.darkHeroBg,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkHeroBg,
                        foregroundColor: AppColors.darkHeroText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22.0,
                              height: 22.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: AppColors.darkHeroText,
                              ),
                            )
                          : Text(
                              'Simpan Transaksi (<3s)',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.darkHeroText,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
