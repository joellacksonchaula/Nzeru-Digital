import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/savings_transaction.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/finance_overview_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/candlestick_chart.dart';
import '../../widgets/dashboard_kit.dart';

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
      context.read<SavingsProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceOverviewProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final candles = _buildSavingsCandles(finance);
    final performance = _performanceLabel(candles);

    return DashboardPage(
      eyebrow: 'Home Dashboard',
      title: 'Welcome back, ${_firstName(finance.user?.name)}',
      subtitle:
          'Track your savings momentum, stay ahead of loan obligations, and move from plan to action without leaving the dashboard.',
      trailing: IconButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ),
      children: [
        DashboardStatGrid(
          items: [
            DashboardStatItem(
              label: 'Saved',
              value: CurrencyUtil.formatCompact(finance.totalSaved),
              detail: '${finance.prioritizedPlans.length} active plans in progress.',
              icon: Icons.savings_rounded,
              accent: const Color(0xFF876446),
            ),
            DashboardStatItem(
              label: 'Monthly pace',
              value: CurrencyUtil.formatCompact(finance.monthlyCommitment),
              detail: 'Required monthly contribution across your plans.',
              icon: Icons.calendar_month_rounded,
              accent: const Color(0xFF4C6A78),
            ),
            DashboardStatItem(
              label: 'On track',
              value: '${finance.onTrackPlans}',
              detail: '${finance.watchPlans} watch, ${finance.behindPlans} behind.',
              icon: Icons.track_changes_rounded,
              accent: const Color(0xFF4B9957),
            ),
            DashboardStatItem(
              label: 'Loan exposure',
              value: CurrencyUtil.formatCompact(finance.outstandingLoan),
              detail: 'Outstanding balance affecting your overall summary.',
              icon: Icons.account_balance_wallet_rounded,
              accent: const Color(0xFFC2545E),
            ),
          ],
        ),
        const SizedBox(height: 18),
        DashboardSectionTitle(
          title: 'Savings Plans',
          actionLabel: 'Create Plan',
          onAction: () => Navigator.pushNamed(context, AppRoutes.createPlan),
        ),
        const SizedBox(height: 10),
        DashboardPlanCarousel(
          plans: finance.prioritizedPlans.isEmpty ? _fallbackPlans : finance.prioritizedPlans,
          onTap: (_) => Navigator.pushNamed(context, AppRoutes.savingsPlans),
        ),
        const SizedBox(height: 18),
        CandlestickChart(
          title: 'Savings Performance',
          subtitle: performance,
          candles: candles,
          height: 340,
        ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Quick Actions'),
        const SizedBox(height: 10),
        DashboardPanel(
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _ActionTile(
                icon: Icons.download_rounded,
                label: 'Deposit',
                onTap: () => Navigator.pushNamed(context, AppRoutes.deposit),
              ),
              _ActionTile(
                icon: Icons.note_alt_rounded,
                label: 'New Plan',
                onTap: () => Navigator.pushNamed(context, AppRoutes.createPlan),
              ),
              _ActionTile(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Loan',
                onTap: () => Navigator.pushNamed(context, AppRoutes.requestLoan),
              ),
              _ActionTile(
                icon: Icons.currency_exchange_rounded,
                label: 'Repay',
                onTap: () => Navigator.pushNamed(context, AppRoutes.repayment),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Recent Transactions'),
        const SizedBox(height: 10),
        DashboardPanel(
          child: Column(
            children: [
              for (final txn in (finance.recentTransactions.isEmpty
                  ? _fallbackTransactions
                  : finance.recentTransactions.take(4)))
                _TransactionRow(txn: txn),
            ],
          ),
        ),
        if (dashboard.isLoading) ...[
          const SizedBox(height: 16),
          const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.44),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFFF7D9),
                    Color(0xFFF2D98D),
                    Color(0xFFB68A25),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: const Color(0xFF5C482C)),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.oswald(
                fontSize: 16,
                color: const Color(0xFF2E261E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final SavingsTransaction txn;

  const _TransactionRow({
    required this.txn,
  });

  @override
  Widget build(BuildContext context) {
    final color = txn.isCredit ? const Color(0xFF4B9957) : const Color(0xFFC2545E);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              txn.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.typeLabel,
                  style: GoogleFonts.oswald(
                    fontSize: 18,
                    color: const Color(0xFF23211E),
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(txn.date),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF5F5A54),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${txn.isCredit ? '+' : '-'}${CurrencyUtil.formatNoDecimal(txn.amount)}',
            style: GoogleFonts.oswald(
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

String _firstName(String? name) {
  final trimmed = (name ?? '').trim();
  if (trimmed.isEmpty) return 'there';
  return trimmed.split(' ').first;
}

List<CandleData> _buildSavingsCandles(FinanceOverviewProvider finance) {
  final transactions = [...finance.transactions]
    ..sort((a, b) => a.date.compareTo(b.date));

  if (transactions.isNotEmpty) {
    var running = 0.0;
    return transactions.take(24).map((txn) {
      final open = running;
      running += txn.isCredit ? txn.amount : -txn.amount;
      final close = running < 0 ? 0 : running;
      final high = open > close ? open : close;
      final low = open < close ? open : close;
      return CandleData(
        time: txn.date,
        open: open,
        high: high + (txn.amount * 0.04),
        low: (low - (txn.amount * 0.04)).clamp(0, double.infinity),
        close: close,
        volume: txn.amount,
      );
    }).toList();
  }

  if (finance.prioritizedPlans.isNotEmpty) {
    return finance.prioritizedPlans.asMap().entries.map((entry) {
      final plan = entry.value;
      final baseline = plan.goalAmount == 0 ? 0.0 : plan.goalAmount * 0.2;
      return CandleData(
        time: plan.createdAt ?? plan.startDate.add(Duration(days: entry.key * 7)),
        open: baseline,
        high: plan.currentAmount + (plan.requiredPerWeek * 0.4),
        low: baseline * 0.9,
        close: plan.currentAmount,
        volume: plan.currentAmount,
      );
    }).toList();
  }

  return _fallbackCandles;
}

String _performanceLabel(List<CandleData> candles) {
  if (candles.length < 2) return 'Live savings data will appear here';
  final first = candles.first.close <= 0 ? 1 : candles.first.close;
  final last = candles.last.close;
  final change = ((last - first) / first) * 100;
  final prefix = change >= 0 ? '+' : '';
  return '$prefix${change.toStringAsFixed(1)}% vs starting savings balance';
}

final _fallbackPlans = [
  SavingsPlan(
    id: 'plan-1',
    userId: 'demo',
    title: 'Phone Cash',
    amountPerPeriod: 5000,
    frequency: PlanFrequency.monthly,
    durationMonths: 6,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 6, 30),
    penaltyPolicy: PenaltyPolicy.monetaryDeduction,
    goalAmount: 85000,
    currentAmount: 45000,
    createdAt: DateTime(2026, 1, 1),
  ),
  SavingsPlan(
    id: 'plan-2',
    userId: 'demo',
    title: 'Car Cash',
    amountPerPeriod: 50000,
    frequency: PlanFrequency.monthly,
    durationMonths: 24,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2028, 1, 1),
    penaltyPolicy: PenaltyPolicy.monetaryDeduction,
    goalAmount: 15000000,
    currentAmount: 1200000,
    createdAt: DateTime(2026, 1, 2),
  ),
  SavingsPlan(
    id: 'plan-3',
    userId: 'demo',
    title: 'Vacation Fund',
    amountPerPeriod: 10000,
    frequency: PlanFrequency.monthly,
    durationMonths: 12,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 12, 1),
    penaltyPolicy: PenaltyPolicy.monetaryDeduction,
    goalAmount: 500000,
    currentAmount: 250000,
    createdAt: DateTime(2026, 1, 3),
  ),
];

final _fallbackTransactions = [
  SavingsTransaction(
    id: '1',
    userId: 'demo',
    amount: 3330000,
    date: DateTime(2026, 3, 16, 21, 40),
    type: TransactionType.withdrawal,
  ),
  SavingsTransaction(
    id: '2',
    userId: 'demo',
    amount: 2000,
    date: DateTime(2026, 3, 16, 21, 40),
    type: TransactionType.deposit,
  ),
  SavingsTransaction(
    id: '3',
    userId: 'demo',
    amount: 2000,
    date: DateTime(2026, 3, 16, 21, 40),
    type: TransactionType.deposit,
  ),
  SavingsTransaction(
    id: '4',
    userId: 'demo',
    amount: 3300,
    date: DateTime(2026, 3, 16, 21, 40),
    type: TransactionType.deposit,
  ),
];

final _fallbackCandles = [
  CandleData(
    time: DateTime(2026, 3, 10),
    open: 12000,
    high: 13200,
    low: 11800,
    close: 12800,
    volume: 1200,
  ),
  CandleData(
    time: DateTime(2026, 3, 12),
    open: 12800,
    high: 14100,
    low: 12600,
    close: 13800,
    volume: 1500,
  ),
  CandleData(
    time: DateTime(2026, 3, 14),
    open: 13800,
    high: 14900,
    low: 13600,
    close: 14500,
    volume: 1600,
  ),
  CandleData(
    time: DateTime(2026, 3, 16),
    open: 14500,
    high: 15800,
    low: 14200,
    close: 15400,
    volume: 2000,
  ),
];
