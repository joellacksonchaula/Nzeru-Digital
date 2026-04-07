import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../providers/finance_overview_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/gold_button.dart';

class SavingsPlansScreen extends StatelessWidget {
  const SavingsPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceOverviewProvider>();
    final plans = finance.prioritizedPlans;
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
          ],
        ),
        const SizedBox(height: 18),
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
            onTap: (plan) =>
                Navigator.pushNamed(context, AppRoutes.planDetail),
          ),
        ],
      ],
    );
  }
}
