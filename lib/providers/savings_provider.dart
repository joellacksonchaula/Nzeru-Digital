import 'package:flutter/material.dart';
import '../models/savings_plan.dart';
import '../models/savings_transaction.dart';
import '../models/penalty.dart';
import '../services/api_service.dart';

class SavingsProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<SavingsPlan> _plans = [];
  List<SavingsTransaction> _transactions = [];
  List<Penalty> _penalties = [];
  bool _isLoading = false;
  String? _error;

  List<SavingsPlan> get plans => _plans;
  List<SavingsTransaction> get transactions => _transactions;
  List<Penalty> get penalties => _penalties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSavings =>
      _transactions
          .where((t) => t.isCredit && t.status == TransactionStatus.completed)
          .fold(0.0, (sum, t) => sum + t.amount) -
      _transactions
          .where((t) => !t.isCredit && t.status == TransactionStatus.completed)
          .fold(0.0, (sum, t) => sum + t.amount);

  double get totalPenalties =>
      _penalties.where((p) => p.isApplied).fold(0.0, (sum, p) => sum + p.amount);

  /// ─── Load all data ─────────────────────────────
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final plansData = await _api.getSavingsPlans();
      _plans = plansData
          .map((json) => SavingsPlan.fromJson(_normalizeKeys(json as Map<String, dynamic>)))
          .toList();

      final txnData = await _api.getTransactions();
      _transactions = txnData
          .map((json) => SavingsTransaction.fromJson(_normalizeKeys(json as Map<String, dynamic>)))
          .toList();

      final penData = await _api.getPenalties();
      _penalties = penData
          .map((json) => Penalty.fromJson(_normalizeKeys(json as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      _error = 'Failed to load savings data';
      _plans = [];
      _transactions = [];
      _penalties = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ─── Add a new savings plan ────────────────────
  Future<bool> addPlan(SavingsPlan plan) async {
    try {
      // toJson() already returns the correct string codes for the backend
      final data = plan.toJson();
      await _api.createSavingsPlan(data);
      await loadData();
      return true;
    } catch (e) {
      _error = 'Failed to create savings plan: $e';
      notifyListeners();
      return false;
    }
  }

  /// ─── Add a deposit to a savings plan ─────────
  Future<bool> addDeposit(SavingsTransaction transaction) async {
    try {
      await _api.createDeposit({
        'amount': transaction.amount,
        'type': 'DEPOSIT',
        'status': 'COMPLETED',
        'plan': transaction.planId,
        'description': transaction.description ?? 'Savings deposit',
      });
      await loadData(); // Refresh data
      return true;
    } catch (e) {
      _error = 'Failed to record deposit';
      notifyListeners();
      return false;
    }
  }

  /// ─── Normalize API keys to match model expectations ─────────
  Map<String, dynamic> _normalizeKeys(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    if (normalized['id'] != null) normalized['id'] = normalized['id'].toString();
    if (normalized['user'] != null) normalized['user_id'] = normalized['user'].toString();
    if (normalized['plan'] != null) normalized['plan_id'] = normalized['plan'].toString();
    if (normalized.containsKey('timestamp') && !normalized.containsKey('date')) {
      normalized['date'] = normalized['timestamp'];
    }

    return normalized;
  }
}