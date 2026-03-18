class LoanPayment {
  final String id;
  final String loanId;
  final double amountPaid;
  final DateTime paymentDate;
  final double remainingBalance;

  LoanPayment({
    required this.id,
    required this.loanId,
    required this.amountPaid,
    required this.paymentDate,
    required this.remainingBalance,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory LoanPayment.fromJson(Map<String, dynamic> json) {
    return LoanPayment(
      id: json['id'] as String,
      loanId: json['loan_id'] as String,
      amountPaid: _parseDouble(json['amount_paid']),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      remainingBalance: _parseDouble(json['remaining_balance']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'loan_id': loanId,
        'amount_paid': amountPaid,
        'payment_date': paymentDate.toIso8601String(),
        'remaining_balance': remainingBalance,
      };
}
