import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'config/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/savings_provider.dart';
import 'providers/loan_provider.dart';
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
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
      ],
      child: MaterialApp(
        title: 'Savings UTL',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
