import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/local_storage/local_storage_service.dart';
import '../../../budget_allocation/presentation/screens/budget_allocation_screen.dart';
import '../../../cloud_sync/presentation/screens/profile_sync_screen.dart';
import '../../../expense_logging/presentation/screens/quick_expense_modal_bottom_sheet.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dual_bento_summary_card.dart';
import '../widgets/hero_bento_card.dart';
import '../widgets/recent_activity_section.dart';
import 'wallet_insights_screen.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  int _currentNavIndex = 0;
  String _userName = 'Anak Kost';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboardEvent());
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final data = await LocalStorageService().readData();
    if (data != null && data.containsKey('profile')) {
      final p = data['profile'] as Map<String, dynamic>;
      final name = p['name'] as String?;
      final photo = p['photoUrl'] as String?;
      if (mounted) {
        setState(() {
          if (name != null && name.isNotEmpty) _userName = name;
          _avatarUrl = photo;
        });
      }
    }
  }

  void _openQuickExpense() {
    QuickExpenseModalBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480.0),
                child: Stack(
                  children: [
                    IndexedStack(
                      index: _currentNavIndex,
                      children: [
                        _DashboardView(
                          userName: _userName,
                          avatarUrl: _avatarUrl,
                          onQuickExpenseTap: _openQuickExpense,
                          onProfileTap: () {
                            setState(() => _currentNavIndex = 3);
                          },
                          onAllocationTap: () {
                            setState(() => _currentNavIndex = 1);
                          },
                        ),

                        const BudgetAllocationScreen(),

                        const WalletInsightsScreen(),

                                                const ProfileSyncScreen(),
                      ],
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: FloatingBentoNav(
                        selectedIndex: _currentNavIndex,
                        onIndexChanged: (index) {
                          if (index == 0) {
                            _loadProfileData();
                          }
                          setState(() {
                            _currentNavIndex = index;
                          });
                        },
                        onAddPressed: _openQuickExpense,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback onQuickExpenseTap;
  final VoidCallback onProfileTap;
  final VoidCallback onAllocationTap;

  const _DashboardView({
    required this.userName,
    this.avatarUrl,
    required this.onQuickExpenseTap,
    required this.onProfileTap,
    required this.onAllocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardHeader(
          userName: userName,
          avatarUrl: avatarUrl,
          onQuickExpenseTap: onQuickExpenseTap,
          onProfileTap: onProfileTap,
        ),

        Expanded(
          child: RefreshIndicator(
            color: AppColors.darkHeroBg,
            backgroundColor: AppColors.darkSurface,
            onRefresh: () async {
              context.read<DashboardBloc>().add(const RefreshDashboardEvent());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverToBoxAdapter(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkHeroBg,
                        ),
                      ),
                    );
                  }

                  if (state is DashboardError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: AppColors.darkExpenseText,
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is DashboardLoaded) {
                    final summary = state.summary;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8.0),

                        HeroBentoCard(
                          survivalBudget: summary.survivalBudget,
                          dailyAllowance: summary.dailyAllowance,
                          onMenuTap: onAllocationTap,
                        ),
                        const SizedBox(height: 13.0),

                        DualBentoSummaryCard(
                          monthlyIncome: summary.monthlyIncome,
                          totalExpense: summary.totalExpense,
                          incomeSource: summary.incomeSource,
                        ),
                        const SizedBox(height: 18.0),

                        RecentActivitySection(
                          transactions: summary.recentTransactions,
                          onViewAllTap: () {},
                          onTransactionTap: (tx) {},
                        ),

                        const SizedBox(height: 100.0),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    ),
  ),
],
);
  }
}
