import 'package:flutter/material.dart';

import '../models/penalty.dart';
import '../models/savings_plan.dart';
import '../models/savings_transaction.dart';
import '../services/api_service.dart';

class SavingsProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<SavingsPlan> _plans = [];
  List<SavingsTransaction> _transactions = [];
  List<Penalty> _penalties = [];
  bool _isLoading = false;
  String? _error;

  List<SavingsPlan> get plans => _plans;
  List<SavingsPlan> get activePlans =>
      _plans.where((plan) => plan.isActive && !plan.isSecret).toList();
  List<SavingsPlan> get secretPlans =>
      _plans.where((plan) => plan.isActive && plan.isSecret).toList();
  List<SavingsTransaction> get transactions => _transactions;
  List<Penalty> get penalties => _penalties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalPenalties => _penalties
      .where((penalty) => penalty.isApplied)
      .fold(0.0, (sum, penalty) => sum + penalty.amount);

  double get secretSavingsTotal =>
      secretPlans.fold(0.0, (sum, plan) => sum + plan.currentAmount);

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final plansData = await _api.getSavingsPlans();
      _plans = plansData
          .map(
            (json) => SavingsPlan.fromJson(
              _normalizeKeys(Map<String, dynamic>.from(json as Map)),
            ),
          )
          .toList();

      final txnData = await _api.getTransactions();
      _transactions = txnData
          .map(
            (json) => SavingsTransaction.fromJson(
              _normalizeKeys(Map<String, dynamic>.from(json as Map)),
            ),
          )
          .toList();

      final penData = await _api.getPenalties();
      _penalties = penData
          .map(
            (json) => Penalty.fromJson(
              _normalizeKeys(Map<String, dynamic>.from(json as Map)),
            ),
          )
          .toList();
    } catch (e) {
      _error = 'Failed to load savings data: $e';
      debugPrint('SavingsProvider.loadData error: $e');
      _plans = [];
      _transactions = [];
      _penalties = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<SavingsPlan?> addPlan(SavingsPlan plan) async {
    try {
      final created = await _api.createSavingsPlan(plan.toJson());
      await loadData();
      return SavingsPlan.fromJson(_normalizeKeys(created));
    } catch (e) {
      _error = 'Failed to create savings plan: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> addDeposit(SavingsTransaction transaction) async {
    try {
      await _api.createTransaction({
        'amount': transaction.amount,
        'type': 'DEPOSIT',
        'status': 'COMPLETED',
        'plan': transaction.planId,
        'description': transaction.description ?? 'Savings deposit',
      });
      await loadData();
      return true;
    } catch (e) {
      _error = 'Failed to record deposit: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addWithdrawal(SavingsTransaction transaction) async {
    try {
      await _api.createTransaction({
        'amount': transaction.amount,
        'type': 'WITHDRAWAL',
        'status': 'COMPLETED',
        'plan': transaction.planId,
        'description': transaction.description ?? 'Savings withdrawal',
      });
      await loadData();
      return true;
    } catch (e) {
      _error = 'Failed to record withdrawal: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> simulateTrialPenalty({
    required String planId,
    double amount = 250,
    String reason = 'Simulated penalty for testing.',
  }) async {
    try {
      await _api.simulatePenalty(
        planId: planId,
        amount: amount,
        reason: reason,
      );
      await loadData();
      return true;
    } catch (e) {
      _error = 'Failed to simulate penalty: $e';
      notifyListeners();
      return false;
    }
  }

  Map<String, dynamic> _normalizeKeys(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    if (normalized['id'] != null)
      normalized['id'] = normalized['id'].toString();
    if (normalized['user'] != null) {
      normalized['user_id'] = normalized['user'].toString();
    }
    if (normalized['plan'] != null) {
      normalized['plan_id'] = normalized['plan'].toString();
    }
    if (normalized.containsKey('timestamp') &&
        !normalized.containsKey('date')) {
      normalized['date'] = normalized['timestamp'];
    }

    return normalized;
  }
}
