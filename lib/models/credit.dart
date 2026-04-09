enum CreditStatus { pending, approved, active, repaid, defaulted, rejected }

enum CreditWithdrawalMode { instant, daily, weekly }

class Credit {
  final String id;
  final String userId;
  final String? planId;
  final double amount;
  final double interestRate;
  final int durationMonths;
  final CreditStatus status;
  final CreditWithdrawalMode withdrawalMode;
  final double lockedAmount;
  final DateTime? approvedDate;
  final DateTime? dueDate;
  final double remainingBalance;
  final double totalRepaid;
  final bool isTrial;

  Credit({
    required this.id,
    required this.userId,
    this.planId,
    required this.amount,
    this.interestRate = 10.0,
    required this.durationMonths,
    this.status = CreditStatus.pending,
    this.withdrawalMode = CreditWithdrawalMode.instant,
    this.lockedAmount = 0,
    this.approvedDate,
    this.dueDate,
    this.remainingBalance = 0,
    this.totalRepaid = 0,
    this.isTrial = false,
  });

  double get totalWithInterest => amount * (1 + interestRate / 100);

  double get suggestedRepayment =>
      durationMonths > 0 ? totalWithInterest / durationMonths : totalWithInterest;

  double get repaymentProgress =>
      totalWithInterest > 0 ? ((totalWithInterest - remainingBalance) / totalWithInterest).clamp(0, 1) : 0;

  String get statusLabel {
    switch (status) {
      case CreditStatus.pending:
        return 'Pending';
      case CreditStatus.approved:
        return 'Approved';
      case CreditStatus.active:
        return 'Active';
      case CreditStatus.repaid:
        return 'Repaid';
      case CreditStatus.defaulted:
        return 'Defaulted';
      case CreditStatus.rejected:
        return 'Rejected';
    }
  }

  String get withdrawalModeLabel {
    switch (withdrawalMode) {
      case CreditWithdrawalMode.instant:
        return 'All at once';
      case CreditWithdrawalMode.daily:
        return 'Daily locked';
      case CreditWithdrawalMode.weekly:
        return 'Weekly locked';
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static CreditStatus statusFromApiString(String s) {
    switch (s.toUpperCase()) {
      case 'APPROVED':
        return CreditStatus.approved;
      case 'ACTIVE':
        return CreditStatus.active;
      case 'PAID':
      case 'REPAID':
        return CreditStatus.repaid;
      case 'DEFAULTED':
        return CreditStatus.defaulted;
      case 'REJECTED':
        return CreditStatus.rejected;
      default:
        return CreditStatus.pending;
    }
  }

  static CreditWithdrawalMode withdrawalModeFromApiString(String s) {
    switch (s.toUpperCase()) {
      case 'DAILY':
        return CreditWithdrawalMode.daily;
      case 'WEEKLY':
        return CreditWithdrawalMode.weekly;
      default:
        return CreditWithdrawalMode.instant;
    }
  }

  static String withdrawalModeToApiString(CreditWithdrawalMode mode) {
    switch (mode) {
      case CreditWithdrawalMode.daily:
        return 'DAILY';
      case CreditWithdrawalMode.weekly:
        return 'WEEKLY';
      case CreditWithdrawalMode.instant:
        return 'INSTANT';
    }
  }

  factory Credit.fromJson(Map<String, dynamic> json) {
    final amount = _parseDouble(json['amount']);
    final interestRate = _parseDouble(json['interest_rate'] ?? 10);
    final totalWithInterest = _parseDouble(json['total_with_interest']);
    final hasRemainingBalance = json.containsKey('remaining_balance');
    final remaining = _parseDouble(json['remaining_balance']);
    final effectiveRemaining =
        hasRemainingBalance ? remaining : (totalWithInterest > 0 ? totalWithInterest : remaining);

    return Credit(
      id: json['id'].toString(),
      userId: (json['user_id'] ?? json['user'] ?? '').toString(),
      planId: json['plan']?.toString() ?? json['plan_id']?.toString(),
      amount: amount,
      interestRate: interestRate,
      durationMonths: json['duration_months'] as int? ?? 1,
      status: statusFromApiString(json['status']?.toString() ?? 'PENDING'),
      withdrawalMode: withdrawalModeFromApiString(
        json['withdrawal_mode']?.toString() ?? 'INSTANT',
      ),
      lockedAmount: _parseDouble(json['locked_amount']),
      approvedDate: json['approved_date'] != null
          ? DateTime.tryParse(json['approved_date'].toString())
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      remainingBalance: effectiveRemaining,
      totalRepaid: totalWithInterest > 0
          ? (totalWithInterest - effectiveRemaining)
              .clamp(0, totalWithInterest)
              .toDouble()
          : _parseDouble(json['total_repaid']),
      isTrial: json['is_trial'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'interest_rate': interestRate,
        'duration_months': durationMonths,
        'plan': planId,
        'withdrawal_mode': withdrawalModeToApiString(withdrawalMode),
        'locked_amount': lockedAmount,
        'due_date': dueDate?.toIso8601String(),
      };
}
