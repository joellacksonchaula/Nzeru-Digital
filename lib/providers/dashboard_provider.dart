import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/savings_transaction.dart';

class DashboardProvider with ChangeNotifier {
  Map<String, dynamic>? _rawData;
  User? user;
  List<SavingsTransaction> recentTransactions = [];
  bool isLoading = false;
  
  // Crypto Data
  List<Map<String, dynamic>> cryptoMarkets = [];
  String marketStatus = "crypto dashboard updated please";

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

      // Mock Crypto Data for UI integration
      cryptoMarkets = [
        {
          'name': 'Bitcoin',
          'symbol': 'BTC',
          'price': 124500000.0,
          'change': 5.4,
          'marketCap': 2400000000000.0,
          'volume': 45000000000.0,
          'isGold': false,
        },
        {
          'name': 'Ethereum',
          'symbol': 'ETH',
          'price': 4200000.0,
          'change': -1.2,
          'marketCap': 450000000000.0,
          'volume': 15000000000.0,
          'isGold': false,
        },
        {
          'name': 'Digital Gold',
          'symbol': 'GOLD',
          'price': 85000.0,
          'change': 0.8,
          'marketCap': 1200000000.0,
          'volume': 50000000.0,
          'isGold': true,
        },
      ];

    } catch (e) {
      debugPrint("Dashboard error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}