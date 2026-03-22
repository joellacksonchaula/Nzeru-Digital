import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/crypto_market_card.dart';
import '../../widgets/crypto_chart.dart';
import '../../widgets/glass_card.dart';
import '../../utils/currency_formatter.dart';
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.gold.withAlpha(30),
                        child: Text(
                          (user?.name ?? 'U')[0].toUpperCase(),
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            user?.name?.toLowerCase() ?? 'joel chaula',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Updated Hint Message (User Request)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.gold, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          dashboardProvider.marketStatus,
                          style: GoogleFonts.inter(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Crypto Markets Horizontal List
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: dashboardProvider.cryptoMarkets.length,
                    itemBuilder: (context, index) {
                      final m = dashboardProvider.cryptoMarkets[index];
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 12),
                        child: CryptoMarketCard(
                          name: m['name'],
                          symbol: m['symbol'],
                          price: m['price'],
                          marketCap: m['marketCap'],
                          volume24h: m['volume'],
                          changePercent24h: m['change'],
                          isGold: m['isGold'],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Market Chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const CryptoChart(
                    title: 'BITCOIN PERFORMANCE',
                    symbol: 'BTC/MK',
                    data: [12.0, 45.0, 32.0, 67.0, 89.0, 50.0, 95.0],
                    changePercent: 5.4,
                    isPositive: true,
                  ),
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      'QUICK ACTIONS',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickAction(
                        icon: Icons.file_download_outlined,
                        label: 'Deposit',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.deposit),
                      ),
                      _QuickAction(
                        icon: Icons.assignment_outlined,
                        label: 'New Plan',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.createPlan),
                      ),
                      _QuickAction(
                        icon: Icons.savings_outlined,
                        label: 'Loan',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.requestLoan),
                      ),
                      _QuickAction(
                        icon: Icons.history_outlined,
                        label: 'Repay',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.repayment),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      'RECENT TRANSACTIONS',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: (dashboardProvider.recentTransactions.length > 4) ? 4 : dashboardProvider.recentTransactions.length,
                    itemBuilder: (context, index) {
                      final txn = dashboardProvider.recentTransactions[index];
                      return GlassCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(12),
                        borderRadius: 12,
                        blurAmount: 8,
                        borderColor: AppColors.gold.withAlpha(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  txn.typeLabel,
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM').format(txn.date),
                                  style: GoogleFonts.inter(
                                    color: AppColors.textMuted,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.border, height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${txn.isCredit ? '+' : '-'}${CurrencyFormatter.formatMK(txn.amount)}',
                                    style: GoogleFonts.inter(
                                      color: txn.isCredit ? AppColors.success : AppColors.actionRed,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  txn.isCredit
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  color: txn.isCredit ? AppColors.success : AppColors.actionRed,
                                  size: 14,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withAlpha(60), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withAlpha(20),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.gold, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
