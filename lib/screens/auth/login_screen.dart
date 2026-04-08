import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/gold_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const DashboardBackdrop(darkMode: false),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
              child: Column(
                children: [
                  _AuthTopBar(
                    title: 'Login',
                    actionLabel: 'Register',
                    onAction: () => Navigator.pushNamed(context, AppRoutes.register),
                  ),
                  const SizedBox(height: 26),
                  _AuthShell(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BadgeIcon(icon: Icons.account_balance_rounded)
                              .animate()
                              .scale(duration: 450.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 20),
                          Text(
                            'Enter the vault',
                            style: GoogleFonts.orbitron(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF191514),
                            ),
                          ).animate().fadeIn(duration: 350.ms),
                          const SizedBox(height: 8),
                          Text(
                            'A 50/50 Tiffany Blue and Falu Red command deck with gold-lined boundaries for secure access.',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              height: 1.5,
                              color: const Color(0xFF5C5147),
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 22),
                          _AuthMetricRow(
                            items: const [
                              _AuthMetric(
                                label: 'Access',
                                value: 'Secure',
                                accent: AppColors.loadingGreen,
                              ),
                              _AuthMetric(
                                label: 'Split',
                                value: '50 / 50',
                                accent: AppColors.loadingRed,
                              ),
                              _AuthMetric(
                                label: 'Style',
                                value: 'Future',
                                accent: AppColors.goldString,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _AuthField(
                            controller: _usernameController,
                            hintText: 'Email address',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Enter your email' : null,
                          ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.08),
                          const SizedBox(height: 16),
                          _AuthField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Enter your password' : null,
                            suffix: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppColors.faluRed,
                              ),
                            ),
                          ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.08),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.faluRed,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GoldButton(
                            label: 'SIGN IN',
                            icon: Icons.login_rounded,
                            isLoading: auth.isLoading,
                            width: double.infinity,
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;

                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              final success = await auth.login(
                                _usernameController.text.trim(),
                                _passwordController.text,
                              );

                              if (!mounted) return;
                              if (success) {
                                navigator.pushReplacementNamed(AppRoutes.mainShell);
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(auth.error ?? 'Login failed'),
                                  ),
                                );
                              }
                            },
                          ).animate().fadeIn(delay: 260.ms),
                          const SizedBox(height: 18),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "New to Nzelu? ",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: const Color(0xFF5C5147),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.register,
                                  ),
                                  child: Text(
                                    'Create your vault',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.tiffanyBlueDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 120.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTopBar extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _AuthTopBar({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.faluTopBarGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.goldString.withValues(alpha: 0.92)),
        boxShadow: [
          BoxShadow(
            color: AppColors.faluRed.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthShell extends StatelessWidget {
  final Widget child;

  const _AuthShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.goldString.withValues(alpha: 0.85)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.75),
                Colors.white.withValues(alpha: 0.90),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.tiffanyBlueLight.withValues(alpha: 0.16),
                        Colors.transparent,
                        AppColors.faluRedLight.withValues(alpha: 0.18),
                      ],
                      stops: const [0.0, 0.48, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(painter: _AuthDividerPainter()),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final divider = Paint()
      ..color = AppColors.goldString.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final glow = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(0, size.height * 0.28)
      ..quadraticBezierTo(
        size.width * 0.44,
        size.height * 0.40,
        size.width,
        size.height * 0.14,
      );
    canvas.drawPath(path, divider);

    final second = Path()
      ..moveTo(0, size.height * 0.34)
      ..quadraticBezierTo(
        size.width * 0.44,
        size.height * 0.46,
        size.width,
        size.height * 0.20,
      );
    canvas.drawPath(second, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;

  const _BadgeIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            AppColors.tiffanyBlueLight,
            AppColors.tiffanyBlue,
            AppColors.faluRed,
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.goldString, width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 34),
    );
  }
}

class _AuthMetricRow extends StatelessWidget {
  final List<_AuthMetric> items;

  const _AuthMetricRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(child: items[i]),
          if (i != items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _AuthMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _AuthMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF241D1B),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        color: const Color(0xFF1D1918),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.tiffanyBlueDark),
        suffixIcon: suffix,
      ),
    );
  }
}
