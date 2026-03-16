enum TransactionType { deposit, penaltyDeduction, interestReward, withdrawal }

enum TransactionStatus { pending, completed, failed }

class SavingsTransaction {
  final String id;
  final String userId;
  final String? planId;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;
  final String? description;

  SavingsTransaction({
    required this.id,
    required this.userId,
    this.planId,
    required this.amount,
    required this.date,
    required this.type,
    this.status = TransactionStatus.completed,
    this.description,
  });

  String get typeLabel {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.penaltyDeduction:
        return 'Penalty';
      case TransactionType.interestReward:
        return 'Interest';
      case TransactionType.withdrawal:
        return 'Withdrawal';
    }
  }

  bool get isCredit =>
      type == TransactionType.deposit ||
      type == TransactionType.interestReward;

  // ─── Type mapping helpers ──────────────────────────────────────────

  static String typeToApiString(TransactionType t) {
    switch (t) {
      case TransactionType.deposit: return 'DEPOSIT';
      case TransactionType.penaltyDeduction: return 'PENALTY';
      case TransactionType.interestReward: return 'INTEREST';
      case TransactionType.withdrawal: return 'WITHDRAWAL';
    }
  }

  static TransactionType typeFromApiString(String s) {
    switch (s.toUpperCase()) {
      case 'DEPOSIT': return TransactionType.deposit;
      case 'PENALTY': return TransactionType.penaltyDeduction;
      case 'INTEREST': return TransactionType.interestReward;
      case 'WITHDRAWAL': return TransactionType.withdrawal;
      default: return TransactionType.deposit;
    }
  }

  // ─── Status mapping helpers ────────────────────────────────────────

  static String statusToApiString(TransactionStatus s) {
    switch (s) {
      case TransactionStatus.pending: return 'PENDING';
      case TransactionStatus.completed: return 'COMPLETED';
      case TransactionStatus.failed: return 'FAILED';
    }
  }

  static TransactionStatus statusFromApiString(String s) {
    switch (s.toUpperCase()) {
      case 'PENDING': return TransactionStatus.pending;
      case 'COMPLETED': return TransactionStatus.completed;
      case 'FAILED': return TransactionStatus.failed;
      default: return TransactionStatus.completed;
    }
  }

  // ─── Internal helpers ──────────────────────────────────────────

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ─── Serialization ─────────────────────────────────────────────

  factory SavingsTransaction.fromJson(Map<String, dynamic> json) {
    return SavingsTransaction(
      id: json['id'].toString(),
      userId: (json['user_id'] ?? json['user'] ?? '').toString(),
      planId: json['plan_id']?.toString() ?? json['plan']?.toString(),
      amount: _parseDouble(json['amount']),
      date: DateTime.parse(json['date'] as String? ?? json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
      type: typeFromApiString(json['type'] as String? ?? 'DEPOSIT'),
      status: statusFromApiString(json['status'] as String? ?? 'COMPLETED'),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date.toIso8601String(),
        'type': typeToApiString(type),
        'status': statusToApiString(status),
        'description': description,
        'plan': planId,
      };
}
