import 'user_settings.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double savingsBalance;
  final double creditBalance;
  final double trackedSavingsBalance;
  final int financialScore;
  final String? avatarUrl;
  final UserSettings settings;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.savingsBalance = 0,
    this.creditBalance = 0,
    this.trackedSavingsBalance = 0,
    this.financialScore = 0,
    this.avatarUrl,
    this.settings = const UserSettings(),
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      savingsBalance: double.tryParse(json['savings_balance']?.toString() ?? '') ?? 0.0,
      creditBalance: double.tryParse(
            (json['credit_balance'] ?? json['loan_balance'])?.toString() ?? '',
          ) ??
          0.0,
      trackedSavingsBalance: double.tryParse(
            (json['tracked_savings_balance'] ?? json['savings_balance'])?.toString() ?? '',
          ) ??
          0.0,
      financialScore: int.tryParse(json['financial_score']?.toString() ?? '') ?? 0,
      avatarUrl: json['avatar_url']?.toString(),
      settings: UserSettings.fromJson(json['settings'] as Map<String, dynamic>? ?? const {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'savings_balance': savingsBalance,
        'credit_balance': creditBalance,
        'tracked_savings_balance': trackedSavingsBalance,
        'financial_score': financialScore,
        'avatar_url': avatarUrl,
        'settings': settings.toJson(),
      };

  User copyWith({
    String? name,
    String? email,
    String? phone,
    double? savingsBalance,
    double? creditBalance,
    double? trackedSavingsBalance,
    int? financialScore,
    String? avatarUrl,
    UserSettings? settings,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      savingsBalance: savingsBalance ?? this.savingsBalance,
      creditBalance: creditBalance ?? this.creditBalance,
      trackedSavingsBalance: trackedSavingsBalance ?? this.trackedSavingsBalance,
      financialScore: financialScore ?? this.financialScore,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      settings: settings ?? this.settings,
    );
  }
}
