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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
                  _RegisterTopBar(
                    onBack: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 22),
                  _RegisterShell(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const _RegisterBadge(icon: Icons.rocket_launch_rounded),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Build your vault',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF191514),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Future-facing registration with a clean 50/50 Tiffany and Falu split.',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        height: 1.45,
                                        color: const Color(0xFF5C5147),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 350.ms),
                          const SizedBox(height: 22),
                          const _RegisterStatusRow(),
                          const SizedBox(height: 22),
                          _RegisterField(
                            controller: _nameController,
                            hintText: 'Full name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: 14),
                          _RegisterField(
                            controller: _emailController,
                            hintText: 'Email address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Enter your email' : null,
                          ),
                          const SizedBox(height: 14),
                          _RegisterField(
                            controller: _phoneController,
                            hintText: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Enter your phone' : null,
                          ),
                          const SizedBox(height: 14),
                          _RegisterField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter a password';
                              if (v.length < 6) return 'Minimum 6 characters';
                              return null;
                            },
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
                          ),
                          const SizedBox(height: 14),
                          _RegisterField(
                            controller: _confirmController,
                            hintText: 'Confirm password',
                            icon: Icons.verified_user_outlined,
                            obscureText: _obscureConfirm,
                            validator: (v) {
                              if (v != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            suffix: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppColors.faluRed,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          GoldButton(
                            label: 'CREATE ACCOUNT',
                            icon: Icons.verified_rounded,
                            isLoading: auth.isLoading,
                            width: double.infinity,
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;

                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              final success = await auth.register(
                                _nameController.text.trim(),
                                _emailController.text.trim(),
                                _phoneController.text.trim(),
                                _passwordController.text,
                              );

                              if (!mounted) return;
                              if (success) {
                                navigator.pushReplacementNamed(AppRoutes.mainShell);
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      auth.error ?? 'Registration failed',
                                    ),
                                  ),
                                );
                              }
                            },
                          ).animate().fadeIn(delay: 180.ms),
                          const SizedBox(height: 18),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Text(
                                  'Already have a vault? ',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: const Color(0xFF5C5147),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Sign in',
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
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _RegisterTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.faluTopBarGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.goldString.withValues(alpha: 0.92)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'REGISTER',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterShell extends StatelessWidget {
  final Widget child;

  const _RegisterShell({required this.child});

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
                Colors.white.withValues(alpha: 0.78),
                Colors.white.withValues(alpha: 0.92),
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
                        AppColors.faluRedLight.withValues(alpha: 0.22),
                      ],
                      stops: const [0.0, 0.48, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned.fill(child: CustomPaint(painter: _RegisterDividerPainter())),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = AppColors.goldString.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path()
      ..moveTo(size.width * 0.08, 0)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.20,
        size.width,
        size.height * 0.08,
      );
    canvas.drawPath(path, gold);

    final lower = Path()
      ..moveTo(0, size.height * 0.24)
      ..quadraticBezierTo(
        size.width * 0.46,
        size.height * 0.36,
        size.width,
        size.height * 0.16,
      );
    canvas.drawPath(lower, gold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RegisterBadge extends StatelessWidget {
  final IconData icon;

  const _RegisterBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            AppColors.faluRed,
            AppColors.tiffanyBlue,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: AppColors.goldString, width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}

class _RegisterStatusRow extends StatelessWidget {
  const _RegisterStatusRow();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Identity', 'Live', AppColors.tiffanyBlueDark),
      ('Border', 'Gold', AppColors.goldString),
      ('Shield', 'Ready', AppColors.loadingGreen),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.64),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: items[i].$3.withValues(alpha: 0.55)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[i].$1.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: items[i].$3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF241D1B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _RegisterField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const _RegisterField({
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
