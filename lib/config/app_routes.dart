import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/dashboard_screen_v2.dart';
import '../screens/savings/savings_plans_screen.dart';
import '../screens/savings/create_plan_screen.dart';
import '../screens/savings/plan_detail_screen.dart';
import '../screens/savings/deposit_screen.dart';
import '../screens/loans/loan_eligibility_screen.dart';
import '../screens/loans/request_loan_screen.dart';
import '../screens/loans/loan_detail_screen.dart';
import '../screens/loans/repayment_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/home/main_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainShell = '/main';
  static const String dashboard = '/dashboard';
  static const String savingsPlans = '/savings';
  static const String createPlan = '/savings/create';
  static const String planDetail = '/savings/detail';
  static const String deposit = '/savings/deposit';
  static const String loanEligibility = '/loans/eligibility';
  static const String requestLoan = '/loans/request';
  static const String loanDetail = '/loans/detail';
  static const String repayment = '/loans/repayment';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        onboarding: (_) => const OnboardingScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        mainShell: (_) => const MainShell(),
        dashboard: (_) => const DashboardScreenV2(),
        savingsPlans: (_) => const SavingsPlansScreen(),
        createPlan: (_) => const CreatePlanScreen(),
        planDetail: (_) => const PlanDetailScreen(),
        deposit: (_) => const DepositScreen(),
        loanEligibility: (_) => const LoanEligibilityScreen(),
        requestLoan: (_) => const RequestLoanScreen(),
        loanDetail: (_) => const LoanDetailScreen(),
        repayment: (_) => const RepaymentScreen(),
        reports: (_) => const ReportsScreen(),
        notifications: (_) => const NotificationsScreen(),
        profile: (_) => const ProfileScreen(),
      };
}
