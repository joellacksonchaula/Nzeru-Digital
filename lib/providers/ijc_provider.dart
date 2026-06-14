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
      _error = 'Failed to load credit accounts: $e';
      _groups = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createGroup({
    required String name,
    required String pocketType,
    double? totalAmount,
    double? releaseAmount,
    String? cashOutPolicy,
    int? customIntervalDays,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'pocket_type': pocketType,
      };
      if (totalAmount != null) {
        body['total_amount'] = totalAmount.toStringAsFixed(2);
      }
      if (releaseAmount != null) {
        body['release_amount'] = releaseAmount.toStringAsFixed(2);
      }
      if (cashOutPolicy != null) {
        body['cash_out_policy'] = cashOutPolicy;
      }
      if (customIntervalDays != null) {
        body['custom_interval_days'] = customIntervalDays;
      }
      await _api.createIjcGroup(body);
      await loadGroups();
      return true;
    } catch (e) {
      _error = 'Failed to create pocket: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinGroup(
    String code, {
    double? totalAmount,
    double? releaseAmount,
    String? cashOutPolicy,
    int? customIntervalDays,
  }) async {
    try {
      final body = <String, dynamic>{'code': code};
      if (totalAmount != null) {
        body['total_amount'] = totalAmount.toStringAsFixed(2);
      }
      if (releaseAmount != null) {
        body['release_amount'] = releaseAmount.toStringAsFixed(2);
      }
      if (cashOutPolicy != null) {
        body['cash_out_policy'] = cashOutPolicy;
      }
      if (customIntervalDays != null) {
        body['custom_interval_days'] = customIntervalDays;
      }
      await _api.joinIjcGroup(body);
      await loadGroups();
      return true;
    } catch (e) {
      _error = 'Failed to join pocket: $e';
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
