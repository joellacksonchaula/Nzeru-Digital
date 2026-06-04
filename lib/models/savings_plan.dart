enum PlanFrequency { daily, weekly, biweekly, monthly }

enum PenaltyPolicy { monetaryDeduction, appRestriction, both }

enum PlanHealth { onTrack, watch, behind }

class SavingsPlan {
  final String id;
  final String userId;
  final String title;
  final double amountPerPeriod;
  final PlanFrequency frequency;
  final int durationMonths;
  final DateTime startDate;
  final DateTime endDate;
  final PenaltyPolicy penaltyPolicy;
  final double goalAmount;
  final double currentAmount;
  final bool isActive;
  final bool isSecret;
  final bool isTrial;
  final DateTime? createdAt;

  SavingsPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.amountPerPeriod,
    required this.frequency,
    required this.durationMonths,
    required this.startDate,
    required this.endDate,
    required this.penaltyPolicy,
    this.goalAmount = 0,
    this.currentAmount = 0,
    this.isActive = true,
    this.isSecret = false,
    this.isTrial = false,
    this.createdAt,
  });

  double get progressPercent =>
      goalAmount > 0 ? (currentAmount / goalAmount).clamp(0, 1) : 0;

  double get remainingAmount => (goalAmount - currentAmount).clamp(0, goalAmount);

  int get totalDurationDays {
    final days = endDate.difference(startDate).inDays;
    return days <= 0 ? 1 : days;
  }

  int get elapsedDays {
    final raw = DateTime.now().difference(startDate).inDays + 1;
    if (raw <= 0) return 0;
    if (raw >= totalDurationDays) return totalDurationDays;
    return raw;
  }

  int get remainingDays {
    final raw = endDate.difference(DateTime.now()).inDays;
    return raw <= 0 ? 1 : raw;
  }

  bool get isMature =>
      DateTime.now().isAfter(endDate) || DateTime.now().isAtSameMomentAs(endDate);

  int get daysUntilMaturity {
    final raw = endDate.difference(DateTime.now()).inDays;
    return raw <= 0 ? 0 : raw;
  }

  double get expectedProgressNow {
    if (totalDurationDays <= 0) return 0;
    return (elapsedDays / totalDurationDays).clamp(0, 1);
  }

  double get requiredPerDay => remainingAmount <= 0 ? 0 : remainingAmount / remainingDays;

  double get requiredPerWeek {
    if (remainingAmount <= 0) return 0;
    final weeks = (remainingDays / 7).ceil();
    return remainingAmount / (weeks <= 0 ? 1 : weeks);
  }

  double get requiredPerMonth {
    if (remainingAmount <= 0) return 0;
    final months = (remainingDays / 30).ceil();
    return remainingAmount / (months <= 0 ? 1 : months);
  }

  DateTime get estimatedCompletionDate {
    if (progressPercent >= 1) return DateTime.now();
    if (currentAmount <= 0 || elapsedDays <= 0) return endDate;

    final savedPerDay = currentAmount / elapsedDays;
    if (savedPerDay <= 0) return endDate;

    final daysNeeded = (remainingAmount / savedPerDay).ceil();
    return DateTime.now().add(Duration(days: daysNeeded));
  }

  PlanHealth get health {
    if (progressPercent >= 1) return PlanHealth.onTrack;

    final delta = progressPercent - expectedProgressNow;
    if (delta >= -0.08) return PlanHealth.onTrack;
    if (delta >= -0.2) return PlanHealth.watch;
    return PlanHealth.behind;
  }

  bool get isEstimatedToFinishOnTime =>
      estimatedCompletionDate.isBefore(endDate) ||
      estimatedCompletionDate.isAtSameMomentAs(endDate);

  String get frequencyLabel {
    switch (frequency) {
      case PlanFrequency.daily:
        return 'Daily';
      case PlanFrequency.weekly:
        return 'Weekly';
      case PlanFrequency.biweekly:
        return 'Bi-Weekly';
      case PlanFrequency.monthly:
        return 'Monthly';
    }
  }

  // ─── Frequency helpers ─────────────────────────────────────────

  /// Maps Dart enum to the backend string code expected by Django.
  static String frequencyToApiString(PlanFrequency f) {
    switch (f) {
      case PlanFrequency.daily:
        return 'DAILY';
      case PlanFrequency.weekly:
        return 'WEEKLY';
      case PlanFrequency.biweekly:
        return 'BIWEEKLY';
      case PlanFrequency.monthly:
        return 'MONTHLY';
    }
  }

  /// Maps a backend string code to the Dart enum.
  static PlanFrequency frequencyFromApiString(String s) {
    switch (s.toUpperCase()) {
      case 'DAILY':
        return PlanFrequency.daily;
      case 'WEEKLY':
        return PlanFrequency.weekly;
      case 'BIWEEKLY':
        return PlanFrequency.biweekly;
      case 'MONTHLY':
        return PlanFrequency.monthly;
      default:
        return PlanFrequency.weekly;
    }
  }

  // ─── Penalty policy helpers ─────────────────────────────────────

  /// Maps Dart enum to the backend string code expected by Django.
  /// Backend choices: MONETARY, RESTRICTION, BOTH
  static String penaltyToApiString(PenaltyPolicy p) {
    switch (p) {
      case PenaltyPolicy.monetaryDeduction:
        return 'MONETARY';
      case PenaltyPolicy.appRestriction:
        return 'RESTRICTION';
      case PenaltyPolicy.both:
        return 'BOTH';
    }
  }

  /// Maps a backend string code to the Dart enum.
  static PenaltyPolicy penaltyFromApiString(String s) {
    switch (s.toUpperCase()) {
      case 'MONETARY':
        return PenaltyPolicy.monetaryDeduction;
      case 'RESTRICTION':
        return PenaltyPolicy.appRestriction;
      case 'BOTH':
        return PenaltyPolicy.both;
      default:
        return PenaltyPolicy.monetaryDeduction;
    }
  }

  // ─── Internal helpers ──────────────────────────────────────────

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _formatMoney(double value) => value.toStringAsFixed(2);

  // ─── Serialization ─────────────────────────────────────────────

  factory SavingsPlan.fromJson(Map<String, dynamic> json) {
    return SavingsPlan(
      id: json['id'].toString(),
      userId: (json['user_id'] ?? json['user'] ?? '').toString(),
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Savings Plan',
      amountPerPeriod: _parseDouble(json['amount_per_period']),
      // Backend returns string codes — parse them via the helper
      frequency: frequencyFromApiString(json['frequency'] as String? ?? 'WEEKLY'),
      durationMonths: json['duration_months'] as int? ?? 12,
      startDate: DateTime.parse(json['start_date'] as String? ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] as String? ?? DateTime.now().toIso8601String()),
      // Backend returns string codes — parse them via the helper
      penaltyPolicy: penaltyFromApiString(json['penalty_policy'] as String? ?? 'MONETARY'),
      goalAmount: _parseDouble(json['goal_amount']),
      currentAmount: _parseDouble(json['current_amount']),
      isActive: json['is_active'] as bool? ?? true,
      isSecret: json['is_secret'] as bool? ?? false,
      isTrial: json['is_trial'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount_per_period': _formatMoney(amountPerPeriod),
        'frequency': frequencyToApiString(frequency),
        'duration_months': durationMonths,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'penalty_policy': penaltyToApiString(penaltyPolicy),
        'goal_amount': _formatMoney(goalAmount),
        'current_amount': _formatMoney(currentAmount),
        'is_secret': isSecret,
        'is_trial': isTrial,
      };
}
