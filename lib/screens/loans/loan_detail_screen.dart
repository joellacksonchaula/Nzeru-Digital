import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../providers/credit_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';

class LoanDetailScreen extends StatelessWidget {
  const LoanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<CreditProvider>();
    final activeLoan = loanProvider.activeCredit;
    final loanPayments =
        loanProvider.payments.where((p) => p.creditId == activeLoan?.id).toList();
    final distributions = loanProvider.distributions
        .where((d) => d.loanId == activeLoan?.id)
        .toList();
    final distribution = distributions.isEmpty ? null : distributions.first;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'CREDIT DETAILS',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            letterSpacing: 2,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: Stack(
        children: [
          const DashboardBackdrop(darkMode: false),
          if (activeLoan == null)
            const Center(child: Text('No active credit'))
          else
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: ProgressRing(
                      progress: activeLoan.repaymentProgress,
                      size: 160,
                      strokeWidth: 14,
                      label: 'REPAID',
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOut),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Column(
                      children: [
                        _row('Credit Amount', CurrencyUtil.format(activeLoan.amount)),
                        const Divider(color: AppColors.border, height: 24),
                        _row(
                          'Interest Rate',
                          '${activeLoan.interestRate.toStringAsFixed(0)}%',
                        ),
                        const Divider(color: AppColors.border, height: 24),
                        _row(
                          'Total with Interest',
                          CurrencyUtil.format(activeLoan.totalWithInterest),
                        ),
                        const Divider(color: AppColors.border, height: 24),
                        _row(
                          'Suggested Payment',
                          CurrencyUtil.format(activeLoan.suggestedRepayment),
                        ),
                        const Divider(color: AppColors.border, height: 24),
                        _row(
                          'Total Repaid',
                          CurrencyUtil.format(activeLoan.totalRepaid),
                          valueColor: AppColors.success,
                        ),
                        const Divider(color: AppColors.border, height: 24),
                        _row(
                          'Remaining',
                          CurrencyUtil.format(activeLoan.remainingBalance),
                          valueColor: AppColors.actionRed,
                        ),
                        const Divider(color: AppColors.border, height: 24),
                        _row('Duration', '${activeLoan.durationMonths} months'),
                        const Divider(color: AppColors.border, height: 24),
                        _row('Status', activeLoan.statusLabel),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  if (distribution != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'INTEREST DISTRIBUTION',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    GlassCard(
                      child: Column(
                        children: [
                          _row(
                            'Total Interest',
                            CurrencyUtil.format(distribution.totalInterest),
                          ),
                          const Divider(color: AppColors.border, height: 24),
                          _row(
                            'Your Share (50%)',
                            CurrencyUtil.format(distribution.userSavingsShare),
                            valueColor: AppColors.success,
                          ),
                          const Divider(color: AppColors.border, height: 24),
                          _row(
                            'Platform Share (50%)',
                            CurrencyUtil.format(distribution.platformShare),
                            valueColor: AppColors.info,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PAYMENT HISTORY',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  ...loanPayments.map(
                    (payment) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy').format(payment.paymentDate),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyUtil.format(payment.amountPaid),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
