import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../providers/savings_provider.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/glass_card.dart';
import '../../utils/currency_util.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savings = context.watch<SavingsProvider>();
    final loans = context.watch<LoanProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'FINANCIAL REPORTS',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    letterSpacing: 3,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Savings Growth Chart
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAVINGS GROWTH',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 500,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: AppColors.border,
                              strokeWidth: 0.5,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                interval: 1000,
                                getTitlesWidget: (value, meta) => Text(
                                  CurrencyUtil.formatCompact(value),
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppColors.textMuted),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  const months = [
                                    'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'
                                  ];
                                  if (value.toInt() < months.length) {
                                    return Text(
                                      months[value.toInt()],
                                      style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: AppColors.textMuted),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: 0,
                          maxY: 4000,
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 300),
                                FlSpot(1, 800),
                                FlSpot(2, 1400),
                                FlSpot(3, 1900),
                                FlSpot(4, 2600),
                                FlSpot(5, 3200),
                              ],
                              isCurved: true,
                              color: AppColors.gold,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) =>
                                    FlDotCirclePainter(
                                  radius: 4,
                                  color: AppColors.gold,
                                  strokeWidth: 2,
                                  strokeColor: AppColors.background,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.gold.withAlpha(50),
                                    AppColors.gold.withAlpha(5),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              // Savings vs Penalties Pie
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAVINGS BREAKDOWN',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    value: 3200,
                                    title: '',
                                    color: AppColors.gold,
                                    radius: 30,
                                  ),
                                  PieChartSectionData(
                                    value: 20,
                                    title: '',
                                    color: AppColors.actionRed,
                                    radius: 30,
                                  ),
                                  PieChartSectionData(
                                    value: 50,
                                    title: '',
                                    color: AppColors.success,
                                    radius: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _legendItem('Deposits', AppColors.gold),
                              const SizedBox(height: 12),
                              _legendItem('Penalties', AppColors.actionRed),
                              const SizedBox(height: 12),
                              _legendItem('Interest', AppColors.success),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              // Loan Repayment Chart
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REPAYMENT PERFORMANCE',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const m = ['Jan', 'Feb', 'Mar'];
                                  if (value.toInt() < m.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(m[value.toInt()],
                                          style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: AppColors.textMuted)),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(
                                toY: 100,
                                color: AppColors.gold,
                                width: 30,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                              ),
                            ]),
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(
                                toY: 100,
                                color: AppColors.gold,
                                width: 30,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                              ),
                            ]),
                            BarChartGroupData(x: 2, barRods: [
                              BarChartRodData(
                                toY: 100,
                                color: AppColors.gold,
                                width: 30,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

              // Summary Stats
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FINANCIAL SUMMARY',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            letterSpacing: 2)),
                    const SizedBox(height: 16),
                    _summaryRow('Total Deposits', CurrencyUtil.format(3200)),
                    const Divider(color: AppColors.border, height: 20),
                    _summaryRow('Total Penalties',
                        CurrencyUtil.format(savings.totalPenalties),
                        color: AppColors.actionRed),
                    const Divider(color: AppColors.border, height: 20),
                    _summaryRow('Interest Earned', CurrencyUtil.format(50),
                        color: AppColors.success),
                    const Divider(color: AppColors.border, height: 20),
                    _summaryRow('Loan Repaid',
                        CurrencyUtil.format(loans.totalRepaid),
                        color: AppColors.info),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.textPrimary)),
      ],
    );
  }
}
