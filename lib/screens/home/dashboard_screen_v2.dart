import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
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
    final plans = finance.prioritizedPlans.isEmpty ? _fallbackPlans : finance.prioritizedPlans;
    final transactions = finance.recentTransactions.isEmpty
        ? _fallbackTransactions
        : finance.recentTransactions.take(5).toList();
    final candles = _buildSavingsCandles(finance);
    final userName = _firstName(finance.user?.name);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () async {
            await Future.wait([
              context.read<DashboardProvider>().loadDashboard(),
              context.read<SavingsProvider>().loadData(),
            ]);
          },
          child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              _HeaderRow(
                name: userName,
                onNotifications: () => Navigator.pushNamed(context, AppRoutes.notifications),
              ),
              const SizedBox(height: 22),
              _SectionHeading(
                title: 'Savings Plans',
                trailing: '${plans.length} active',
              ),
              const SizedBox(height: 14),
              _SavingsCardsCarousel(
                plans: plans,
              ),
              const SizedBox(height: 22),
              CandlestickChart(
                candles: candles,
                title: 'Savings Performance',
                subtitle: _performanceLabel(candles),
                darkMode: true,
                height: 318,
                borderRadius: BorderRadius.circular(30),
              ),
              const SizedBox(height: 22),
              _SectionHeading(title: 'Quick Actions'),
              const SizedBox(height: 14),
              _ActionButtonsRow(),
              const SizedBox(height: 24),
              _SectionHeading(
                title: 'Recent Transactions',
                trailing: DateFormat('dd MMM').format(DateTime.now()),
              ),
              const SizedBox(height: 14),
              _TransactionsPanel(transactions: transactions),
              if (dashboard.isLoading) ...[
                const SizedBox(height: 20),
                const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String name;
  final VoidCallback onNotifications;

  const _HeaderRow({
    required this.name,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? 'U' : name[0].toUpperCase();

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFFFF7E4),
          child: Text(
            initial,
            style: GoogleFonts.oswald(
              fontSize: 24,
              color: const Color(0xFFB88A2E),
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
                  color: const Color(0xFF867A6B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: GoogleFonts.oswald(
                  fontSize: 28,
                  height: 0.95,
                  color: const Color(0xFF171412),
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onNotifications,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF171412),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionHeading({
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
            fontSize: 22,
            color: const Color(0xFF171412),
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB88A2E),
            ),
          ),
      ],
    );
  }
}

class _SavingsCardsCarousel extends StatelessWidget {
  final List<SavingsPlan> plans;

  const _SavingsCardsCarousel({
    required this.plans,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 480;
        final cardWidth = compact ? 214.0 : 286.0;

        return Column(
          children: [
            SizedBox(
              height: compact ? 214 : 230,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: plans.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: cardWidth,
                    child: _SavingsPlanCard(
                      plan: plans[index],
                      compact: compact,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB88A2E),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 6),
                for (var i = 0; i < (plans.length > 4 ? 3 : plans.length - 1); i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D2C7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SavingsPlanCard extends StatelessWidget {
  final SavingsPlan plan;
  final bool compact;

  const _SavingsPlanCard({
    required this.plan,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(plan.health);

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.oswald(
                    fontSize: compact ? 22 : 24,
                    color: const Color(0xFF171412),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Goal ${CurrencyUtil.formatNoDecimal(plan.goalAmount)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF7E7266),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetricLine(
                      label: 'Saved',
                      value: CurrencyUtil.formatNoDecimal(plan.currentAmount),
                    ),
                    const SizedBox(height: 4),
                    _MetricLine(
                      label: 'Remaining',
                      value: CurrencyUtil.formatNoDecimal(plan.remainingAmount),
                    ),
                    const SizedBox(height: 4),
                    _MetricLine(
                      label: 'Deadline',
                      value: DateFormat('dd MMM yyyy').format(plan.endDate),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(plan.health),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            children: [
              SizedBox(
                width: compact ? 64 : 74,
                height: compact ? 64 : 74,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: plan.progressPercent,
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFFF0ECE5),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                    Center(
                      child: Text(
                        '${(plan.progressPercent * 100).round()}%',
                        style: GoogleFonts.oswald(
                          fontSize: compact ? 16 : 18,
                          color: const Color(0xFF171412),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _requiredLabel(plan),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7E7266),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return const Color(0xFF3FA66B);
      case PlanHealth.watch:
        return const Color(0xFFB88A2E);
      case PlanHealth.behind:
        return const Color(0xFFD76354);
    }
  }

  String _statusLabel(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return 'On Track';
      case PlanHealth.watch:
        return 'Slight Delay';
      case PlanHealth.behind:
        return 'Behind';
    }
  }

  String _requiredLabel(SavingsPlan plan) {
    switch (plan.frequency) {
      case PlanFrequency.daily:
        return 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerDay)} / day';
      case PlanFrequency.weekly:
      case PlanFrequency.biweekly:
        return 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerWeek)} / week';
      case PlanFrequency.monthly:
        return 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerMonth)} / month';
    }
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final String value;

  const _MetricLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF8B7E6E),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.oswald(
              fontSize: 15,
              color: const Color(0xFF171412),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'Deposit', icon: Icons.download_rounded, route: AppRoutes.deposit),
      (label: 'New Plan', icon: Icons.note_alt_rounded, route: AppRoutes.createPlan),
      (label: 'Loan', icon: Icons.account_balance_wallet_rounded, route: AppRoutes.requestLoan),
      (label: 'Repay', icon: Icons.currency_exchange_rounded, route: AppRoutes.repayment),
    ];

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, item.route),
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              width: 94,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFF3CF),
                    Color(0xFFE7C768),
                    Color(0xFFC49426),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24C49426),
                    blurRadius: 22,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      item.icon,
                      color: const Color(0xFF5F4513),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4A3710),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final txn in transactions) _TransactionRow(txn: txn),
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
    final color = txn.isCredit ? const Color(0xFF3FA66B) : const Color(0xFFD76354);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
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
                    color: const Color(0xFF171412),
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(txn.date),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF7E7266),
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

List<CandleData> _buildSavingsCandles(FinanceOverviewProvider finance) {
  final transactions = [...finance.transactions]..sort((a, b) => a.date.compareTo(b.date));

  if (transactions.isNotEmpty) {
    var running = 0.0;
    return transactions.take(42).map((txn) {
      final open = running;
      running += txn.isCredit ? txn.amount : -txn.amount;
      final close = running < 0 ? 0.0 : running;
      final high = _maxDouble(open, close) + (txn.amount * 0.025);
      final low =
          (_minDouble(open, close) - (txn.amount * 0.02)).clamp(0.0, double.infinity).toDouble();
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
              final base = plan.goalAmount == 0 ? 0.0 : plan.goalAmount * (0.10 + (index * 0.03));
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

String _performanceLabel(List<CandleData> candles) {
  if (candles.length < 2) return 'Live update feed';
  final first = candles.first.close <= 0 ? 1 : candles.first.close;
  final last = candles.last.close;
  final change = ((last - first) / first) * 100;
  final prefix = change >= 0 ? '+' : '';
  return '$prefix${change.toStringAsFixed(1)}% over your tracked period';
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
    type: TransactionType.deposit,
  ),
  SavingsTransaction(
    id: '2',
    userId: 'demo',
    amount: 2000,
    date: DateTime(2026, 3, 15, 9, 20),
    type: TransactionType.deposit,
  ),
  SavingsTransaction(
    id: '3',
    userId: 'demo',
    amount: 1200,
    date: DateTime(2026, 3, 14, 7, 10),
    type: TransactionType.deposit,
  ),
  SavingsTransaction(
    id: '4',
    userId: 'demo',
    amount: 2800,
    date: DateTime(2026, 3, 12, 17, 55),
    type: TransactionType.deposit,
  ),
];

final _fallbackCandles = List.generate(
  36,
  (index) {
    final open = 12000.0 + (index * 220);
    final close = open + (index.isEven ? 60 : -40);
    return CandleData(
      time: DateTime(2026, 3, 1).add(Duration(days: index)),
      open: open,
      high: _maxDouble(open, close) + 110,
      low: _minDouble(open, close) - 80,
      close: close,
      volume: 1000,
    );
  },
);
