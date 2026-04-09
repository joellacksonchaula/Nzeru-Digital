import 'package:flutter/material.dart';

import '../models/credit.dart';
import '../models/credit_payment.dart';
import '../models/interest_distribution.dart';
import '../services/api_service.dart';

class CreditProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Credit> _credits = [];
  List<CreditPayment> _payments = [];
  List<InterestDistribution> _distributions = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _eligibility;

  List<Credit> get credits => _credits;
  List<CreditPayment> get payments => _payments;
  List<InterestDistribution> get distributions => _distributions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get eligibility => _eligibility;

  Credit? get activeCredit {
    for (final credit in _credits) {
      if (credit.status == CreditStatus.active ||
          credit.status == CreditStatus.approved) {
        return credit;
      }
    }
    return null;
  }

  double get totalRepaid =>
      _payments.fold(0.0, (sum, payment) => sum + payment.amountPaid);

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final creditsData = await _api.getCredits();
      _credits = creditsData
          .map((json) => Credit.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();

      final paymentsData = await _api.getCreditPayments();
      _payments = paymentsData
          .map((json) => CreditPayment.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();

      final distData = await _api.getInterestDistributions();
      _distributions = distData
          .map((json) => InterestDistribution.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      _error = 'Failed to load credit data';
      _credits = [];
      _payments = [];
      _distributions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> checkEligibility({String? planId}) async {
    try {
      _eligibility = await _api.getCreditEligibility(planId: planId);
      notifyListeners();
      return _eligibility;
    } catch (e) {
      _error = 'Failed to check credit eligibility';
      notifyListeners();
      return null;
    }
  }

  Future<bool> requestCredit(Credit credit) async {
    try {
      await _api.requestCredit(credit.toJson());
      await loadData();
      await checkEligibility(planId: credit.planId);
      return true;
    } catch (e) {
      _error = 'Failed to request credit';
      notifyListeners();
      return false;
    }
  }

  Future<bool> makePayment(CreditPayment payment) async {
    try {
      await _api.makeCreditPayment(payment.toJson());
      await loadData();
      return true;
    } catch (e) {
      _error = 'Failed to record payment';
      notifyListeners();
      return false;
    }
  }
}
