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
      _isAuthenticated = _user != null;
      _isLoading = false;
      notifyListeners();
      return _isAuthenticated;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _error = 'Invalid username or password';
      } else if (e.statusCode == 404) {
        _error = 'User not found or profile missing';
      } else {
        _error = 'Login failed (${e.statusCode}). Please try again.';
      }
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
        username: email,
        email: email,
        password: password,
        password2: password,
        firstName: name.split(' ').first,
        lastName: name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : '',
        phone: phone,
      );
      // Auto-login after registration
      await _api.login(
        username: email,
        password: password,
      );
      await _fetchCurrentUser();
      _isAuthenticated = _user != null;
      _isLoading = false;
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _error = 'Registration failed: $e';
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
        savingsBalance: double.tryParse(data['savings_balance']?.toString() ?? '') ?? 0.0,
        loanBalance: double.tryParse(data['loan_balance']?.toString() ?? '') ?? 0.0,
        financialScore: int.tryParse(data['financial_score']?.toString() ?? '') ?? 0,
      );
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      _user = null;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final data = await _api.recalculateProfile();
      if (_user != null) {
        _user = _user!.copyWith(
          name: '${data['user']?['first_name'] ?? ''} ${data['user']?['last_name'] ?? ''}'.trim(),
          savingsBalance: double.tryParse(data['savings_balance']?.toString() ?? ''),
          loanBalance: double.tryParse(data['loan_balance']?.toString() ?? ''),
          financialScore: int.tryParse(data['financial_score']?.toString() ?? ''),
        );
        notifyListeners();
      } else {
        await _fetchCurrentUser();
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
