import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'config/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/finance_overview_provider.dart';
import 'providers/savings_provider.dart';
import 'providers/loan_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/theme_mode_provider.dart';
import 'services/api_service.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load any persisted auth tokens so ApiService knows if user is logged in
  // before the widget tree is built.
  await ApiService().loadTokens();

  runApp(const SavingsUTLApp());
}

class SavingsUTLApp extends StatelessWidget {
  const SavingsUTLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()),
        ChangeNotifierProxyProvider3<AuthProvider, SavingsProvider, LoanProvider,
            FinanceOverviewProvider>(
          create: (_) => FinanceOverviewProvider(),
          update: (_, auth, savings, loans, finance) {
            final provider = finance ?? FinanceOverviewProvider();
            provider.sync(auth: auth, savings: savings, loans: loans);
            return provider;
          },
        ),
      ],
      child: Consumer<ThemeModeProvider>(
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'Savings UTL',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode.themeMode,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
