import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_overview_provider.dart';
import '../../providers/loan_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';

class LoanEligibilityScreen extends StatelessWidget {
  const LoanEligibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loans = context.watch<LoanProvider>();
    final finance = context.watch<FinanceOverviewProvider>();
    final savingsBalance = auth.user?.savingsBalance ?? finance.totalSaved;
    final maxLoan = loans.getLoanEligibility(savingsBalance);
    final activeLoan = finance.activeLoan;
    final eligible = maxLoan > 0 && activeLoan == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
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
                    'Nzelu Loans',
                    style: GoogleFonts.oswald(
                      fontSize: 14,
                      letterSpacing: 2.2,
                      color: const Color(0xFF0ABAB5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Borrow with clarity',
                    style: GoogleFonts.oswald(
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
                            border: Border.all(
                              color: eligible
                                  ? const Color(0xFF4B9957).withValues(alpha: 0.25)
                                  : const Color(0xFFD16C5E).withValues(alpha: 0.22),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                eligible ? Icons.verified_rounded : Icons.block_rounded,
                                color: eligible
                                    ? const Color(0xFF4B9957)
                                    : const Color(0xFFD16C5E),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  eligible ? 'Eligible for Loan' : 'Not Eligible Yet',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: eligible
                                        ? const Color(0xFF32663E)
                                        : const Color(0xFF9B4E42),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: eligible
                            ? () => Navigator.pushNamed(context, AppRoutes.requestLoan)
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0ABAB5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.account_balance_rounded, size: 18),
                        label: Text(
                          'Request',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                          style: GoogleFonts.oswald(
                            fontSize: 22,
                            color: const Color(0xFF171412),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your savings balance powers your borrowing ceiling. We keep the active debt picture visible at the same time.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.4,
                            color: const Color(0xFF6F665C),
                          ),
                        ),
                        const SizedBox(height: 14),
                        DashboardFixedGrid(
                          mainAxisExtent: 122,
                          children: [
                            _LoanMiniCard(
                              label: 'Eligible',
                              value: CurrencyUtil.formatCompact(maxLoan),
                              accent: const Color(0xFF4B9957),
                              icon: Icons.verified_rounded,
                            ),
                            _LoanMiniCard(
                              label: 'Savings',
                              value: CurrencyUtil.formatCompact(savingsBalance),
                              accent: const Color(0xFF876446),
                              icon: Icons.savings_rounded,
                            ),
                            _LoanMiniCard(
                              label: 'Outstanding',
                              value: CurrencyUtil.formatCompact(finance.outstandingLoan),
                              accent: const Color(0xFFC2545E),
                              icon: Icons.wallet_rounded,
                            ),
                            _LoanMiniCard(
                              label: 'Repaid',
                              value: CurrencyUtil.formatCompact(finance.totalRepaid),
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
                          'Active Loan',
                          style: GoogleFonts.oswald(
                            fontSize: 22,
                            color: const Color(0xFF171412),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (activeLoan == null)
                          Text(
                            'No active loan at the moment. Once approved, repayment details appear here.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.4,
                              color: const Color(0xFF6F665C),
                            ),
                          )
                        else ...[
                          DashboardInfoRow(
                            label: 'Status',
                            value: activeLoan.statusLabel,
                            valueColor: const Color(0xFF4B9957),
                          ),
                          DashboardInfoRow(
                            label: 'Loan amount',
                            value: CurrencyUtil.formatNoDecimal(activeLoan.amount),
                          ),
                          DashboardInfoRow(
                            label: 'Total repayment',
                            value: CurrencyUtil.formatNoDecimal(activeLoan.totalWithInterest),
                          ),
                          DashboardInfoRow(
                            label: 'Monthly payment',
                            value: CurrencyUtil.formatNoDecimal(activeLoan.monthlyPayment),
                          ),
                          DashboardInfoRow(
                            label: 'Remaining balance',
                            value: CurrencyUtil.formatNoDecimal(activeLoan.remainingBalance),
                            valueColor: const Color(0xFFC2545E),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: activeLoan.repaymentProgress,
                              minHeight: 12,
                              backgroundColor: const Color(0xFFE7DED1),
                              color: const Color(0xFF4B9957),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Repayment progress ${(activeLoan.repaymentProgress * 100).round()}%',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4B9957),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.repayment),
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

class _LoanMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  const _LoanMiniCard({
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
            style: GoogleFonts.oswald(
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
            style: GoogleFonts.oswald(
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
