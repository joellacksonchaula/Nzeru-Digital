class IjcMember {
  final int id;
  final String userName;
  final String role;
  final String status;
  final double totalContributed;

  const IjcMember({
    required this.id,
    required this.userName,
    required this.role,
    required this.status,
    required this.totalContributed,
  });

  factory IjcMember.fromJson(Map<String, dynamic> json) {
    return IjcMember(
      id: _parseInt(json['id']),
      userName: (json['user_name'] ?? '').toString(),
      role: (json['role'] ?? 'MEMBER').toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      totalContributed: _parseDouble(json['total_contributed']),
    );
  }
}

class IjcTransaction {
  final int id;
  final String userName;
  final double amount;
  final String type;
  final String description;
  final DateTime createdAt;

  const IjcTransaction({
    required this.id,
    required this.userName,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  bool get isDeposit => type == 'DEPOSIT';

  factory IjcTransaction.fromJson(Map<String, dynamic> json) {
    return IjcTransaction(
      id: _parseInt(json['id']),
      userName: (json['user_name'] ?? '').toString(),
      amount: _parseDouble(json['amount']),
      type: (json['type'] ?? 'DEPOSIT').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class IjcGroup {
  final int id;
  final String name;
  final String ijcId;
  final String joinCode;
  final String pocketType;
  final String ownerName;
  final String controllerName;
  final double goalAmount;
  final double totalAmount;
  final double releaseAmount;
  final bool isPaused;
  final double balance;
  final double availableBalance;
  final double lockedBalance;
  final double releasedBalance;
  final String cashOutPolicy;
  final double dailyLimit;
  final double weeklyLimit;
  final double monthlyLimit;
  final String resetType;
  final bool allowRollover;
  final double dailySpent;
  final double weeklySpent;
  final double monthlySpent;
  final double availableToday;
  final DateTime? nextDailyResetAt;
  final DateTime? nextCashOutDate;
  final DateTime? nextReleaseDate;
  final bool cashOutAvailable;
  final int daysUntilCashOut;
  final double progressPercent;
  final int memberCount;
  final String? currentUserRole;
  final String? currentUserStatus;
  final List<IjcMember> members;
  final List<IjcTransaction> transactions;

  const IjcGroup({
    required this.id,
    required this.name,
    required this.ijcId,
    required this.joinCode,
    required this.pocketType,
    required this.ownerName,
    required this.controllerName,
    required this.goalAmount,
    required this.totalAmount,
    required this.releaseAmount,
    required this.isPaused,
    required this.balance,
    required this.availableBalance,
    required this.lockedBalance,
    required this.releasedBalance,
    required this.cashOutPolicy,
    required this.dailyLimit,
    required this.weeklyLimit,
    required this.monthlyLimit,
    required this.resetType,
    required this.allowRollover,
    required this.dailySpent,
    required this.weeklySpent,
    required this.monthlySpent,
    required this.availableToday,
    required this.nextDailyResetAt,
    required this.nextCashOutDate,
    required this.nextReleaseDate,
    required this.cashOutAvailable,
    required this.daysUntilCashOut,
    required this.progressPercent,
    required this.memberCount,
    required this.currentUserRole,
    required this.currentUserStatus,
    required this.members,
    required this.transactions,
  });

  bool get isController => currentUserRole == 'CONTROLLER';
  bool get isUser => currentUserRole == 'USER' || currentUserRole == 'OWNER';
  bool get canWithdraw => isUser && isApproved && availableBalance > 0 && !isPaused;
  bool get isOwner => isController;
  bool get isApproved => currentUserStatus == 'APPROVED';
  double get effectiveTotalAmount => totalAmount > 0 ? totalAmount : goalAmount;
  double get dailyRemaining =>
      dailyLimit <= 0 ? availableBalance : (dailyLimit - dailySpent).clamp(0, availableBalance).toDouble();

  factory IjcGroup.fromJson(Map<String, dynamic> json) {
    return IjcGroup(
      id: _parseInt(json['id']),
      name: (json['name'] ?? 'Joint Savings').toString(),
      ijcId: (json['ijc_id'] ?? '').toString(),
      joinCode: (json['join_code'] ?? '').toString(),
      pocketType: (json['pocket_type'] ?? 'SPONSORED').toString(),
      ownerName: (json['owner_name'] ?? '').toString(),
      controllerName: (json['controller_name'] ?? '').toString(),
      goalAmount: _parseDouble(json['goal_amount']),
      totalAmount: _parseDouble(json['total_amount']),
      releaseAmount: _parseDouble(json['release_amount']),
      isPaused: json['is_paused'] == true,
      balance: _parseDouble(json['balance']),
      availableBalance: _parseDouble(json['available_balance']),
      lockedBalance: _parseDouble(json['locked_balance']),
      releasedBalance: _parseDouble(json['released_balance']),
      cashOutPolicy: (json['cash_out_policy'] ?? 'WEEKLY').toString(),
      dailyLimit: _parseDouble(json['daily_limit']),
      weeklyLimit: _parseDouble(json['weekly_limit']),
      monthlyLimit: _parseDouble(json['monthly_limit']),
      resetType: (json['reset_type'] ?? 'MIDNIGHT').toString(),
      allowRollover: json['allow_rollover'] == true,
      dailySpent: _parseDouble(json['daily_spent']),
      weeklySpent: _parseDouble(json['weekly_spent']),
      monthlySpent: _parseDouble(json['monthly_spent']),
      availableToday: _parseDouble(json['available_today']),
      nextDailyResetAt:
          DateTime.tryParse((json['next_daily_reset_at'] ?? '').toString()),
      nextCashOutDate:
          DateTime.tryParse((json['next_cash_out_date'] ?? '').toString()),
      nextReleaseDate:
          DateTime.tryParse((json['next_release_date'] ?? '').toString()),
      cashOutAvailable: json['cash_out_available'] == true,
      daysUntilCashOut: _parseInt(json['days_until_cash_out']),
      progressPercent: _parseDouble(json['progress_percent']) / 100,
      memberCount: _parseInt(json['member_count']),
      currentUserRole: json['current_user_role']?.toString(),
      currentUserStatus: json['current_user_status']?.toString(),
      members: (json['members'] as List? ?? const [])
          .map((item) => IjcMember.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      transactions: (json['transactions'] as List? ?? const [])
          .map((item) => IjcTransaction.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}
