import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../providers/finance_overview_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/gold_button.dart';

class SavingsPlansScreen extends StatelessWidget {
  const SavingsPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceOverviewProvider>();
    final savings = context.watch<SavingsProvider>();
    final plans = finance.prioritizedPlans;
    final trialPlans = plans.where((plan) => plan.isTrial).toList();
    final trialPlan = trialPlans.isEmpty ? null : trialPlans.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DashboardPage(
      eyebrow: 'Nzelu Savings',
      title: 'Your Savings',
      subtitle:
          'Browse all your active and completed plans. Create a new one, or tap a plan to inspect it closely.',
      trailing: GoldButton(
        label: 'NEW PLAN',
        icon: Icons.add_rounded,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createPlan),
      ),
      children: [
        DashboardStatGrid(
          items: [
            DashboardStatItem(
              label: 'Total Saved',
              value: CurrencyUtil.formatCompact(finance.totalSaved),
              detail: 'All plans combined',
              icon: Icons.savings_rounded,
              accent: const Color(0xFF0ABAB5),
            ),
            DashboardStatItem(
              label: 'Monthly Goal',
              value: CurrencyUtil.formatCompact(finance.monthlyCommitment),
              detail: 'Combined commitment',
              icon: Icons.calendar_month_rounded,
              accent: const Color(0xFFD4AF37),
            ),
            DashboardStatItem(
              label: 'Deposits',
              value: CurrencyUtil.formatCompact(finance.totalDeposits),
              detail: 'Money added so far',
              icon: Icons.south_west_rounded,
              accent: const Color(0xFF3B9D5D),
            ),
            DashboardStatItem(
              label: 'Interest',
              value: CurrencyUtil.formatCompact(finance.interestEarned),
              detail: 'Rewards earned so far',
              icon: Icons.trending_up_rounded,
              accent: const Color(0xFF801818),
            ),
            if (finance.trialPlans.isNotEmpty)
              DashboardStatItem(
                label: 'Trial',
                value: CurrencyUtil.formatCompact(
                  finance.trialPlans.fold(0.0, (sum, plan) => sum + plan.currentAmount),
                ),
                detail: 'Sandbox savings total',
                icon: Icons.science_rounded,
                accent: const Color(0xFFD4AF37),
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (trialPlan != null) ...[
          DashboardPanel(
            glowColor: const Color(0x66D4AF37),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Trial plan detected. Use it to test deposits, credit requests, repayments, and penalties safely.',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6E5626)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await savings.simulateTrialPenalty(planId: trialPlan.id);
                    if (!context.mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Trial penalty applied.' : (savings.error ?? 'Penalty simulation failed.')),
                      ),
                    );
                  },
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('Apply Trial Penalty'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (plans.isEmpty)
          DashboardPanel(
            child: SizedBox(
              height: 160,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      size: 40,
                      color: isDark
                          ? const Color(0xFF8DE8E5)
                          : const Color(0xFF088F8B),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No savings plans yet.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFFD0D5DC)
                            : const Color(0xFF6F665C),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GoldButton(
                      label: 'CREATE FIRST PLAN',
                      icon: Icons.rocket_launch_rounded,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.createPlan),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          DashboardSectionTitle(
            title: 'Active Plans',
            actionLabel: 'Deposit',
            onAction: () =>
                Navigator.pushNamed(context, AppRoutes.deposit),
          ),
          const SizedBox(height: 10),
          DashboardPlanCarousel(
            plans: plans,
            onTap: (plan) => Navigator.pushNamed(
              context,
              AppRoutes.planDetail,
              arguments: plan.id,
            ),
          ),
        ],
      ],
    );
  }
}
