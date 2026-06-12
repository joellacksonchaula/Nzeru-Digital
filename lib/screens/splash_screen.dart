import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/dashboard_kit.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final futures = await Future.wait([
      context.read<AuthProvider>().tryRestoreSession(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;

    final isAuthenticated = futures[0] as bool;
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const DashboardBackdrop(darkMode: false),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            // Logo with JPEG image
            const AppLogo(size: 100, iconSize: 48)
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 600.ms),
            const SizedBox(height: 30),
            Text(
              'NZELU',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.tiffanyBlue,
                letterSpacing: 6,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms),
            const SizedBox(height: 10),
            Text(
              'DIGITAL FINANCIAL VAULT',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMuted,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
            const SizedBox(height: 60),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.loadingRed,
                    backgroundColor: AppColors.tiffanyMist,
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
