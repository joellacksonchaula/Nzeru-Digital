import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../providers/finance_overview_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';

class SavingsPlansScreen extends StatelessWidget {
  const SavingsPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceOverviewProvider>();

    return DashboardPage(
      eyebrow: 'Savings',
      title: 'Savings plans with live pacing',
      subtitle:
          'Every plan below updates its required monthly, weekly, and daily pace from your current saved amount and deadline.',
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
        DashboardSectionTitle(title: 'Top Priority Plans'),
        const SizedBox(height: 10),
        if (finance.prioritizedPlans.isEmpty)
          const DashboardPanel(
            child: Text('No active savings plans yet. Create one to start tracking progress.'),
          )
        else
          DashboardPlanCarousel(
            plans: finance.prioritizedPlans,
            onTap: (_) => Navigator.pushNamed(context, AppRoutes.planDetail),
          ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'All Plans'),
        const SizedBox(height: 10),
        for (final plan in finance.prioritizedPlans) ...[
          DashboardSavingsPlanCard(
            plan: plan,
            onTap: () => Navigator.pushNamed(context, AppRoutes.planDetail),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
