import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withAlpha(40),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (user?.name ?? 'U')[0].toUpperCase(),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            color: AppColors.background, size: 16),
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: 16),
              Text(
                user?.name ?? 'User',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textMuted),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 30),

              // Financial Score
              GlassCard(
                child: Column(
                  children: [
                    Text('FINANCIAL HEALTH SCORE',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            letterSpacing: 2)),
                    const SizedBox(height: 20),
                    ProgressRing(
                      progress: (user?.financialScore ?? 0) / 100,
                      size: 140,
                      strokeWidth: 12,
                      centerText: '${user?.financialScore ?? 0}',
                      label: 'OUT OF 100',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _scoreItem('Consistency', '90%', AppColors.success),
                        _scoreItem('Repayment', '100%', AppColors.gold),
                        _scoreItem('Penalties', 'Low', AppColors.info),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 8),

              // User info
              GlassCard(
                child: Column(
                  children: [
                    _infoRow(Icons.person_outline, 'Name', user?.name ?? ''),
                    const Divider(color: AppColors.border, height: 24),
                    _infoRow(Icons.email_outlined, 'Email', user?.email ?? ''),
                    const Divider(color: AppColors.border, height: 24),
                    _infoRow(Icons.phone_outlined, 'Phone', user?.phone ?? ''),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),

              // Settings
              const SizedBox(height: 16),
              _settingsTile(Icons.security, 'Security', () {}),
              _settingsTile(Icons.notifications_outlined, 'Notifications', () {}),
              _settingsTile(Icons.help_outline, 'Help & Support', () {}),
              _settingsTile(Icons.info_outline, 'About', () {}),

              const SizedBox(height: 16),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    auth.logout();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.actionRed.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.actionRed.withAlpha(40)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout,
                            color: AppColors.actionRed, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'SIGN OUT',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.actionRed,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.playfairDisplay(
                fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textPrimary)),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
