import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/finance_overview_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceOverviewProvider>();
    final recentTransactions = finance.recentTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      body: Stack(
        children: [
          const DashboardBackdrop(darkMode: false),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nzelu Financial Reports',
                    style: GoogleFonts.sora(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: const Color(0xFF171412),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.75,
                    children: [
                      _MiniReportCard(
                        label: 'Deposits',
                        value: CurrencyUtil.formatCompact(
                          finance.totalDeposits,
                        ),
                        accent: const Color(0xFF0F9D8A),
                        icon: Icons.south_west_rounded,
                      ),
                      _MiniReportCard(
                        label: 'Withdrawals',
                        value: CurrencyUtil.formatCompact(
                          finance.totalWithdrawals,
                        ),
                        accent: const Color(0xFFD96069),
                        icon: Icons.north_east_rounded,
                      ),
                      _MiniReportCard(
                        label: 'Interest',
                        value: CurrencyUtil.formatCompact(
                          finance.interestEarned,
                        ),
                        accent: const Color(0xFF54738A),
                        icon: Icons.trending_up_rounded,
                      ),
                      _MiniReportCard(
                        label: 'Net worth',
                        value: CurrencyUtil.formatCompact(finance.netWorth),
                        accent: const Color(0xFFB88E5A),
                        icon: Icons.analytics_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  DashboardPanel(
                    glowColor: const Color(0x660F9D8A),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Savings summary',
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF171412),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ReportRow(
                          label: 'Current savings',
                          value: CurrencyUtil.formatNoDecimal(
                            finance.totalSaved,
                          ),
                        ),
                        _ReportRow(
                          label: 'Goal target',
                          value: CurrencyUtil.formatNoDecimal(
                            finance.totalGoal,
                          ),
                        ),
                        _ReportRow(
                          label: 'Remaining to target',
                          value: CurrencyUtil.formatNoDecimal(
                            finance.totalRemaining,
                          ),
                        ),
                        _ReportRow(
                          label: 'Monthly commitment',
                          value: CurrencyUtil.formatNoDecimal(
                            finance.monthlyCommitment,
                          ),
                        ),
                        _ReportRow(
                          label: 'Outstanding credit',
                          value: CurrencyUtil.formatNoDecimal(
                            finance.outstandingCredit,
                          ),
                          valueColor: const Color(0xFFD96069),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  DashboardPanel(
                    glowColor: const Color(0x6654738A),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent activity',
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF171412),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (recentTransactions.isEmpty)
                          Text(
                            'No transactions available yet.',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: const Color(0xFF6F665C),
                            ),
                          )
                        else
                          Column(
                            children: recentTransactions
                                .map(
                                  (txn) => Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.86,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFE6DAC7),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: txn.isCredit
                                                ? const Color(
                                                    0xFF0F9D8A,
                                                  ).withValues(alpha: 0.12)
                                                : const Color(
                                                    0xFFD96069,
                                                  ).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Icon(
                                            txn.isCredit
                                                ? Icons.arrow_downward_rounded
                                                : Icons.arrow_upward_rounded,
                                            size: 18,
                                            color: txn.isCredit
                                                ? const Color(0xFF0F9D8A)
                                                : const Color(0xFFD96069),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                txn.typeLabel,
                                                style: GoogleFonts.sora(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(
                                                    0xFF171412,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                DateFormat(
                                                  'dd MMM yyyy',
                                                ).format(txn.date),
                                                style: GoogleFonts.manrope(
                                                  fontSize: 12,
                                                  color: const Color(
                                                    0xFF6F665C,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          CurrencyUtil.formatNoDecimal(
                                            txn.amount,
                                          ),
                                          style: GoogleFonts.sora(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: txn.isCredit
                                                ? const Color(0xFF0F9D8A)
                                                : const Color(0xFFD96069),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
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

class _MiniReportCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  const _MiniReportCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      glowColor: accent,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
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
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF171412),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ReportRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: const Color(0xFF6F665C),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF171412),
            ),
          ),
        ],
      ),
    );
  }
}
