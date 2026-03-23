import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../providers/finance_overview_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
import 'create_plan_screen.dart';

class SavingsPlansScreen extends StatelessWidget {
  const SavingsPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceOverviewProvider>();
    final plans = finance.prioritizedPlans;

    return DashboardPage(
      eyebrow: 'Savings',
      title: 'Savings plans first',
      subtitle:
          'Review every savings plan at the top, then manage pacing, targets, and new plan creation below.',
      trailing: FilledButton.tonalIcon(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createPlan),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Plan'),
      ),
      children: [
        DashboardSectionTitle(title: 'Your Savings'),
        const SizedBox(height: 10),
        if (plans.isEmpty)
          const DashboardPanel(
            width: double.infinity,
            child: Text(
              'No active savings plans yet. Create your first plan below.',
              style: TextStyle(color: Color(0xFF171412)),
            ),
          )
        else
          DashboardHorizontalRail(
            children: plans
                .map(
                  (plan) => SizedBox(
                    width: 390,
                    child: DashboardSavingsPlanCard(
                      plan: plan,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.planDetail),
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 18),
        DashboardStatGrid(
          items: [
            DashboardStatItem(
              label: 'Total saved',
              value: CurrencyUtil.formatCompact(finance.totalSaved),
              detail: 'Across ${plans.length} active savings plans.',
              icon: Icons.savings_rounded,
              accent: const Color(0xFF876446),
            ),
            DashboardStatItem(
              label: 'Goal total',
              value: CurrencyUtil.formatCompact(finance.totalGoal),
              detail: 'Combined target value for all active plans.',
              icon: Icons.flag_circle_rounded,
              accent: const Color(0xFF4C6A78),
            ),
            DashboardStatItem(
              label: 'Needed monthly',
              value: CurrencyUtil.formatCompact(finance.monthlyCommitment),
              detail: 'To keep every plan on pace from today.',
              icon: Icons.calendar_month_rounded,
              accent: const Color(0xFF4B9957),
            ),
            DashboardStatItem(
              label: 'Needed weekly',
              value: CurrencyUtil.formatCompact(finance.weeklyCommitment),
              detail: 'A weekly view of your total commitment.',
              icon: Icons.date_range_rounded,
              accent: const Color(0xFFC2545E),
            ),
          ],
        ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Create Plan'),
        const SizedBox(height: 10),
        const SavingsPlanComposer(embedded: true),
      ],
    );
  }
}
