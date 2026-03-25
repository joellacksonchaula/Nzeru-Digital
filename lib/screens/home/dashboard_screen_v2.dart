import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../models/savings_plan.dart';
import '../../models/savings_transaction.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/finance_overview_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/candlestick_chart.dart';

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
    final plans = finance.prioritizedPlans.isEmpty
        ? _fallbackPlans
        : finance.prioritizedPlans.take(5).toList();
    final transactions = finance.recentTransactions.isEmpty
        ? _fallbackTransactions
        : finance.recentTransactions.take(5).toList();
    final candles = _buildSavingsCandles(finance);
    final userName = _firstName(finance.user?.name);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFC89B38),
          onRefresh: () async {
            await Future.wait([
              context.read<DashboardProvider>().loadDashboard(),
              context.read<SavingsProvider>().loadData(),
            ]);
          },
          child: ListView(
            physics:
                const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              _PhoneHeader(
                name: userName,
                onNotifications: () =>
                    Navigator.pushNamed(context, AppRoutes.notifications),
              ),
              const SizedBox(height: 26),
              _SectionRow(
                title: 'Savings Plans',
                trailing: plans.isEmpty ? null : '${plans.length} active',
              ),
              const SizedBox(height: 14),
              plans.isEmpty
                  ? const SizedBox(
                      height: 170,
                      child: _EmptyCard(message: 'No savings plans yet.'),
                    )
                  : _TopPlansRail(plans: plans.take(3).toList()),
              const SizedBox(height: 18),
              _PerformanceCard(candles: candles),
              const SizedBox(height: 18),
              const _SectionRow(title: 'Quick Actions'),
              const SizedBox(height: 14),
              const _QuickActionsRow(),
              const SizedBox(height: 18),
              _SectionRow(
                title: 'Recent Transactions',
                trailing: DateFormat('dd MMM').format(DateTime.now()),
              ),
              const SizedBox(height: 14),
              _TransactionsPanel(transactions: transactions.take(3).toList()),
              if (dashboard.isLoading) ...[
                const SizedBox(height: 20),
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFC89B38)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneHeader extends StatelessWidget {
  final String name;
  final VoidCallback onNotifications;

  const _PhoneHeader({
    required this.name,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? 'U' : name[0].toUpperCase();

    return Row(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF5D7),
                Color(0xFFF5E6AA),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1AC89B38),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.oswald(
                fontSize: 28,
                color: const Color(0xFFB88616),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF4E4A44),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: GoogleFonts.oswald(
                  fontSize: 30,
                  height: 0.95,
                  color: const Color(0xFF111111),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onNotifications,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 31,
                    color: Color(0xFF171412),
                  ),
                ),
                Positioned(
                  top: 13,
                  right: 15,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE86161),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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

class _SectionRow extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionRow({
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.oswald(
            fontSize: 24,
            color: const Color(0xFF111111),
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9B7B23),
            ),
          ),
      ],
    );
  }
}

class _TopSavingsPlanCard extends StatelessWidget {
  final SavingsPlan plan;

  const _TopSavingsPlanCard({
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(plan.health);
    final percent = (plan.progressPercent * 100).round();
    final rateLabel = _topRateLabel(plan);
    final progressLabel = '+$percent%';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E0D3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _displayTopTitle(plan.title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.oswald(
                      fontSize: 14,
                      height: 0.95,
                      color: const Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: plan.progressPercent,
                        strokeWidth: 4,
                        backgroundColor: const Color(0xFFEAE3D9),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                      Center(
                        child: Text(
                          '$percent%',
                          style: GoogleFonts.oswald(
                            fontSize: 9,
                            color: const Color(0xFF1F1F1F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              plan.progressPercent >= 1 ? 'Goal' : 'Target',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF4A4A4A),
              ),
            ),
            Text(
              CurrencyUtil.formatNoDecimal(plan.goalAmount),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              rateLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF2E2E2E),
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ETA',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: plan.progressPercent,
                minHeight: 10,
                backgroundColor: const Color(0xFFEEF0EA),
                color: statusColor.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F1E9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    plan.isEstimatedToFinishOnTime ? 'On Fi' : 'Off',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF427A54),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  progressLabel,
                  style: GoogleFonts.oswald(
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              DateFormat('d MMM yyyy').format(plan.endDate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF3A3A3A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _displayTopTitle(String title) {
    if (title.trim().isEmpty) return 'Savings';
    final words = title.trim().split(RegExp(r'\s+'));
    return words.length > 1 ? words.first : title;
  }

  static String _topRateLabel(SavingsPlan plan) {
    if (plan.progressPercent >= 1) return 'Saved in full';
    switch (plan.frequency) {
      case PlanFrequency.daily:
        return 'Remaining ${CurrencyUtil.formatNoDecimal(plan.requiredPerDay)}/day';
      case PlanFrequency.weekly:
      case PlanFrequency.biweekly:
        return 'Remaining ${CurrencyUtil.formatNoDecimal(plan.requiredPerWeek)}/week';
      case PlanFrequency.monthly:
        return 'Saved ${CurrencyUtil.formatNoDecimal(plan.currentAmount)}';
    }
  }

  static Color _statusColor(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return const Color(0xFF4B9C73);
      case PlanHealth.watch:
        return const Color(0xFFBE9D54);
      case PlanHealth.behind:
        return const Color(0xFFD16C5E);
    }
  }
}

class _TopPlansRail extends StatelessWidget {
  final List<SavingsPlan> plans;

  const _TopPlansRail({
    required this.plans,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 156,
            child: _TopSavingsPlanCard(plan: plans[index]),
          );
        },
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final List<CandleData> candles;

  const _PerformanceCard({
    required this.candles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111721),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crypto Performance',
                      style: GoogleFonts.oswald(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'BTC Price Performance',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF8B95A5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF202736),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF343C4F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ETH/MK',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF8B95A5),
                      ),
                    ),
                    Text(
                      CurrencyUtil.formatCompact(
                        candles.isEmpty ? 0 : candles.last.close,
                      ),
                      style: GoogleFonts.oswald(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CandlestickChart(
            candles: candles,
            title: '',
            subtitle: '',
            darkMode: true,
            height: 130,
            borderRadius: BorderRadius.circular(18),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'Deposit', icon: Icons.download_rounded, route: AppRoutes.deposit),
      (label: 'New Plan', icon: Icons.note_alt_rounded, route: AppRoutes.createPlan),
      (label: 'Loan', icon: Icons.account_balance_wallet_rounded, route: AppRoutes.requestLoan),
      (label: 'Repay', icon: Icons.refresh_rounded, route: AppRoutes.repayment),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, items[i].route),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF7E8A2),
                      Color(0xFFE6BF50),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC89B38).withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        items[i].icon,
                        size: 18,
                        color: const Color(0xFF6B520F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      items[i].label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A3810),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _TransactionsPanel extends StatelessWidget {
  final List<SavingsTransaction> transactions;

  const _TransactionsPanel({
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            _TransactionRow(txn: transactions[i]),
            if (i != transactions.length - 1)
              Divider(
                height: 1,
                indent: 18,
                endIndent: 18,
                color: const Color(0xFFEFE9DE),
              ),
          ],
        ],
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
    final color =
        txn.isCredit ? const Color(0xFF427A54) : const Color(0xFFD16C5E);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5EF),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(
              txn.isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.typeLabel,
                  style: GoogleFonts.oswald(
                    fontSize: 17,
                    color: const Color(0xFF171412),
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(txn.date),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF55504A),
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

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7DED1)),
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF55504A),
          ),
        ),
      ),
    );
  }
}

List<CandleData> _buildSavingsCandles(FinanceOverviewProvider finance) {
  final transactions = [...finance.transactions]
    ..sort((a, b) => a.date.compareTo(b.date));

  if (transactions.isNotEmpty) {
    var running = 0.0;
    return transactions.take(42).map((txn) {
      final open = running;
      running += txn.isCredit ? txn.amount : -txn.amount;
      final close = running < 0 ? 0.0 : running;
      final high = _maxDouble(open, close) + (txn.amount * 0.025);
      final low = (_minDouble(open, close) - (txn.amount * 0.02))
          .clamp(0.0, double.infinity)
          .toDouble();
      return CandleData(
        time: txn.date,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: txn.amount,
      );
    }).toList();
  }

  if (finance.prioritizedPlans.isNotEmpty) {
    return finance.prioritizedPlans
        .expand((plan) => List.generate(10, (index) {
              final base =
                  plan.goalAmount == 0 ? 0.0 : plan.goalAmount * (0.10 + (index * 0.03));
              final close = (base + (plan.currentAmount * (index / 10)))
                  .clamp(0.0, plan.goalAmount)
                  .toDouble();
              return CandleData(
                time: plan.startDate.add(Duration(days: index * 3)),
                open: index == 0 ? base * 0.94 : base,
                high: close + (plan.requiredPerWeek * 0.16),
                low: (base * 0.90).clamp(0.0, double.infinity).toDouble(),
                close: close,
                volume: plan.currentAmount,
              );
            }))
        .take(42)
        .toList();
  }

  return _fallbackCandles;
}

String _firstName(String? name) {
  final trimmed = (name ?? '').trim();
  if (trimmed.isEmpty) return 'User';
  return trimmed.split(' ').first;
}

double _maxDouble(double a, double b) => a > b ? a : b;
double _minDouble(double a, double b) => a < b ? a : b;

final List<SavingsPlan> _fallbackPlans = [
  SavingsPlan(
    id: 'plan-1',
    userId: 'demo',
    title: 'Go',
    amountPerPeriod: 5000,
    frequency: PlanFrequency.weekly,
    durationMonths: 6,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 9, 12),
    penaltyPolicy: PenaltyPolicy.monetaryDeduction,
    goalAmount: 1200000000,
    currentAmount: 28332000,
    createdAt: DateTime(2026, 1, 1),
  ),
  SavingsPlan(
    id: 'plan-2',
    userId: 'demo',
    title: 'Vacation',
    amountPerPeriod: 50000,
    frequency: PlanFrequency.weekly,
    durationMonths: 24,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 4, 16),
    penaltyPolicy: PenaltyPolicy.monetaryDeduction,
    goalAmount: 48000,
    currentAmount: 48000,
    createdAt: DateTime(2026, 1, 2),
  ),
  SavingsPlan(
    id: 'plan-3',
    userId: 'demo',
    title: 'Emergency',
    amountPerPeriod: 10000,
    frequency: PlanFrequency.weekly,
    durationMonths: 12,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2027, 1, 1),
    penaltyPolicy: PenaltyPolicy.monetaryDeduction,
    goalAmount: 48000,
    currentAmount: 2400,
    createdAt: DateTime(2026, 1, 3),
  ),
];

final _fallbackTransactions = [
  SavingsTransaction(
    id: '1',
    userId: 'demo',
    amount: 20000,
    date: DateTime(2026, 3, 24, 20, 55),
    type: TransactionType.deposit,
  ),
  SavingsTransaction(
    id: '2',
    userId: 'demo',
    amount: 2000,
    date: DateTime(2026, 3, 22, 17, 36),
    type: TransactionType.deposit,
  ),
  SavingsTransaction(
    id: '3',
    userId: 'demo',
    amount: 1200,
    date: DateTime(2026, 3, 20, 14, 10),
    type: TransactionType.deposit,
  ),
];

final _fallbackCandles = List.generate(
  12,
  (index) {
    final open = 14000000.0 + (index * 120000);
    final close = open + (index.isEven ? 30000 : -18000);
    return CandleData(
      time: DateTime(2026, 3, 13).add(Duration(days: index)),
      open: open,
      high: _maxDouble(open, close) + 60000,
      low: _minDouble(open, close) - 45000,
      close: close,
      volume: 1000,
    );
  },
);
