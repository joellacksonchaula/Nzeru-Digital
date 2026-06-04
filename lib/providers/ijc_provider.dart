import 'package:flutter/material.dart';

import '../models/ijc_group.dart';
import '../services/api_service.dart';

class IjcProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<IjcGroup> _groups = [];
  bool _isLoading = false;
  String? _error;

  List<IjcGroup> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.getIjcGroups();
      _groups = data
          .map((json) => IjcGroup.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      _error = 'Failed to load joint savings: $e';
      _groups = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createGroup({
    required String name,
    required double goalAmount,
    required String cashOutPolicy,
  }) async {
    try {
      await _api.createIjcGroup({
        'name': name,
        'goal_amount': goalAmount.toStringAsFixed(2),
        'cash_out_policy': cashOutPolicy,
      });
      await loadGroups();
      return true;
    } catch (e) {
      _error = 'Failed to create IJC: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinGroup(String code) async {
    try {
      await _api.joinIjcGroup(code);
      await loadGroups();
      return true;
    } catch (e) {
      _error = 'Failed to join IJC: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveMember({
    required int groupId,
    required int memberId,
  }) async {
    try {
      await _api.approveIjcMember(groupId: groupId, memberId: memberId);
      await loadGroups();
      return true;
    } catch (e) {
      _error = 'Failed to approve member: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deposit({
    required int groupId,
    required double amount,
    String description = '',
  }) async {
    try {
      await _api.depositIjc(
        groupId: groupId,
        amount: amount,
        description: description,
      );
      await loadGroups();
      return true;
    } catch (e) {
      _error = 'Failed to deposit into IJC: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> withdraw({
    required int groupId,
    required double amount,
    String description = '',
  }) async {
    try {
      await _api.withdrawIjc(
        groupId: groupId,
        amount: amount,
        description: description,
      );
      await loadGroups();
      return true;
    } catch (e) {
      _error = 'Failed to withdraw from IJC: $e';
      notifyListeners();
      return false;
    }
  }
}
