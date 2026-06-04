import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/credit_provider.dart';
import '../../providers/finance_overview_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';

class LoanEligibilityScreen extends StatefulWidget {
  const LoanEligibilityScreen({super.key});

  @override
  State<LoanEligibilityScreen> createState() => _LoanEligibilityScreenState();
}

class _LoanEligibilityScreenState extends State<LoanEligibilityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreditProvider>().checkEligibility();
    });
  }

  @override
  Widget build(BuildContext context) {
    final credits = context.watch<CreditProvider>();
    final finance = context.watch<FinanceOverviewProvider>();
    final activeCredit = finance.activeCredit;
    final eligibility = credits.eligibility ?? const {};
    final trackedSavings =
        double.tryParse(
          (eligibility['tracked_savings_balance'] ?? finance.totalSaved)
              .toString(),
        ) ??
        finance.totalSaved;
    final maxCredit =
        double.tryParse(
          (eligibility['max_loan_amount'] ?? (trackedSavings * 0.4)).toString(),
        ) ??
        (trackedSavings * 0.4);
    final eligible =
        (eligibility['eligible'] as bool?) ??
        (maxCredit > 0 && activeCredit == null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const DashboardBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nzelu Credit',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      letterSpacing: 2.2,
                      color: const Color(0xFF0ABAB5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Borrow with clarity',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      height: 0.96,
                      color: const Color(0xFF171412),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: eligible
                                ? const Color(0xFFE7F4EA)
                                : const Color(0xFFF8E9E7),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            eligible
                                ? 'Eligible for credit'
                                : 'Credit locked right now',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: eligible
                                  ? const Color(0xFF32663E)
                                  : const Color(0xFF9B4E42),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: eligible
                            ? () => Navigator.pushNamed(
                                context,
                                AppRoutes.requestLoan,
                              )
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.faluRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 18,
                        ),
                        label: const Text('Request'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  DashboardPanel(
                    glowColor: const Color(0x664C6A78),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Eligibility Overview',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: const Color(0xFF171412),
                          ),
                        ),
                        const SizedBox(height: 14),
                        DashboardFixedGrid(
                          mainAxisExtent: 122,
                          children: [
                            _MetricCard(
                              label: 'Eligible',
                              value: CurrencyUtil.formatCompact(maxCredit),
                              accent: const Color(0xFF4B9957),
                              icon: Icons.verified_rounded,
                            ),
                            _MetricCard(
                              label: 'Tracked',
                              value: CurrencyUtil.formatCompact(trackedSavings),
                              accent: const Color(0xFF876446),
                              icon: Icons.savings_rounded,
                            ),
                            _MetricCard(
                              label: 'Outstanding',
                              value: CurrencyUtil.formatCompact(
                                finance.outstandingCredit,
                              ),
                              accent: const Color(0xFFC2545E),
                              icon: Icons.wallet_rounded,
                            ),
                            _MetricCard(
                              label: 'Repaid',
                              value: CurrencyUtil.formatCompact(
                                finance.totalRepaid,
                              ),
                              accent: const Color(0xFF4C6A78),
                              icon: Icons.paid_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  DashboardPanel(
                    glowColor: const Color(0x664B9957),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Credit',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: const Color(0xFF171412),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (activeCredit == null)
                          Text(
                            'No active credit at the moment. Your approved credit details will appear here once requested.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              height: 1.4,
                              color: const Color(0xFF6F665C),
                            ),
                          )
                        else ...[
                          DashboardInfoRow(
                            label: 'Status',
                            value: activeCredit.statusLabel,
                            valueColor: const Color(0xFF4B9957),
                          ),
                          DashboardInfoRow(
                            label: 'Credit amount',
                            value: CurrencyUtil.formatNoDecimal(
                              activeCredit.amount,
                            ),
                          ),
                          DashboardInfoRow(
                            label: 'Repayable total',
                            value: CurrencyUtil.formatNoDecimal(
                              activeCredit.totalWithInterest,
                            ),
                          ),
                          DashboardInfoRow(
                            label: 'Suggested payment',
                            value: CurrencyUtil.formatNoDecimal(
                              activeCredit.suggestedRepayment,
                            ),
                          ),
                          DashboardInfoRow(
                            label: 'Cash-out mode',
                            value: activeCredit.withdrawalModeLabel,
                          ),
                          DashboardInfoRow(
                            label: 'Remaining balance',
                            value: CurrencyUtil.formatNoDecimal(
                              activeCredit.remainingBalance,
                            ),
                            valueColor: const Color(0xFFC2545E),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: activeCredit.repaymentProgress,
                              minHeight: 12,
                              backgroundColor: AppColors.faluMist,
                              color: AppColors.loadingGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Repayment progress ${(activeCredit.repaymentProgress * 100).round()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4B9957),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.repayment,
                            ),
                            icon: const Icon(Icons.payment_rounded),
                            label: const Text('Make Payment'),
                          ),
                        ],
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  const _MetricCard({
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
            style: GoogleFonts.poppins(
              fontSize: 11,
              letterSpacing: 1.2,
              color: const Color(0xFF7E756A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 19,
              height: 1,
              color: const Color(0xFF171412),
            ),
          ),
        ],
      ),
    );
  }
}
