import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';

class LoanDetailScreen extends StatelessWidget {
  const LoanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loans = context.watch<LoanProvider>();
    final loan = loans.activeLoan;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: 'MK ',
      decimalDigits: 2,
    );
    final loanPayments =
        loans.payments.where((p) => p.loanId == loan?.id).toList();
    final distribution =
        loans.distributions.where((d) => d.loanId == loan?.id).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('LOAN DETAILS',
            style: GoogleFonts.orbitron(
                fontSize: 16, letterSpacing: 2, color: AppColors.gold)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loan == null
          ? const Center(child: Text('No active loan'))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: ProgressRing(
                      progress: loan.repaymentProgress,
                      size: 160,
                      strokeWidth: 14,
                      label: 'REPAID',
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOut),

                  const SizedBox(height: 20),

                  // Loan info
                  GlassCard(
                    child: Column(
                      children: [
                        _row('Loan Amount',
                            currencyFormat.format(loan.amount)),
                        const Divider(color: AppColors.border, height: 24),
                        _row('Interest Rate',
                            '${loan.interestRate.toStringAsFixed(0)}%'),
                        const Divider(color: AppColors.border, height: 24),
                        _row('Total with Interest',
                            currencyFormat.format(loan.totalWithInterest)),
                        const Divider(color: AppColors.border, height: 24),
                        _row('Monthly Payment',
                            currencyFormat.format(loan.monthlyPayment)),
                        const Divider(color: AppColors.border, height: 24),
                        _row('Total Repaid',
                            currencyFormat.format(loan.totalRepaid),
                            valueColor: AppColors.success),
                        const Divider(color: AppColors.border, height: 24),
                        _row('Remaining',
                            currencyFormat.format(loan.remainingBalance),
                            valueColor: AppColors.actionRed),
                        const Divider(color: AppColors.border, height: 24),
                        _row('Duration', '${loan.durationMonths} months'),
                        const Divider(color: AppColors.border, height: 24),
                        _row('Status', loan.statusLabel),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  // Interest distribution
                  if (distribution != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('INTEREST DISTRIBUTION',
                            style: GoogleFonts.orbitron(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                letterSpacing: 2)),
                      ),
                    ),
                    GlassCard(
                      child: Column(
                        children: [
                          _row('Total Interest',
                              currencyFormat.format(distribution.totalInterest)),
                          const Divider(color: AppColors.border, height: 24),
                          _row('Your Share (50%)',
                              currencyFormat
                                  .format(distribution.userSavingsShare),
                              valueColor: AppColors.success),
                          const Divider(color: AppColors.border, height: 24),
                          _row('Platform Share (50%)',
                              currencyFormat
                                  .format(distribution.platformShare),
                              valueColor: AppColors.info),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],

                  // Payments history
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('PAYMENT HISTORY',
                          style: GoogleFonts.orbitron(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              letterSpacing: 2)),
                    ),
                  ),
                  ...loanPayments.map(
                    (payment) => Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.check_circle_outline,
                                color: AppColors.success, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payment',
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                                Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(payment.paymentDate),
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Text(currencyFormat.format(payment.amountPaid),
                              style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}
