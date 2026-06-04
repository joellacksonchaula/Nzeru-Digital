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
  final String ownerName;
  final double goalAmount;
  final double balance;
  final String cashOutPolicy;
  final DateTime? nextCashOutDate;
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
    required this.ownerName,
    required this.goalAmount,
    required this.balance,
    required this.cashOutPolicy,
    required this.nextCashOutDate,
    required this.cashOutAvailable,
    required this.daysUntilCashOut,
    required this.progressPercent,
    required this.memberCount,
    required this.currentUserRole,
    required this.currentUserStatus,
    required this.members,
    required this.transactions,
  });

  bool get isOwner => currentUserRole == 'OWNER';
  bool get isApproved => currentUserStatus == 'APPROVED';

  factory IjcGroup.fromJson(Map<String, dynamic> json) {
    return IjcGroup(
      id: _parseInt(json['id']),
      name: (json['name'] ?? 'Joint Savings').toString(),
      ijcId: (json['ijc_id'] ?? '').toString(),
      joinCode: (json['join_code'] ?? '').toString(),
      ownerName: (json['owner_name'] ?? '').toString(),
      goalAmount: _parseDouble(json['goal_amount']),
      balance: _parseDouble(json['balance']),
      cashOutPolicy: (json['cash_out_policy'] ?? 'WEEKLY').toString(),
      nextCashOutDate:
          DateTime.tryParse((json['next_cash_out_date'] ?? '').toString()),
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
