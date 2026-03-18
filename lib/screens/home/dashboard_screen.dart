import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_text.dart';
import '../../widgets/stat_tile.dart';
import '../../utils/currency_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load savings and loans data when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsProvider>().loadData();
      context.read<LoanProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final savings = context.watch<SavingsProvider>();
    final loans = context.watch<LoanProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          backgroundColor: AppColors.cardBg,
          onRefresh: () async {
            await Future.wait([
              context.read<AuthProvider>().refreshProfile(),
              context.read<SavingsProvider>().loadData(),
              context.read<LoanProvider>().loadData(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.name ?? 'User',
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.notifications),
                          icon: Stack(
                            children: [
                              const Icon(Icons.notifications_outlined,
                                  color: AppColors.textSecondary, size: 26),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppColors.actionRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.gold.withAlpha(30),
                          child: Text(
                            (user?.name ?? 'U')[0].toUpperCase(),
                            style: GoogleFonts.orbitron(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Total Savings Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL SAVINGS',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                              letterSpacing: 2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.trending_up,
                                    color: AppColors.success, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '+12.5%',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GlowText(
                        text: CurrencyFormatter.formatMK(user?.savingsBalance ?? 0),
                        fontSize: 34,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Quick Stats Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.account_balance_wallet,
                        label: 'LOAN BALANCE',
                        value: CurrencyFormatter.formatMK(
                            loans.activeLoan?.remainingBalance ?? 0),
                        iconColor: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: Icons.speed_rounded,
                        label: 'FINANCIAL SCORE',
                        value: '${user?.financialScore ?? 0}',
                        iconColor: AppColors.gold,
                        valueColor: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.savings_rounded,
                        label: 'ACTIVE PLANS',
                        value: '${savings.plans.where((p) => p.isActive).length}',
                        iconColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: Icons.warning_amber_rounded,
                        label: 'PENALTIES',
                        value: CurrencyFormatter.formatCompact(savings.totalPenalties),
                        iconColor: AppColors.actionRed,
                        valueColor: AppColors.actionRed,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'QUICK ACTIONS',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 95,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _QuickAction(
                      icon: Icons.add_circle_outline,
                      label: 'Deposit',
                      color: AppColors.gold,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.deposit),
                    ),
                    _QuickAction(
                      icon: Icons.playlist_add,
                      label: 'New Plan',
                      color: AppColors.success,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.createPlan),
                    ),
                    _QuickAction(
                      icon: Icons.account_balance,
                      label: 'Loan',
                      color: AppColors.info,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.requestLoan),
                    ),
                    _QuickAction(
                      icon: Icons.payment,
                      label: 'Repay',
                      color: AppColors.warning,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.repayment),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Transactions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT TRANSACTIONS',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: GoogleFonts.inter(
                          color: AppColors.gold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...savings.transactions.take(5).map((txn) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: txn.isCredit
                              ? AppColors.success.withAlpha(20)
                              : AppColors.actionRed.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          txn.isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: txn.isCredit
                              ? AppColors.success
                              : AppColors.actionRed,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              txn.typeLabel,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(txn.date),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${txn.isCredit ? '+' : '-'} ${CurrencyFormatter.formatMK(txn.amount)}',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: txn.isCredit
                              ? AppColors.success
                              : AppColors.actionRed,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(30), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
