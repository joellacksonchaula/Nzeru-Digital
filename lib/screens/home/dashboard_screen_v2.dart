import 'dart:ui';

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
    final plans = finance.prioritizedPlans.isEmpty ? _fallbackPlans : finance.prioritizedPlans;
    final transactions = finance.recentTransactions.isEmpty
        ? _fallbackTransactions
        : finance.recentTransactions.take(4).toList();
    final candles = _buildSavingsCandles(finance);

    return DashboardPage(
      eyebrow: 'Fintech Command',
      title: 'Savings layers built for motion',
      subtitle:
          'Your graph stays live underneath the dashboard while plans, actions, and funding cues float above it in one continuous finance surface.',
      trailing: IconButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
        icon: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3D7C4)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF171412),
          ),
        ),
      ),
      children: [
        _LayeredHero(
          finance: finance,
          plans: plans,
          candles: candles,
        ),
        const SizedBox(height: 28),
        DashboardSectionTitle(title: 'Portfolio Snapshot'),
        const SizedBox(height: 12),
        DashboardStatGrid(
          items: [
            DashboardStatItem(
              label: 'Saved',
              value: CurrencyUtil.formatCompact(finance.totalSaved),
              detail: '${plans.length} active plans moving in parallel.',
              icon: Icons.savings_rounded,
              accent: const Color(0xFFBF912C),
            ),
            DashboardStatItem(
              label: 'Monthly pace',
              value: CurrencyUtil.formatCompact(finance.monthlyCommitment),
              detail: 'Required contribution rate across all goals.',
              icon: Icons.calendar_month_rounded,
              accent: const Color(0xFF537A8A),
            ),
            DashboardStatItem(
              label: 'On track',
              value: '${finance.onTrackPlans}',
              detail: '${finance.watchPlans} watch, ${finance.behindPlans} behind.',
              icon: Icons.track_changes_rounded,
              accent: const Color(0xFF3B9D5D),
            ),
            DashboardStatItem(
              label: 'Loan exposure',
              value: CurrencyUtil.formatCompact(finance.outstandingLoan),
              detail: 'Outstanding balance still affecting net flexibility.',
              icon: Icons.account_balance_wallet_rounded,
              accent: const Color(0xFFD55C4B),
            ),
          ],
        ),
        const SizedBox(height: 28),
        DashboardSectionTitle(
          title: 'Recent Transactions',
          actionLabel: 'See All',
          onAction: () => Navigator.pushNamed(context, AppRoutes.savingsPlans),
        ),
        const SizedBox(height: 12),
        DashboardPanel(
          child: Column(
            children: [
              for (final txn in transactions) _TransactionRow(txn: txn),
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

class _LayeredHero extends StatelessWidget {
  final FinanceOverviewProvider finance;
  final List<SavingsPlan> plans;
  final List<CandleData> candles;

  const _LayeredHero({
    required this.finance,
    required this.plans,
    required this.candles,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final heroHeight = compact ? 425.0 : 470.0;
        final overlayHeight = compact ? 172.0 : 208.0;

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 18 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: SizedBox(
            height: heroHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: _GraphHeroSurface(
                    finance: finance,
                    candles: candles,
                    compact: compact,
                  ),
                ),
                Positioned(
                  left: compact ? 14 : 18,
                  right: compact ? 14 : 18,
                  bottom: compact ? 18 : 22,
                  child: _ActionRail(compact: compact),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: compact ? -18 : -26,
                  child: SizedBox(
                    height: overlayHeight,
                    child: _FloatingSavingsRow(
                      plans: plans,
                      compact: compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GraphHeroSurface extends StatelessWidget {
  final FinanceOverviewProvider finance;
  final List<CandleData> candles;
  final bool compact;

  const _GraphHeroSurface({
    required this.finance,
    required this.candles,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final pace = CurrencyUtil.formatNoDecimal(finance.monthlyCommitment);
    final saved = CurrencyUtil.formatCompact(finance.totalSaved);

    return Stack(
      children: [
        CandlestickChart(
          candles: candles,
          showHeader: false,
          height: compact ? 390 : 430,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 78),
          borderRadius: BorderRadius.circular(34),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.02),
                  const Color(0xFFF8F4EA).withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          top: compact ? 18 : 22,
          left: compact ? 18 : 22,
          right: compact ? 18 : 22,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            spacing: 12,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFE5DAC8)),
                      ),
                      child: Text(
                        'Live savings surface',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8F6C2C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'MK $saved flowing across your goals',
                      style: GoogleFonts.oswald(
                        fontSize: compact ? 28 : 34,
                        height: 0.94,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF171412),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_performanceLabel(candles)} with a required pace of MK $pace per month.',
                      style: GoogleFonts.inter(
                        fontSize: compact ? 12 : 13,
                        height: 1.45,
                        color: const Color(0xFF685F55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _HeroSignalCard(
                title: 'Top Layer',
                value: '${finance.onTrackPlans}',
                subtitle: 'Plans on track',
                accent: const Color(0xFF3B9D5D),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroSignalCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accent;

  const _HeroSignalCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 164,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.oswald(
                  fontSize: 12,
                  letterSpacing: 1.8,
                  color: const Color(0xFF8B7E6B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.oswald(
                  fontSize: 34,
                  height: 0.9,
                  color: const Color(0xFF171412),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingSavingsRow extends StatelessWidget {
  final List<SavingsPlan> plans;
  final bool compact;

  const _FloatingSavingsRow({
    required this.plans,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 500 + (index * 100)),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 24 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _FloatingPlanCard(
            plan: plans[index],
            compact: compact,
          ),
        );
      },
    );
  }
}

class _FloatingPlanCard extends StatelessWidget {
  final SavingsPlan plan;
  final bool compact;

  const _FloatingPlanCard({
    required this.plan,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _statusColor(plan.health);
    final width = compact ? 198.0 : 246.0;
    final percent = (plan.progressPercent * 100).round();
    final textScale = compact ? 0.92 : 1.0;

    return Container(
      width: width,
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          const BoxShadow(
            color: Color(0x16000000),
            blurRadius: 34,
            offset: Offset(0, 20),
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
                child: Text(
                  plan.title,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.oswald(
                    fontSize: (compact ? 18 : 21) * textScale,
                    height: 0.98,
                    color: const Color(0xFF171412),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: compact ? 44 : 50,
                height: compact ? 44 : 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.74),
                  border: Border.all(color: accent.withValues(alpha: 0.24)),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: CircularProgressIndicator(
                        value: plan.progressPercent,
                        strokeWidth: 4,
                        backgroundColor: const Color(0xFFF0EAE0),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$percent%',
                        style: GoogleFonts.oswald(
                          fontSize: compact ? 12 : 13,
                          color: const Color(0xFF171412),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${CurrencyUtil.formatNoDecimal(plan.currentAmount)} / ${CurrencyUtil.formatNoDecimal(plan.goalAmount)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF685F55),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _requiredSavingLabel(plan),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: compact ? 11 : 12,
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _statusLabel(plan.health),
              style: GoogleFonts.inter(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return const Color(0xFF3B9D5D);
      case PlanHealth.watch:
        return const Color(0xFFBF912C);
      case PlanHealth.behind:
        return const Color(0xFFD55C4B);
    }
  }

  String _statusLabel(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return 'On track';
      case PlanHealth.watch:
        return 'Slight delay';
      case PlanHealth.behind:
        return 'Behind';
    }
  }

  String _requiredSavingLabel(SavingsPlan plan) {
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

class _ActionRail extends StatelessWidget {
  final bool compact;

  const _ActionRail({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        label: 'Deposit',
        icon: Icons.download_rounded,
        route: AppRoutes.deposit,
        accent: const Color(0xFF3B9D5D),
      ),
      (
        label: 'New Plan',
        icon: Icons.note_alt_rounded,
        route: AppRoutes.createPlan,
        accent: const Color(0xFFBF912C),
      ),
      (
        label: 'Loan',
        icon: Icons.account_balance_wallet_rounded,
        route: AppRoutes.requestLoan,
        accent: const Color(0xFF537A8A),
      ),
      (
        label: 'Repay',
        icon: Icons.currency_exchange_rounded,
        route: AppRoutes.repayment,
        accent: const Color(0xFFD55C4B),
      ),
    ];

    return SizedBox(
      height: compact ? 66 : 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, item.route),
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 14 : 18,
                vertical: compact ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: item.accent.withValues(alpha: 0.20)),
                boxShadow: [
                  BoxShadow(
                    color: item.accent.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: compact ? 34 : 38,
                    height: compact ? 34 : 38,
                    decoration: BoxDecoration(
                      color: item.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(item.icon, color: item.accent, size: compact ? 18 : 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF171412),
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

class _TransactionRow extends StatelessWidget {
  final SavingsTransaction txn;

  const _TransactionRow({
    required this.txn,
  });

  @override
  Widget build(BuildContext context) {
    final color = txn.isCredit ? const Color(0xFF3B9D5D) : const Color(0xFFD55C4B);
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
                    color: const Color(0xFF6F665C),
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
    return transactions.take(36).map((txn) {
      final open = running;
      running += txn.isCredit ? txn.amount : -txn.amount;
      final close = running < 0 ? 0.0 : running;
      final high = mathMax(open, close) + (txn.amount * 0.025);
      final low = (mathMin(open, close) - (txn.amount * 0.02)).clamp(0, double.infinity);
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
        .expand((plan) => List.generate(8, (index) {
              final seed = plan.goalAmount == 0 ? 0.0 : plan.goalAmount * (0.12 + (index * 0.04));
              final close = (seed + (plan.currentAmount * (index / 8))).clamp(0, plan.goalAmount);
              return CandleData(
                time: plan.startDate.add(Duration(days: index * 4)),
                open: index == 0 ? seed * 0.92 : (seed * 0.98),
                high: close + (plan.requiredPerWeek * 0.18),
                low: (seed * 0.88).clamp(0, double.infinity),
                close: close,
                volume: plan.currentAmount,
              );
            }))
        .take(36)
        .toList();
  }

  return _fallbackCandles;
}

String _performanceLabel(List<CandleData> candles) {
  if (candles.length < 2) return 'Live savings data will appear here';
  final first = candles.first.close <= 0 ? 1 : candles.first.close;
  final last = candles.last.close;
  final change = ((last - first) / first) * 100;
  final prefix = change >= 0 ? '+' : '';
  return '$prefix${change.toStringAsFixed(1)}% vs starting balance';
}

double mathMax(double a, double b) => a > b ? a : b;
double mathMin(double a, double b) => a < b ? a : b;

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

final _fallbackCandles = List.generate(
  30,
  (index) {
    final open = 12000.0 + (index * 280);
    final close = open + (index.isEven ? 120 : -40);
    return CandleData(
      time: DateTime(2026, 3, 1).add(Duration(days: index)),
      open: open,
      high: mathMax(open, close) + 160,
      low: mathMin(open, close) - 120,
      close: close,
      volume: 1000,
    );
  },
);
