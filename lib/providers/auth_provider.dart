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

  /// Call this at startup (from SplashScreen) to restore a saved session.
  Future<bool> tryRestoreSession() async {
    await _api.loadTokens();
    if (!_api.isAuthenticated) return false;
    try {
      await _fetchCurrentUser();
      _isAuthenticated = _user != null;
      notifyListeners();
      return _isAuthenticated;
    } catch (_) {
      // Token may be expired; try refresh
      final refreshed = await _api.refreshToken();
      if (refreshed) {
        try {
          await _fetchCurrentUser();
          _isAuthenticated = _user != null;
          notifyListeners();
          return _isAuthenticated;
        } catch (_) {}
      }
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    final normalizedUsername = username.trim();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.login(username: normalizedUsername, password: password);
      await _fetchCurrentUser();
      _isAuthenticated = _user != null;
      _isLoading = false;
      notifyListeners();
      return _isAuthenticated;
    } on ApiException catch (e) {
      _isLoading = false;
      if (e.statusCode == 401) {
        _error = 'Invalid email or password';
      } else if (e.statusCode == 400) {
        // Parse validation error from body if possible
        _error = 'Login failed: please check your credentials.';
      } else {
        _error = 'Login failed (${e.statusCode}). Please try again.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Network error. Please check your connection.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.trim();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use email as username so login also works with email
      await _api.register(
        username: normalizedEmail,
        email: normalizedEmail,
        password: password,
        password2: password,
        firstName: normalizedName.split(' ').first,
        lastName: normalizedName.split(' ').length > 1
            ? normalizedName.split(' ').sublist(1).join(' ')
            : '',
        phone: normalizedPhone,
      );
      // Auto-login after registration
      await _api.login(username: normalizedEmail, password: password);
      await _fetchCurrentUser();
      _isAuthenticated = _user != null;
      _isLoading = false;
      notifyListeners();
      return _isAuthenticated;
    } on ApiException catch (e) {
      _isLoading = false;
      _error = 'Registration failed (${e.statusCode}): ${e.body}';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Network error. Please check your connection.';
      notifyListeners();
      return false;
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final data = await _api.getCurrentUser();
      // /auth/me/ returns the UserProfile which contains nested user object
      final userData = data['user'] ?? data;
      _user = User(
        id: userData['id']?.toString() ?? '',
        name: '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'
            .trim()
            .isNotEmpty
            ? '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim()
            : (userData['username'] ?? 'User'),
        email: userData['email'] ?? '',
        phone: data['phone'] ?? '',
        savingsBalance:
            double.tryParse(data['savings_balance']?.toString() ?? '') ?? 0.0,
        loanBalance:
            double.tryParse(data['loan_balance']?.toString() ?? '') ?? 0.0,
        financialScore:
            int.tryParse(data['financial_score']?.toString() ?? '') ?? 0,
      );
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      _user = null;
    }
  }

  /// Refresh user profile data from the single-call dashboard endpoint.
  Future<void> refreshProfile() async {
    try {
      final data = await _api.getDashboard();
      final userData = data['user'] ?? {};
      final name =
          '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
      _user = User(
        id: userData['id']?.toString() ?? _user?.id ?? '',
        name: name.isNotEmpty ? name : (userData['username'] ?? _user?.name ?? 'User'),
        email: userData['email'] ?? _user?.email ?? '',
        phone: _user?.phone ?? '',
        savingsBalance:
            double.tryParse(data['savings_balance']?.toString() ?? '') ??
                _user?.savingsBalance ??
                0.0,
        loanBalance:
            double.tryParse(data['loan_balance']?.toString() ?? '') ??
                _user?.loanBalance ??
                0.0,
        financialScore:
            int.tryParse(data['financial_score']?.toString() ?? '') ??
                _user?.financialScore ??
                0,
      );
      notifyListeners();
    } catch (_) {
      // Fallback to the profile recalculate endpoint
      try {
        final data = await _api.recalculateProfile();
        if (_user != null) {
          final userData = data['user'] ?? {};
          _user = _user!.copyWith(
            savingsBalance:
                double.tryParse(data['savings_balance']?.toString() ?? ''),
            loanBalance:
                double.tryParse(data['loan_balance']?.toString() ?? ''),
            financialScore:
                int.tryParse(data['financial_score']?.toString() ?? ''),
          );
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }
}
