class InterestDistribution {
  final String loanId;
  final double totalInterest;
  final double userSavingsShare;
  final double platformShare;

  InterestDistribution({
    required this.loanId,
    required this.totalInterest,
    required this.userSavingsShare,
    required this.platformShare,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory InterestDistribution.fromJson(Map<String, dynamic> json) {
    return InterestDistribution(
      loanId: json['loan_id'] as String,
      totalInterest: _parseDouble(json['total_interest']),
      userSavingsShare: _parseDouble(json['user_savings_share']),
      platformShare: _parseDouble(json['platform_share']),
    );
  }

  Map<String, dynamic> toJson() => {
        'loan_id': loanId,
        'total_interest': totalInterest,
        'user_savings_share': userSavingsShare,
        'platform_share': platformShare,
      };
}
