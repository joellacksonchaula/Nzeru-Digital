import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/savings_provider.dart';
import '../../providers/loan_provider.dart';
import '../../providers/auth_provider.dart' as auth;
import '../../widgets/bottom_nav_bar.dart';
import 'dashboard_screen_v2.dart';
import '../savings/savings_plans_screen.dart';
import '../loans/loan_eligibility_screen.dart';
import '../reports/reports_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreenV2(),
    SavingsPlansScreen(),
    LoanEligibilityScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load mock data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsProvider>().loadData();
      context.read<LoanProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          // Refresh data when navigating
          if (i == 0 || i == 1 || i == 2) {
             context.read<auth.AuthProvider>().refreshProfile();
             context.read<SavingsProvider>().loadData();
             context.read<LoanProvider>().loadData();
          }
        },
      ),
    );
  }
}
