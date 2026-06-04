import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_kit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return DashboardPage(
      eyebrow: 'Nzelu Profile',
      title: user?.name ?? 'Your profile',
      subtitle:
          'Your live profile, tracked savings, and security shortcuts stay synced with the backend from here.',
      children: [
        DashboardPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(label: 'Personal Info'),
              const SizedBox(height: 12),
              _ProfileRow(
                icon: Icons.person_outline_rounded,
                label: 'Full name',
                value: user?.name ?? '--',
              ),
              _ProfileRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user?.email ?? '--',
              ),
              _ProfileRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: (user?.phone ?? '').trim().isEmpty ? '--' : user!.phone,
              ),
              _ProfileRow(
                icon: Icons.savings_outlined,
                label: 'Tracked savings',
                value: user == null ? '--' : user.trackedSavingsBalance.toStringAsFixed(2),
              ),
              _ProfileRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Outstanding credit',
                value: user == null ? '--' : user.creditBalance.toStringAsFixed(2),
              ),
              const SizedBox(height: 18),
              const _SectionTitle(label: 'Settings'),
              const SizedBox(height: 12),
              _ProfileAction(
                icon: Icons.settings_outlined,
                label: 'Open settings',
                detail: 'Security, preferences, financial defaults, and support',
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
              _ProfileAction(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                detail: 'Leave this account on this device',
                onTap: () {
                  auth.logout();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 14,
        letterSpacing: 1.8,
        color: const Color(0xFF0ABAB5),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6DAC7)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0ABAB5).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0ABAB5), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6F665C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: const Color(0xFF171412),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6DAC7)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFC2545E).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFC2545E), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: const Color(0xFF171412),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6F665C),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF6F665C)),
          ],
        ),
      ),
    );
  }
}
