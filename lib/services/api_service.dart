import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Central API service handling all HTTP calls to the Django backend.
/// Tokens are persisted to SharedPreferences so sessions survive app restarts.
class ApiService {
  // Production URL
  static const String baseUrl =
      "https://savingsutl-production.up.railway.app/api";

  String? _accessToken;
  String? _refreshToken;

  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  bool get isAuthenticated => _accessToken != null;

  // ─── Token Persistence ──────────────────────────────

  /// Call once at startup (in main.dart) to restore any saved session.
  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  Future<void> _saveTokens() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString('access_token', _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString('refresh_token', _refreshToken!);
    }
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // ─── Headers ────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  // ─── Core HTTP helpers with auto-refresh ────────────

  /// GET with automatic token refresh on 401.
  Future<http.Response> _get(String path) async {
    var response = await http
        .get(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        response = await http
            .get(Uri.parse('$baseUrl$path'), headers: _headers)
            .timeout(const Duration(seconds: 30));
      }
    }
    return response;
  }

  /// POST with automatic token refresh on 401.
  Future<http.Response> _post(String path,
      {Map<String, dynamic>? body, bool requiresAuth = true}) async {
    final headers = requiresAuth
        ? _headers
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    var response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 401 && requiresAuth) {
      final refreshed = await refreshToken();
      if (refreshed) {
        response = await http
            .post(
              Uri.parse('$baseUrl$path'),
              headers: _headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(const Duration(seconds: 30));
      }
    }
    return response;
  }

  // ─── Auth ────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    String firstName = '',
    String lastName = '',
    String phone = '',
  }) async {
    try {
      final response = await _post(
        '/auth/register/',
        body: {
          'username': username,
          'email': email,
          'password': password,
          'password2': password2,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        },
        requiresAuth: false,
      );
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception(
          'Network error: ${e.message}. Check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout. Server took too long to respond.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _post(
        '/auth/login/',
        body: {'username': username, 'password': password},
        requiresAuth: false,
      );
      final data = _handleResponse(response);
      _accessToken = data['access'];
      _refreshToken = data['refresh'];
      await _saveTokens();
      return data;
    } on SocketException catch (e) {
      throw Exception(
          'Network error: ${e.message}. Check your internet connection.');
    } on TimeoutException {
      throw Exception('Login timeout. Server took too long to respond.');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': _refreshToken}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        if (data.containsKey('refresh')) {
          _refreshToken = data['refresh'];
        }
        await _saveTokens();
        return true;
      }
      // Refresh token expired — clear everything
      await logout();
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    await _clearTokens();
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _get('/auth/me/');
    return _handleResponse(response);
  }

  // ─── Dashboard (single-call) ─────────────────────────

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _get('/dashboard/');
    return _handleResponse(response);
  }

  // ─── Profile ─────────────────────────────────────────

  Future<Map<String, dynamic>> recalculateProfile() async {
    final response = await _post('/profile/recalculate/');
    return _handleResponse(response);
  }

  // ─── Savings Plans ────────────────────────────────────

  Future<List<dynamic>> getSavingsPlans({bool? secretOnly}) async {
    final path = secretOnly == null
        ? '/savings/'
        : '/savings/?secret=$secretOnly';
    final response = await _get(path);
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> createSavingsPlan(
      Map<String, dynamic> data) async {
    final response = await _post('/savings/', body: data);
    return _handleResponse(response);
  }

  // ─── Transactions ──────────────────────────────────────

  Future<List<dynamic>> getTransactions() async {
    final response = await _get('/transactions/');
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> createDeposit(
      Map<String, dynamic> data) async {
    final response = await _post('/transactions/', body: data);
    return _handleResponse(response);
  }

  // ─── Penalties ─────────────────────────────────────────

  Future<List<dynamic>> getPenalties() async {
    final response = await _get('/penalties/');
    return _handleListResponse(response);
  }

  // ─── Loans ─────────────────────────────────────────────

  Future<List<dynamic>> getLoans() async {
    final response = await _get('/loans/');
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> requestLoan(
      Map<String, dynamic> data) async {
    final response = await _post('/loans/', body: data);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getLoanEligibility() async {
    final response = await _get('/loans/eligibility/');
    return _handleResponse(response);
  }

  // ─── Loan Payments ─────────────────────────────────────

  Future<List<dynamic>> getLoanPayments() async {
    final response = await _get('/payments/');
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> makeLoanPayment(
      Map<String, dynamic> data) async {
    final response = await _post('/payments/', body: data);
    return _handleResponse(response);
  }

  // ─── Interest Distributions ────────────────────────────

  Future<List<dynamic>> getInterestDistributions() async {
    final response = await _get('/interest/');
    return _handleListResponse(response);
  }

  // ─── Notifications ─────────────────────────────────────

  Future<List<dynamic>> getNotifications() async {
    final response = await _get('/notifications/');
    return _handleListResponse(response);
  }

  Future<void> markNotificationRead(int id) async {
    await _post('/notifications/$id/mark_read/');
  }

  Future<void> markAllNotificationsRead() async {
    await _post('/notifications/mark_all_read/');
  }

  // ─── Reports ───────────────────────────────────────────

  Future<Map<String, dynamic>> getFinancialReport() async {
    final response = await _get('/reports/');
    return _handleResponse(response);
  }

  // ─── Response Helpers ──────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    }
    throw ApiException(response.statusCode, response.body);
  }

  List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded.containsKey('results')) {
        return decoded['results'] as List;
      }
      return [];
    }
    throw ApiException(response.statusCode, response.body);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;

  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
