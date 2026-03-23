import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      title: 'A unified view of progress and pressure',
      subtitle:
          'Savings, penalties, deposits, and loan obligations all feed the same reporting surface so trends stay meaningful.',
      children: [
        DashboardStatGrid(
          items: [
            DashboardStatItem(
              label: 'Deposits',
              value: CurrencyUtil.formatCompact(finance.totalDeposits),
              detail: 'All credited savings deposits recorded so far.',
              icon: Icons.south_west_rounded,
              accent: const Color(0xFF4B9957),
            ),
            DashboardStatItem(
              label: 'Withdrawals',
              value: CurrencyUtil.formatCompact(finance.totalWithdrawals),
              detail: 'Money moved out of savings plans.',
              icon: Icons.north_east_rounded,
              accent: const Color(0xFFC2545E),
            ),
            DashboardStatItem(
              label: 'Penalties',
              value: CurrencyUtil.formatCompact(finance.totalPenalties),
              detail: 'Penalty deductions now flow straight from savings data.',
              icon: Icons.warning_amber_rounded,
              accent: const Color(0xFFB7821E),
            ),
            DashboardStatItem(
              label: 'Interest',
              value: CurrencyUtil.formatCompact(finance.interestEarned),
              detail: 'Interest rewards reflected alongside deposits.',
              icon: Icons.trending_up_rounded,
              accent: const Color(0xFF4C6A78),
            ),
          ],
        ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Plan Priorities'),
        const SizedBox(height: 10),
        if (finance.prioritizedPlans.isNotEmpty)
          DashboardPlanCarousel(plans: finance.prioritizedPlans)
        else
          const DashboardPanel(child: Text('Create savings plans to unlock richer reporting.')),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Financial Mix'),
        const SizedBox(height: 10),
        DashboardPanel(
          child: SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 46,
                sections: [
                  PieChartSectionData(
                    value: finance.totalDeposits <= 0 ? 1 : finance.totalDeposits,
                    title: '',
                    color: const Color(0xFF876446),
                    radius: 34,
                  ),
                  PieChartSectionData(
                    value: finance.totalPenalties <= 0 ? 1 : finance.totalPenalties,
                    title: '',
                    color: const Color(0xFFC2545E),
                    radius: 32,
                  ),
                  PieChartSectionData(
                    value: finance.interestEarned <= 0 ? 1 : finance.interestEarned,
                    title: '',
                    color: const Color(0xFF4B9957),
                    radius: 30,
                  ),
                  PieChartSectionData(
                    value: finance.outstandingLoan <= 0 ? 1 : finance.outstandingLoan,
                    title: '',
                    color: const Color(0xFF4C6A78),
                    radius: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Momentum'),
        const SizedBox(height: 10),
        DashboardPanel(
          child: SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.black.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Saved', 'Needed', 'Loan', 'Net'];
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(labels[index]),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _bar(0, finance.totalSaved, const Color(0xFF876446)),
                  _bar(1, finance.monthlyCommitment, const Color(0xFF4B9957)),
                  _bar(2, finance.outstandingLoan, const Color(0xFFC2545E)),
                  _bar(3, finance.netWorth < 0 ? 0 : finance.netWorth, const Color(0xFF4C6A78)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        DashboardPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardSectionTitle(title: 'Financial Summary'),
              const SizedBox(height: 8),
              DashboardInfoRow(
                label: 'Savings progress',
                value: '${(finance.progress * 100).round()}%',
              ),
              DashboardInfoRow(
                label: 'Plans on track',
                value: '${finance.onTrackPlans}',
                valueColor: const Color(0xFF4B9957),
              ),
              DashboardInfoRow(
                label: 'Plans behind',
                value: '${finance.behindPlans}',
                valueColor: const Color(0xFFC2545E),
              ),
              DashboardInfoRow(
                label: 'Net worth',
                value: CurrencyUtil.formatNoDecimal(finance.netWorth),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y <= 0 ? 1 : y,
          color: color,
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }
}
