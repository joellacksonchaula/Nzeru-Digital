class UserSettings {
  final String preferredTheme;
  final String preferredLanguage;
  final String preferredCurrency;
  final bool notificationsEnabled;
  final bool transactionAlerts;
  final bool twoFactorEnabled;
  final bool biometricLoginEnabled;
  final bool autoSaveEnabled;
  final String creditUsagePreference;
  final List<String> paymentMethods;
  final String appFeedback;
  final String? defaultSavingsPlanId;

  const UserSettings({
    this.preferredTheme = 'system',
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'MWK',
    this.notificationsEnabled = true,
    this.transactionAlerts = true,
    this.twoFactorEnabled = false,
    this.biometricLoginEnabled = false,
    this.autoSaveEnabled = false,
    this.creditUsagePreference = 'flexible',
    this.paymentMethods = const [],
    this.appFeedback = '',
    this.defaultSavingsPlanId,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      preferredTheme: json['preferred_theme']?.toString() ?? 'system',
      preferredLanguage: json['preferred_language']?.toString() ?? 'en',
      preferredCurrency: json['preferred_currency']?.toString() ?? 'MWK',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      transactionAlerts: json['transaction_alerts'] as bool? ?? true,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
      biometricLoginEnabled: json['biometric_login_enabled'] as bool? ?? false,
      autoSaveEnabled: json['auto_save_enabled'] as bool? ?? false,
      creditUsagePreference: json['credit_usage_preference']?.toString() ?? 'flexible',
      paymentMethods: (json['payment_methods'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      appFeedback: json['app_feedback']?.toString() ?? '',
      defaultSavingsPlanId: json['default_savings_plan_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'preferred_theme': preferredTheme,
        'preferred_language': preferredLanguage,
        'preferred_currency': preferredCurrency,
        'notifications_enabled': notificationsEnabled,
        'transaction_alerts': transactionAlerts,
        'two_factor_enabled': twoFactorEnabled,
        'biometric_login_enabled': biometricLoginEnabled,
        'auto_save_enabled': autoSaveEnabled,
        'credit_usage_preference': creditUsagePreference,
        'payment_methods': paymentMethods,
        'app_feedback': appFeedback,
        'default_savings_plan_id': defaultSavingsPlanId,
      };

  UserSettings copyWith({
    String? preferredTheme,
    String? preferredLanguage,
    String? preferredCurrency,
    bool? notificationsEnabled,
    bool? transactionAlerts,
    bool? twoFactorEnabled,
    bool? biometricLoginEnabled,
    bool? autoSaveEnabled,
    String? creditUsagePreference,
    List<String>? paymentMethods,
    String? appFeedback,
    String? defaultSavingsPlanId,
  }) {
    return UserSettings(
      preferredTheme: preferredTheme ?? this.preferredTheme,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      biometricLoginEnabled: biometricLoginEnabled ?? this.biometricLoginEnabled,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      creditUsagePreference: creditUsagePreference ?? this.creditUsagePreference,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      appFeedback: appFeedback ?? this.appFeedback,
      defaultSavingsPlanId: defaultSavingsPlanId ?? this.defaultSavingsPlanId,
    );
  }
}
