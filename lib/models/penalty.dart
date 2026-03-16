class Penalty {
  final String id;
  final String userId;
  final String? planId;
  final double amount;
  final String reason;
  final DateTime date;
  final bool isApplied;

  Penalty({
    required this.id,
    required this.userId,
    this.planId,
    required this.amount,
    required this.reason,
    required this.date,
    this.isApplied = true,
  });

  // ─── Internal helpers ──────────────────────────────────────────

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ─── Serialization ─────────────────────────────────────────────

  factory Penalty.fromJson(Map<String, dynamic> json) {
    return Penalty(
      id: json['id'].toString(),
      userId: (json['user_id'] ?? json['user'] ?? '').toString(),
      planId: json['plan_id']?.toString() ?? json['plan']?.toString(),
      amount: _parseDouble(json['amount']),
      reason: json['reason'] as String? ?? 'Penalty applied',
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
      isApplied: json['is_applied'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'reason': reason,
        'date': date.toIso8601String(),
        'is_applied': isApplied,
        'plan': planId,
      };
}
