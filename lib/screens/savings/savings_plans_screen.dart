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

    return DashboardPage(
      eyebrow: 'Savings',
      title: 'Savings plans with live pacing',
      subtitle:
          'Create, review, and manage plans directly here with a futuristic horizontal layout that keeps your goals and actions side by side.',
      trailing: FilledButton.tonalIcon(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createPlan),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Plan'),
      ),
      children: [
        DashboardStatGrid(
          items: [
            DashboardStatItem(
              label: 'Total saved',
              value: CurrencyUtil.formatCompact(finance.totalSaved),
              detail: 'Across ${finance.prioritizedPlans.length} active savings plans.',
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
        DashboardSectionTitle(title: 'Savings Hub'),
        const SizedBox(height: 10),
        DashboardHorizontalRail(
          children: [
            const SavingsPlanComposer(embedded: true),
            if (finance.prioritizedPlans.isEmpty)
              const DashboardPanel(
                width: 420,
                child: Text(
                  'No active savings plans yet. Use the planner on the left to create your first one.',
                  style: TextStyle(color: Colors.white),
                ),
              )
            else
              SizedBox(
                width: 520,
                child: DashboardPlanCarousel(
                  plans: finance.prioritizedPlans.take(5).toList(),
                  onTap: (_) => Navigator.pushNamed(context, AppRoutes.planDetail),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'All Plans'),
        const SizedBox(height: 10),
        if (finance.prioritizedPlans.isNotEmpty)
          DashboardHorizontalRail(
            children: finance.prioritizedPlans
                .map(
                  (plan) => SizedBox(
                    width: 420,
                    child: DashboardSavingsPlanCard(
                      plan: plan,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.planDetail),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
