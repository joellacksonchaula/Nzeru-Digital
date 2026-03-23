import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_overview_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final finance = context.watch<FinanceOverviewProvider>();
    final user = auth.user;

    return DashboardPage(
      eyebrow: 'Profile',
      title: user?.name ?? 'Your profile',
      subtitle:
          'Personal details, financial health, and account actions now sit inside the same dashboard system as the rest of the app.',
      children: [
        DashboardStatGrid(
          items: [
            DashboardStatItem(
              label: 'Health score',
              value: '${user?.financialScore ?? 0}/100',
              detail: 'Snapshot of overall financial health.',
              icon: Icons.favorite_rounded,
              accent: const Color(0xFF4B9957),
            ),
            DashboardStatItem(
              label: 'Saved',
              value: CurrencyUtil.formatCompact(finance.totalSaved),
              detail: 'Visible total from active savings plans.',
              icon: Icons.savings_rounded,
              accent: const Color(0xFF876446),
            ),
            DashboardStatItem(
              label: 'Loan due',
              value: CurrencyUtil.formatCompact(finance.outstandingLoan),
              detail: 'Outstanding balance linked from loans.',
              icon: Icons.account_balance_wallet_rounded,
              accent: const Color(0xFFC2545E),
            ),
            DashboardStatItem(
              label: 'Net position',
              value: CurrencyUtil.formatCompact(finance.netWorth),
              detail: 'Savings minus outstanding debt.',
              icon: Icons.analytics_rounded,
              accent: const Color(0xFF4C6A78),
            ),
          ],
        ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Priority Plans'),
        const SizedBox(height: 10),
        if (finance.prioritizedPlans.isNotEmpty)
          DashboardPlanCarousel(plans: finance.prioritizedPlans)
        else
          const DashboardPanel(child: Text('Your savings plans will appear here once created.')),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Account Details'),
        const SizedBox(height: 10),
        DashboardPanel(
          child: Column(
            children: [
              DashboardInfoRow(label: 'Name', value: user?.name ?? ''),
              DashboardInfoRow(label: 'Email', value: user?.email ?? ''),
              DashboardInfoRow(label: 'Phone', value: user?.phone ?? ''),
              DashboardInfoRow(
                label: 'Financial score',
                value: '${user?.financialScore ?? 0}',
                valueColor: const Color(0xFF4B9957),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        DashboardSectionTitle(title: 'Settings'),
        const SizedBox(height: 10),
        DashboardPanel(
          child: Column(
            children: const [
              _SettingRow(icon: Icons.security_rounded, label: 'Security'),
              _SettingRow(icon: Icons.notifications_outlined, label: 'Notifications'),
              _SettingRow(icon: Icons.help_outline_rounded, label: 'Help & Support'),
              _SettingRow(icon: Icons.info_outline_rounded, label: 'About'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        DashboardPanel(
          child: Center(
            child: OutlinedButton.icon(
              onPressed: () {
                auth.logout();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SettingRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6A645C)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF6A645C)),
        ],
      ),
    );
  }
}
