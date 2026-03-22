import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_text.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/progress_ring.dart';
import '../../utils/currency_util.dart';

class LoanEligibilityScreen extends StatelessWidget {
  const LoanEligibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loans = context.watch<LoanProvider>();
    final user = auth.user;
    final savingsBalance = user?.savingsBalance ?? 0;
    final maxLoan = loans.getLoanEligibility(savingsBalance);
    final activeLoan = loans.activeLoan;

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
                  'LOANS',
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    letterSpacing: 3,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Eligibility Card
              GlassCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('LOAN ELIGIBILITY',
                            style: GoogleFonts.orbitron(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                letterSpacing: 2)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: maxLoan > 0
                                ? AppColors.success.withAlpha(20)
                                : AppColors.actionRed.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            maxLoan > 0 ? 'ELIGIBLE' : 'NOT ELIGIBLE',
                            style: GoogleFonts.orbitron(
                              fontSize: 9,
                              color: maxLoan > 0
                                  ? AppColors.success
                                  : AppColors.actionRed,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlowText(
                      text: CurrencyUtil.format(maxLoan),
                      fontSize: 36,
                    ),
                    const SizedBox(height: 8),
                    Text('Maximum loan amount (50% of savings)',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 20),
                    // Savings breakdown
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Savings',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                               Text(CurrencyUtil.format(savingsBalance),
                                  style: GoogleFonts.orbitron(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                          Icon(Icons.arrow_forward_rounded,
                              color: AppColors.gold),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Max Loan',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(CurrencyUtil.format(maxLoan),
                                  style: GoogleFonts.orbitron(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (maxLoan > 0)
                      GoldButton(
                        label: 'REQUEST LOAN',
                        icon: Icons.account_balance_rounded,
                        width: double.infinity,
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.requestLoan),
                      ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              // Active Loan
              if (activeLoan != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('ACTIVE LOAN',
                      style: GoogleFonts.orbitron(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          letterSpacing: 2)),
                ),
                const SizedBox(height: 10),
                GlassCard(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.loanDetail),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Loan Amount',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                    CurrencyUtil
                                        .format(activeLoan.totalWithInterest),
                                    style: GoogleFonts.orbitron(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary)),
                                const SizedBox(height: 10),
                                Text('Monthly Payment',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                    CurrencyUtil
                                        .format(activeLoan.monthlyPayment),
                                    style: GoogleFonts.orbitron(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.gold)),
                              ],
                            ),
                          ),
                          ProgressRing(
                            progress: activeLoan.repaymentProgress,
                            size: 90,
                            strokeWidth: 8,
                            label: 'REPAID',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: activeLoan.repaymentProgress,
                          backgroundColor: AppColors.surface,
                          color: AppColors.gold,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Repaid: ${CurrencyUtil.format(activeLoan.totalRepaid)}',
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: AppColors.textMuted)),
                          Text(
                              'Remaining: ${CurrencyUtil.format(activeLoan.remainingBalance)}',
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GoldButton(
                        label: 'MAKE PAYMENT',
                        isOutlined: true,
                        icon: Icons.payment_rounded,
                        width: double.infinity,
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.repayment),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
