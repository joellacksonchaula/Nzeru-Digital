import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.login(username: username, password: password);
      await _fetchCurrentUser();
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.statusCode == 401
          ? 'Invalid username or password'
          : 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.register(
        username: email,  // Use full email as username
        email: email,
        password: password,
        password2: password,
        firstName: name.split(' ').first,
        lastName: name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : '',
        phone: phone,
      );
      // Auto-login after registration
      await _api.login(
        username: email,  // Login with email as username
        password: password,
      );
      await _fetchCurrentUser();
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = 'Registration failed: ${e.body}';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final data = await _api.getCurrentUser();
      final userData = data['user'] ?? data;
      _user = User(
        id: userData['id']?.toString() ?? '',
        name: '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim(),
        email: userData['email'] ?? '',
        phone: data['phone'] ?? '',
        savingsBalance: (data['savings_balance'] as num?)?.toDouble() ?? 0,
        loanBalance: (data['loan_balance'] as num?)?.toDouble() ?? 0,
        financialScore: data['financial_score'] as int? ?? 0,
      );
    } catch (_) {
      // Profile may not exist yet—create minimal user
    }
  }

  Future<void> refreshProfile() async {
    try {
      final data = await _api.recalculateProfile();
      if (_user != null) {
        _user = _user!.copyWith(
          savingsBalance: (data['savings_balance'] as num?)?.toDouble(),
          loanBalance: (data['loan_balance'] as num?)?.toDouble(),
          financialScore: data['financial_score'] as int?,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  void logout() {
    _api.logout();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }
}
