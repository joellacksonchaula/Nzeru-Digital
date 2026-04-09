import 'package:flutter/material.dart';

import '../models/credit.dart';
import '../models/savings_plan.dart';
import '../models/savings_transaction.dart';
import '../models/user.dart';
import 'auth_provider.dart';
import 'credit_provider.dart';
import 'savings_provider.dart';

class FinanceOverviewProvider with ChangeNotifier {
  User? _user;
  List<SavingsPlan> _plans = const [];
  List<SavingsTransaction> _transactions = const [];
  Credit? _activeCredit;
  double _totalPenalties = 0;
  double _totalRepaid = 0;

  User? get user => _user;
  List<SavingsPlan> get plans => _plans;
  List<SavingsTransaction> get transactions => _transactions;
  Credit? get activeCredit => _activeCredit;
  double get totalPenalties => _totalPenalties;
  double get totalRepaid => _totalRepaid;
  List<SavingsPlan> get trialPlans => _plans.where((plan) => plan.isTrial).toList();
  List<SavingsPlan> get livePlans => _plans.where((plan) => !plan.isTrial).toList();

  double get totalSaved =>
      _plans.fold(0.0, (sum, plan) => sum + plan.currentAmount);

  double get totalGoal =>
      _plans.fold(0.0, (sum, plan) => sum + plan.goalAmount);

  double get totalRemaining =>
      _plans.fold(0.0, (sum, plan) => sum + plan.remainingAmount);

  double get progress =>
      totalGoal > 0 ? (totalSaved / totalGoal).clamp(0, 1) : 0;

  double get totalDeposits => _transactions
      .where((txn) => txn.type == TransactionType.deposit)
      .fold(0.0, (sum, txn) => sum + txn.amount);

  double get totalWithdrawals => _transactions
      .where((txn) => txn.type == TransactionType.withdrawal)
      .fold(0.0, (sum, txn) => sum + txn.amount);

  double get interestEarned => _transactions
      .where((txn) => txn.type == TransactionType.interestReward)
      .fold(0.0, (sum, txn) => sum + txn.amount);

  double get monthlyCommitment =>
      _plans.fold(0.0, (sum, plan) => sum + plan.requiredPerMonth);

  double get weeklyCommitment =>
      _plans.fold(0.0, (sum, plan) => sum + plan.requiredPerWeek);

  int get onTrackPlans =>
      _plans.where((plan) => plan.health == PlanHealth.onTrack).length;

  int get watchPlans =>
      _plans.where((plan) => plan.health == PlanHealth.watch).length;

  int get behindPlans =>
      _plans.where((plan) => plan.health == PlanHealth.behind).length;

  List<SavingsPlan> get prioritizedPlans {
    final sorted = [..._plans];
    sorted.sort((a, b) {
      final endCompare = a.endDate.compareTo(b.endDate);
      if (endCompare != 0) return endCompare;
      return b.currentAmount.compareTo(a.currentAmount);
    });
    return sorted;
  }

  List<SavingsTransaction> get recentTransactions {
    final sorted = [..._transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(6).toList();
  }

  double get outstandingCredit => _activeCredit?.remainingBalance ?? 0;

  double get netWorth => totalSaved - outstandingCredit;

  void sync({
    required AuthProvider auth,
    required SavingsProvider savings,
    required CreditProvider credits,
  }) {
    _user = auth.user;
    _plans = savings.activePlans;
    _transactions = savings.transactions;
    _activeCredit = credits.activeCredit;
    _totalPenalties = savings.totalPenalties;
    _totalRepaid = credits.totalRepaid;
    notifyListeners();
  }
}
