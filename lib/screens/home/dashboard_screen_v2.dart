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
import '../../widgets/candlestick_chart.dart';
import '../../utils/currency_formatter.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/savings_transaction.dart';

class DashboardScreenV2 extends StatefulWidget {
  const DashboardScreenV2({super.key});

  @override
  State<DashboardScreenV2> createState() => _DashboardScreenV2State();
}

class _DashboardScreenV2State extends State<DashboardScreenV2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final user = dashboardProvider.user;
    final dashboardData = dashboardProvider.data;

    if (dashboardProvider.isLoading && dashboardData == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          backgroundColor: AppColors.cardBg,
          onRefresh: () async {
            await context.read<DashboardProvider>().loadDashboard();
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
                                if (dashboardData?['unread_notifications'] != null && 
                                    dashboardData!['unread_notifications'] > 0)
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

                // Total Savings Card with Candlestick Preview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                const SizedBox(height: 8),
                                GlowText(
                                  text: CurrencyFormatter.formatMK(
                                    user?.savingsBalance ?? 0,
                                    decimalDigits: 2,
                                  ),
                                  fontSize: 32,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(20),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.success.withAlpha(30),
                                  width: 0.5,
                                ),
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
                        const SizedBox(height: 20),
                        // Mini candlestick chart
                        SizedBox(
                          height: 80,
                          child: _buildMiniChart(dashboardProvider.recentTransactions),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

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
                              dashboardData?['loan_balance'] ?? 0),
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
                          value: '${dashboardData?['active_plans'] ?? 0}',
                          iconColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          icon: Icons.warning_amber_rounded,
                          label: 'PENALTIES',
                          value: CurrencyFormatter.formatMK(
                              dashboardData?['total_penalties'] ?? 0),
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
                const SizedBox(height: 12),
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...dashboardProvider.recentTransactions.take(5).map((txn) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 0.5),
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
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                txn.typeLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                DateFormat('dd MMM yyyy, HH:mm')
                                    .format(txn.date),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${txn.isCredit ? '+' : '-'}${CurrencyFormatter.formatMK(txn.amount)}',
                          style: GoogleFonts.orbitron(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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

  /// Generate sample candlestick data from actual transactions
  Widget _buildMiniChart(List<SavingsTransaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No transaction data for chart',
          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10),
        ),
      );
    }
    
    // Group recent transactions by day
    final txns = transactions.toList().reversed.toList();
    final candles = <CandleData>[];

    for (int i = 0; i < txns.length; i++) {
      final amount = txns[i].amount.toDouble();
      candles.add(
        CandleData(
          time: txns[i].date,
          open: amount * 0.9,
          high: amount,
          low: amount * 0.7,
          close: amount,
          volume: amount,
        ),
      );
    }

    return CandlestickChart(
      candles: candles,
      title: 'DEPOSIT CHART (7D)',
      height: 80,
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
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
