import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/savings_plan.dart';
import '../../models/savings_transaction.dart';
import '../../providers/finance_overview_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceOverviewProvider>();

    return DashboardPage(
      eyebrow: 'Reports',
      title: 'Financial Reports',
      subtitle:
          'Two live charts now use your actual savings data, and the report cards mix horizontal and vertical layouts.',
      children: [
        DashboardHorizontalRail(
          children: [
            SizedBox(
              width: 220,
              child: _ReportCard(
                label: 'Deposits',
                value: CurrencyUtil.formatCompact(finance.totalDeposits),
                detail: 'Money added',
                accent: const Color(0xFF4B9957),
                icon: Icons.south_west_rounded,
              ),
            ),
            SizedBox(
              width: 220,
              child: _ReportCard(
                label: 'Withdrawals',
                value: CurrencyUtil.formatCompact(finance.totalWithdrawals),
                detail: 'Money moved out',
                accent: const Color(0xFFC2545E),
                icon: Icons.north_east_rounded,
              ),
            ),
            SizedBox(
              width: 220,
              child: _ReportCard(
                label: 'Penalties',
                value: CurrencyUtil.formatCompact(finance.totalPenalties),
                detail: 'Charges applied',
                accent: const Color(0xFFB7821E),
                icon: Icons.warning_amber_rounded,
              ),
            ),
            SizedBox(
              width: 220,
              child: _ReportCard(
                label: 'Interest',
                value: CurrencyUtil.formatCompact(finance.interestEarned),
                detail: 'Rewards earned',
                accent: const Color(0xFF4C6A78),
                icon: Icons.trending_up_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _DepositTrendChart(finance: finance),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 860) {
              return Column(
                children: [
                  _PlanProgressChart(finance: finance),
                  const SizedBox(height: 14),
                  _ReportColumn(finance: finance),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _PlanProgressChart(finance: finance),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 4,
                  child: _ReportColumn(finance: finance),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DepositTrendChart extends StatelessWidget {
  final FinanceOverviewProvider finance;

  const _DepositTrendChart({
    required this.finance,
  });

  @override
  Widget build(BuildContext context) {
    final deposits = finance.transactions
        .where((txn) => txn.type == TransactionType.deposit)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final recent = deposits.length > 7
        ? deposits.sublist(deposits.length - 7)
        : deposits;
    final maxY = recent.fold<double>(
      0,
      (max, txn) => txn.amount > max ? txn.amount : max,
    );

    return DashboardPanel(
      glowColor: const Color(0x663B9D5D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deposit Trend',
            style: GoogleFonts.oswald(
              fontSize: 22,
              color: const Color(0xFF171412),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last ${recent.length} deposit entries from live transaction data.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6F665C),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: recent.isEmpty
                ? const Center(child: Text('No deposit data yet'))
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (recent.length - 1).toDouble(),
                      minY: 0,
                      maxY: maxY == 0 ? 100 : maxY * 1.25,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: const Color(0xFFEFE6D8),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 54,
                            getTitlesWidget: (value, _) => Text(
                              CurrencyUtil.formatCompact(value),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: const Color(0xFF6F665C),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final index = value.toInt();
                              if (index < 0 || index >= recent.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat('dd MMM').format(recent[index].date),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: const Color(0xFF6F665C),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF171412),
                          getTooltipItems: (spots) => spots
                              .map(
                                (spot) => LineTooltipItem(
                                  CurrencyUtil.formatNoDecimal(spot.y),
                                  GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: const Color(0xFF3B9D5D),
                          barWidth: 4,
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF3B9D5D).withValues(alpha: 0.16),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                              radius: 3.5,
                              color: const Color(0xFF3B9D5D),
                              strokeColor: Colors.white,
                              strokeWidth: 1.5,
                            ),
                          ),
                          spots: [
                            for (var i = 0; i < recent.length; i++)
                              FlSpot(i.toDouble(), recent[i].amount),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlanProgressChart extends StatelessWidget {
  final FinanceOverviewProvider finance;

  const _PlanProgressChart({
    required this.finance,
  });

  @override
  Widget build(BuildContext context) {
    final plans = finance.prioritizedPlans.take(5).toList();
    final maxGoal = plans.fold<double>(
      0,
      (max, plan) => plan.goalAmount > max ? plan.goalAmount : max,
    );

    return DashboardPanel(
      glowColor: const Color(0x664C6A78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Progress',
            style: GoogleFonts.oswald(
              fontSize: 22,
              color: const Color(0xFF171412),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saved amount versus target for your current plans.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6F665C),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: plans.isEmpty
                ? const Center(child: Text('No plan data yet'))
                : BarChart(
                    BarChartData(
                      maxY: maxGoal == 0 ? 100 : maxGoal * 1.15,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: const Color(0xFFEFE6D8),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 52,
                            getTitlesWidget: (value, _) => Text(
                              CurrencyUtil.formatCompact(value),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: const Color(0xFF6F665C),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final index = value.toInt();
                              if (index < 0 || index >= plans.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _shortTitle(plans[index]),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: const Color(0xFF6F665C),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF171412),
                          getTooltipItem: (group, _, rod, __) {
                            final plan = plans[group.x.toInt()];
                            return BarTooltipItem(
                              '${plan.title}\nSaved ${CurrencyUtil.formatNoDecimal(plan.currentAmount)}',
                              GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < plans.length; i++)
                          BarChartGroupData(
                            x: i,
                            barsSpace: 6,
                            barRods: [
                              BarChartRodData(
                                toY: plans[i].goalAmount,
                                width: 12,
                                color: const Color(0xFFE6DAC7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              BarChartRodData(
                                toY: plans[i].currentAmount,
                                width: 12,
                                color: const Color(0xFF4C6A78),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _shortTitle(SavingsPlan plan) {
    final trimmed = plan.title.trim();
    if (trimmed.isEmpty) return 'Plan';
    return trimmed.length > 8 ? '${trimmed.substring(0, 8)}...' : trimmed;
  }
}

class _ReportColumn extends StatelessWidget {
  final FinanceOverviewProvider finance;

  const _ReportColumn({
    required this.finance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ReportCard(
          label: 'Saved',
          value: CurrencyUtil.formatCompact(finance.totalSaved),
          detail: 'Current savings',
          accent: const Color(0xFF876446),
          icon: Icons.savings_rounded,
        ),
        const SizedBox(height: 12),
        _ReportCard(
          label: 'Needed',
          value: CurrencyUtil.formatCompact(finance.monthlyCommitment),
          detail: 'Monthly pace',
          accent: const Color(0xFF4B9957),
          icon: Icons.calendar_month_rounded,
        ),
        const SizedBox(height: 12),
        _ReportCard(
          label: 'Loan',
          value: CurrencyUtil.formatCompact(finance.outstandingLoan),
          detail: 'Outstanding debt',
          accent: const Color(0xFFC2545E),
          icon: Icons.account_balance_wallet_rounded,
        ),
        const SizedBox(height: 12),
        _ReportCard(
          label: 'Net Worth',
          value: CurrencyUtil.formatCompact(finance.netWorth),
          detail: 'Savings minus debt',
          accent: const Color(0xFF4C6A78),
          icon: Icons.analytics_rounded,
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color accent;
  final IconData icon;

  const _ReportCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      glowColor: accent,
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: 104,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                const Spacer(),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.oswald(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: const Color(0xFF6F665C),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.oswald(
                fontSize: 20,
                height: 1,
                color: const Color(0xFF171412),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6F665C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
