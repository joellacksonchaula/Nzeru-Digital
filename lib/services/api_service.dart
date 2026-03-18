import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

/// Central API service handling all HTTP calls to the Django backend.
/// Stores JWT tokens for authenticated requests.
class ApiService {
  // Production URL
  static const String baseUrl = "https://savingsutl-production.up.railway.app/api";

  String? _accessToken;
  String? _refreshToken;

  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  bool get isAuthenticated => _accessToken != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  // ─── Auth ───────────────────────────────────────────

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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password2': password2,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        }),
      ).timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}. Check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout. Server took too long to respond.');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));
      
      final data = _handleResponse(response);
      _accessToken = data['access'];
      _refreshToken = data['refresh'];
      return data;
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}. Check your internet connection and verify the server is running.');
    } on TimeoutException {
      throw Exception('Login timeout. Server took too long to respond.');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        if (data.containsKey('refresh')) {
          _refreshToken = data['refresh'];
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─── Profile ────────────────────────────────────────

  Future<Map<String, dynamic>> recalculateProfile() async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/recalculate/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─── Savings Plans ──────────────────────────────────

  Future<List<dynamic>> getSavingsPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/savings/'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> createSavingsPlan(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/savings/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // ─── Transactions ───────────────────────────────────

  Future<List<dynamic>> getTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> createDeposit(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // ─── Penalties ──────────────────────────────────────

  Future<List<dynamic>> getPenalties() async {
    final response = await http.get(
      Uri.parse('$baseUrl/penalties/'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  // ─── Loans ──────────────────────────────────────────

  Future<List<dynamic>> getLoans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/loans/'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> requestLoan(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/loans/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getLoanEligibility() async {
    final response = await http.get(
      Uri.parse('$baseUrl/loans/eligibility/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─── Loan Payments ──────────────────────────────────

  Future<List<dynamic>> getLoanPayments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> makeLoanPayment(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // ─── Interest Distributions ─────────────────────────

  Future<List<dynamic>> getInterestDistributions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/interest/'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  // ─── Notifications ──────────────────────────────────

  Future<List<dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  Future<void> markNotificationRead(int id) async {
    await http.post(
      Uri.parse('$baseUrl/notifications/$id/mark_read/'),
      headers: _headers,
    );
  }

  Future<void> markAllNotificationsRead() async {
    await http.post(
      Uri.parse('$baseUrl/notifications/mark_all_read/'),
      headers: _headers,
    );
  }

  // ─── Reports ────────────────────────────────────────

  Future<Map<String, dynamic>> getFinancialReport() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─── Helpers ────────────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(response.statusCode, response.body);
  }

  List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      // Handle both paginated and non-paginated responses
      if (decoded is List) return decoded;
      if (decoded is Map && decoded.containsKey('results')) {
        return decoded['results'] as List;
      }
      return [decoded];
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
