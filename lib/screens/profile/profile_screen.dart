import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          'A smaller profile dashboard with all main account tiles visible without horizontal scrolling.',
      children: [
        DashboardFixedGrid(
          mainAxisExtent: 132,
          children: [
            _ProfileCard(
              label: 'Health',
              value: '${user?.financialScore ?? 0}/100',
              detail: 'Financial score',
              accent: const Color(0xFF4B9957),
              icon: Icons.favorite_rounded,
            ),
            _ProfileCard(
              label: 'Saved',
              value: CurrencyUtil.formatCompact(finance.totalSaved),
              detail: 'Active savings',
              accent: const Color(0xFF876446),
              icon: Icons.savings_rounded,
            ),
            _ProfileCard(
              label: 'Loan Due',
              value: CurrencyUtil.formatCompact(finance.outstandingLoan),
              detail: 'Outstanding balance',
              accent: const Color(0xFFC2545E),
              icon: Icons.account_balance_wallet_rounded,
            ),
            _ProfileCard(
              label: 'Net',
              value: CurrencyUtil.formatCompact(finance.netWorth),
              detail: 'Net position',
              accent: const Color(0xFF4C6A78),
              icon: Icons.analytics_rounded,
            ),
          ],
        ),
        const SizedBox(height: 14),
        DashboardFixedGrid(
          mainAxisExtent: 132,
          children: [
            _ProfileCard(
              label: 'Email',
              value: user?.email ?? '',
              detail: 'Primary email',
              accent: const Color(0xFF4C6A78),
              icon: Icons.email_outlined,
            ),
            _ProfileCard(
              label: 'Phone',
              value: user?.phone ?? '',
              detail: 'Phone number',
              accent: const Color(0xFFB98A2D),
              icon: Icons.phone_rounded,
            ),
            _ProfileCard(
              label: 'Security',
              value: 'Enabled',
              detail: 'Account protected',
              accent: const Color(0xFF4B9957),
              icon: Icons.security_rounded,
            ),
            _ProfileCard(
              label: 'Support',
              value: 'Help',
              detail: 'Help and support',
              accent: const Color(0xFF876446),
              icon: Icons.help_outline_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),
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

class _ProfileCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color accent;
  final IconData icon;

  const _ProfileCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      glowColor: accent,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const Spacer(),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.oswald(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: const Color(0xFF6F665C),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value.isEmpty ? '--' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.oswald(
              fontSize: 18,
              height: 1,
              color: const Color(0xFF171412),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF6F665C),
            ),
          ),
        ],
      ),
    );
  }
}
