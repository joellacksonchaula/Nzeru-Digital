import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/savings_transaction.dart';

class DashboardProvider with ChangeNotifier {
  Map<String, dynamic>? _rawData;
  User? user;
  List<SavingsTransaction> recentTransactions = [];
  bool isLoading = false;

  Map<String, dynamic>? get data => _rawData;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService().getDashboard();
      _rawData = res;
      
      if (res.containsKey('user')) {
        user = User.fromJson(res['user']);
      }
      
      if (res.containsKey('recent_transactions')) {
          recentTransactions = (res['recent_transactions'] as List)
            .map((t) => SavingsTransaction.fromJson(t))
            .toList();
      }
    } catch (e) {
      debugPrint("Dashboard error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}