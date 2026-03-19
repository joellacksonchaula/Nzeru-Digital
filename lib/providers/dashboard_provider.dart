import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  Map<String, dynamic>? data;
  bool isLoading = false;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.get('/api/dashboard/');
      data = res;
    } catch (e) {
      print("Dashboard error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}