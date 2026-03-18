class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double savingsBalance;
  final double loanBalance;
  final int financialScore;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.savingsBalance = 0,
    this.loanBalance = 0,
    this.financialScore = 0,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      savingsBalance: double.tryParse(json['savings_balance']?.toString() ?? '') ?? 0.0,
      loanBalance: double.tryParse(json['loan_balance']?.toString() ?? '') ?? 0.0,
      financialScore: int.tryParse(json['financial_score']?.toString() ?? '') ?? 0,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'savings_balance': savingsBalance,
        'loan_balance': loanBalance,
        'financial_score': financialScore,
        'avatar_url': avatarUrl,
      };

  User copyWith({
    String? name,
    String? email,
    String? phone,
    double? savingsBalance,
    double? loanBalance,
    int? financialScore,
    String? avatarUrl,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      savingsBalance: savingsBalance ?? this.savingsBalance,
      loanBalance: loanBalance ?? this.loanBalance,
      financialScore: financialScore ?? this.financialScore,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
