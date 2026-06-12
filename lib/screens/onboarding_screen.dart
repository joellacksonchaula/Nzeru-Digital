import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import '../widgets/dashboard_kit.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.savings_rounded,
      title: 'SAVE',
      subtitle: 'Build Financial Discipline',
      description:
          'Create structured savings plans and build consistent saving habits with smart commitment tracking.',
    ),
    _OnboardingPage(
      icon: Icons.account_balance_rounded,
      title: 'BORROW',
      subtitle: 'Access Smart Credit',
      description:
          'Your tracked savings unlock credit eligibility. Access up to 40% with transparent repayment and locked release options.',
    ),
    _OnboardingPage(
      icon: Icons.trending_up_rounded,
      title: 'GROW',
      subtitle: 'Financial Freedom',
      description:
          'Earn interest rewards, track your financial health score, and grow your wealth over time.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const DashboardBackdrop(darkMode: false),
          SafeArea(
            child: Column(
              children: [
            // Logo and Skip button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: const AppLogo(size: 44, iconSize: 22, showText: true),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
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
                            border: Border.all(
                              color: AppColors.primaryRed,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            page.icon,
                            color: Colors.white,
                            size: 56,
                          ),
                        ).animate().scale(
                              begin: const Offset(0.8, 0.8),
                              duration: 500.ms,
                              curve: Curves.easeOut,
                            ),
                        const SizedBox(height: 50),
                        Text(
                          page.title,
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tiffanyBlue,
                            letterSpacing: 8,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                        const SizedBox(height: 12),
                        Text(
                          page.subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                        const SizedBox(height: 24),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: AppColors.textMuted,
                            height: 1.6,
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == i ? 30 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? (i.isEven
                            ? AppColors.loadingRed
                            : AppColors.loadingGreen)
                        : AppColors.textMuted.withAlpha(60),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _currentPage == i
                        ? [
                            BoxShadow(
                              color: (i.isEven
                                      ? AppColors.loadingRed
                                      : AppColors.loadingGreen)
                                  .withAlpha(60),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AppButton(
                label: _currentPage == _pages.length - 1
                    ? 'GET STARTED'
                    : 'NEXT',
                width: double.infinity,
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
              ),
            ),
            const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
