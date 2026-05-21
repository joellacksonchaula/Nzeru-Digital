import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_settings.dart';
import '../services/api_service.dart';

Map<String, dynamic> _asStringKeyedMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

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
  UserSettings get settings => _user?.settings ?? const UserSettings();

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
    } on ApiConfigurationException catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
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
    } on ApiConfigurationException catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final data = await _api.getCurrentUser();
      final userMap = _asStringKeyedMap(data['user']);
      final userData = userMap.isNotEmpty ? userMap : _asStringKeyedMap(data);
      userData['phone'] = data['phone'];
      userData['savings_balance'] = data['savings_balance'];
      userData['credit_balance'] = data['credit_balance'] ?? data['loan_balance'];
      userData['loan_balance'] = data['loan_balance'];
      userData['tracked_savings_balance'] =
          data['tracked_savings_balance'] ?? data['savings_balance'];
      userData['financial_score'] = data['financial_score'];
      userData['settings'] = _asStringKeyedMap(data['settings']);
      _user = User.fromJson(userData);
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      _user = null;
    }
  }

  /// Refresh user profile data from the single-call dashboard endpoint.
  Future<void> refreshProfile() async {
    try {
      final data = await _api.getDashboard();
      final userData = _asStringKeyedMap(data['user']);
      final userSettings = _asStringKeyedMap(userData['settings']);
      final mergedUser = <String, dynamic>{
        ...userData,
        'id': userData['id']?.toString() ?? _user?.id ?? '',
        'name': userData['name'] ?? _user?.name ?? 'User',
        'email': userData['email'] ?? _user?.email ?? '',
        'phone': userData['phone'] ?? _user?.phone ?? '',
        'savings_balance': data['real_savings_balance'] ?? data['savings_balance'],
        'credit_balance': data['credit_balance'] ?? data['loan_balance'],
        'loan_balance': data['loan_balance'],
        'tracked_savings_balance':
            data['tracked_savings_balance'] ?? _user?.trackedSavingsBalance ?? 0,
        'financial_score':
            data['financial_score'] ?? _user?.financialScore ?? 0,
        'settings': userSettings.isNotEmpty
            ? userSettings
            : (_user?.settings.toJson() ?? <String, dynamic>{}),
      };
      _user = User.fromJson(mergedUser);
      notifyListeners();
    } catch (_) {
      // Fallback to the profile recalculate endpoint
      try {
        final data = await _api.recalculateProfile();
        if (_user != null) {
          _user = _user!.copyWith(
            savingsBalance:
                double.tryParse(data['savings_balance']?.toString() ?? ''),
            creditBalance: double.tryParse(
              (data['credit_balance'] ?? data['loan_balance'])?.toString() ?? '',
            ),
            trackedSavingsBalance: double.tryParse(
              (data['tracked_savings_balance'] ?? data['savings_balance'])?.toString() ?? '',
            ),
            financialScore:
                int.tryParse(data['financial_score']?.toString() ?? ''),
            settings: UserSettings.fromJson(_asStringKeyedMap(data['settings'])),
          );
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  Future<bool> updateSettings(UserSettings newSettings) async {
    try {
      final data = await _api.updateSettings(newSettings.toJson());
      if (_user != null) {
        _user = _user!.copyWith(
          settings: UserSettings.fromJson(_asStringKeyedMap(data)),
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update settings';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to change password';
      notifyListeners();
      return false;
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
