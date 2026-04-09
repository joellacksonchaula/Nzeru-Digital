class CreditPayment {
  final String id;
  final String creditId;
  final double amountPaid;
  final DateTime paymentDate;
  final double remainingBalance;

  CreditPayment({
    required this.id,
    required this.creditId,
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

  factory CreditPayment.fromJson(Map<String, dynamic> json) {
    return CreditPayment(
      id: json['id'].toString(),
      creditId: (json['loan_id'] ?? json['loan']).toString(),
      amountPaid: _parseDouble(json['amount_paid']),
      paymentDate: DateTime.parse(json['payment_date'].toString()),
      remainingBalance: _parseDouble(json['remaining_balance']),
    );
  }

  Map<String, dynamic> toJson() => {
        'loan': creditId,
        'amount_paid': amountPaid,
      };
}
