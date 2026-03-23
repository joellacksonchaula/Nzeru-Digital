import 'package:flutter/material.dart';
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

    return DashboardPage(
      eyebrow: 'Loans',
      title: 'Borrow with your full picture in view',
      subtitle:
          'Loan eligibility, repayment progress, and savings health stay in sync so borrowing decisions reflect your real financial position.',
      trailing: FilledButton.tonalIcon(
        onPressed: maxLoan > 0
            ? () => Navigator.pushNamed(context, AppRoutes.requestLoan)
            : null,
        icon: const Icon(Icons.account_balance_rounded),
        label: const Text('Request'),
      ),
      children: [
        DashboardStatGrid(
          items: [
            DashboardStatItem(
              label: 'Eligible',
              value: CurrencyUtil.formatCompact(maxLoan),
              detail: 'Based on 50% of your current savings balance.',
              icon: Icons.verified_rounded,
              accent: const Color(0xFF4B9957),
            ),
            DashboardStatItem(
              label: 'Saved',
              value: CurrencyUtil.formatCompact(savingsBalance),
              detail: 'Savings strength feeding directly into eligibility.',
              icon: Icons.savings_rounded,
              accent: const Color(0xFF876446),
            ),
            DashboardStatItem(
              label: 'Outstanding',
              value: CurrencyUtil.formatCompact(finance.outstandingLoan),
              detail: 'Active loan balance already counted in your summary.',
              icon: Icons.wallet_rounded,
              accent: const Color(0xFFC2545E),
            ),
            DashboardStatItem(
              label: 'Repaid',
              value: CurrencyUtil.formatCompact(finance.totalRepaid),
              detail: 'Payments completed across all recorded loans.',
              icon: Icons.paid_rounded,
              accent: const Color(0xFF4C6A78),
            ),
          ],
        ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Savings Context'),
        const SizedBox(height: 10),
        if (finance.prioritizedPlans.isNotEmpty)
          DashboardPlanCarousel(plans: finance.prioritizedPlans)
        else
          const DashboardPanel(
            child: Text('No savings plans yet. Building savings history improves visibility into loan readiness.'),
          ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Eligibility Overview'),
        const SizedBox(height: 10),
        DashboardPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardInfoRow(
                label: 'Current savings balance',
                value: CurrencyUtil.formatNoDecimal(savingsBalance),
              ),
              DashboardInfoRow(
                label: 'Maximum eligible amount',
                value: CurrencyUtil.formatNoDecimal(maxLoan),
                valueColor: const Color(0xFF4B9957),
              ),
              DashboardInfoRow(
                label: 'Net position after debt',
                value: CurrencyUtil.formatNoDecimal(finance.netWorth),
                valueColor: const Color(0xFF4C6A78),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: maxLoan > 0
                    ? () => Navigator.pushNamed(context, AppRoutes.requestLoan)
                    : null,
                icon: const Icon(Icons.account_balance_rounded),
                label: const Text('Request Loan'),
              ),
            ],
          ),
        ),
        if (activeLoan != null) ...[
          const SizedBox(height: 18),
          DashboardSectionTitle(title: 'Active Loan'),
          const SizedBox(height: 10),
          DashboardPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardInfoRow(
                  label: 'Loan amount',
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
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: activeLoan.repaymentProgress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFD7D1CB),
                    color: const Color(0xFF876446),
                  ),
                ),
                const SizedBox(height: 8),
                DashboardInfoRow(
                  label: 'Repayment progress',
                  value: '${(activeLoan.repaymentProgress * 100).round()}%',
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.repayment),
                  icon: const Icon(Icons.payment_rounded),
                  label: const Text('Make Payment'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
