import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      title: 'Financial Snapshot',
      subtitle:
          'Every key report block stays visible at once with a tighter 2 by 2 layout.',
      children: [
        DashboardFixedGrid(
          mainAxisExtent: 132,
          children: [
            _ReportCard(
              label: 'Deposits',
              value: CurrencyUtil.formatCompact(finance.totalDeposits),
              detail: 'Money added',
              accent: const Color(0xFF4B9957),
              icon: Icons.south_west_rounded,
            ),
            _ReportCard(
              label: 'Withdrawals',
              value: CurrencyUtil.formatCompact(finance.totalWithdrawals),
              detail: 'Money moved out',
              accent: const Color(0xFFC2545E),
              icon: Icons.north_east_rounded,
            ),
            _ReportCard(
              label: 'Penalties',
              value: CurrencyUtil.formatCompact(finance.totalPenalties),
              detail: 'Charges applied',
              accent: const Color(0xFFB7821E),
              icon: Icons.warning_amber_rounded,
            ),
            _ReportCard(
              label: 'Interest',
              value: CurrencyUtil.formatCompact(finance.interestEarned),
              detail: 'Rewards earned',
              accent: const Color(0xFF4C6A78),
              icon: Icons.trending_up_rounded,
            ),
          ],
        ),
        const SizedBox(height: 14),
        DashboardFixedGrid(
          mainAxisExtent: 132,
          children: [
            _ReportCard(
              label: 'Saved',
              value: CurrencyUtil.formatCompact(finance.totalSaved),
              detail: 'Current savings',
              accent: const Color(0xFF876446),
              icon: Icons.savings_rounded,
            ),
            _ReportCard(
              label: 'Needed',
              value: CurrencyUtil.formatCompact(finance.monthlyCommitment),
              detail: 'Monthly pace',
              accent: const Color(0xFF4B9957),
              icon: Icons.calendar_month_rounded,
            ),
            _ReportCard(
              label: 'Loan',
              value: CurrencyUtil.formatCompact(finance.outstandingLoan),
              detail: 'Outstanding debt',
              accent: const Color(0xFFC2545E),
              icon: Icons.account_balance_wallet_rounded,
            ),
            _ReportCard(
              label: 'Net Worth',
              value: CurrencyUtil.formatCompact(finance.netWorth),
              detail: 'Savings minus debt',
              accent: const Color(0xFF4C6A78),
              icon: Icons.analytics_rounded,
            ),
          ],
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
    );
  }
}
