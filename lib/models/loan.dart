enum LoanStatus { pending, approved, active, repaid, defaulted }

class Loan {
  final String id;
  final String userId;
  final double amount;
  final double interestRate;
  final int durationMonths;
  final LoanStatus status;
  final DateTime? approvedDate;
  final DateTime? dueDate;
  final double totalRepaid;

  Loan({
    required this.id,
    required this.userId,
    required this.amount,
    this.interestRate = 10.0,
    required this.durationMonths,
    this.status = LoanStatus.pending,
    this.approvedDate,
    this.dueDate,
    this.totalRepaid = 0,
  });

  double get totalWithInterest => amount * (1 + interestRate / 100);
  double get monthlyPayment => totalWithInterest / durationMonths;
  double get remainingBalance => totalWithInterest - totalRepaid;
  double get repaymentProgress =>
      totalWithInterest > 0 ? (totalRepaid / totalWithInterest).clamp(0, 1) : 0;

  String get statusLabel {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.repaid:
        return 'Repaid';
      case LoanStatus.defaulted:
        return 'Defaulted';
    }
  }

  // ─── Status mapping helpers ────────────────────────────────────────

  static String statusToApiString(LoanStatus s) {
    switch (s) {
      case LoanStatus.pending: return 'PENDING';
      case LoanStatus.approved: return 'APPROVED';
      case LoanStatus.active: return 'ACTIVE';
      case LoanStatus.repaid: return 'REPAID';
      case LoanStatus.defaulted: return 'DEFAULTED';
    }
  }

  static LoanStatus statusFromApiString(String s) {
    switch (s.toUpperCase()) {
      case 'PENDING': return LoanStatus.pending;
      case 'APPROVED': return LoanStatus.approved;
      case 'ACTIVE': return LoanStatus.active;
      case 'REPAID': return LoanStatus.repaid;
      case 'DEFAULTED': return LoanStatus.defaulted;
      default: return LoanStatus.pending;
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

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'].toString(),
      userId: (json['user_id'] ?? json['user'] ?? '').toString(),
      amount: _parseDouble(json['amount']),
      interestRate: _parseDouble(json['interest_rate'] ?? 10.0),
      durationMonths: json['duration_months'] as int? ?? 12,
      status: statusFromApiString(json['status'] as String? ?? 'PENDING'),
      approvedDate: json['approved_date'] != null
          ? DateTime.parse(json['approved_date'] as String)
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      totalRepaid: _parseDouble(json['total_repaid']),
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'interest_rate': interestRate,
        'duration_months': durationMonths,
        'status': statusToApiString(status),
        'approved_date': approvedDate?.toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
        'total_repaid': totalRepaid,
      };
}
