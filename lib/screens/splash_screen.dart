import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import '../providers/auth_provider.dart';
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
      Future.delayed(const Duration(seconds: 3)),
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Centred logo — logo only, no text
          Center(
            child: AppLogo(size: 280, iconSize: 140)
                .animate()
                .scale(
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1, 1),
                  duration: 900.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 700.ms),
          ),

          // Subtle loading spinner pinned to the bottom
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primaryTiffany,
                  backgroundColor: AppColors.primaryTiffanyLight,
                ),
              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
            ),
          ),
        ],
      ),
    );
  }
}
