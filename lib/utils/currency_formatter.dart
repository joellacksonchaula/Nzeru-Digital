import 'package:intl/intl.dart';

/// Currency formatting utilities for Malawian Kwacha (MK)
class CurrencyFormatter {
  // Private constructor to prevent instantiation
  CurrencyFormatter._();

  /// Format number as Malawian Kwacha with comma separators
  /// Examples:
  /// - 1000 → "MK 1,000.00"
  /// - 1000000 → "MK 1,000,000.00"
  /// - 123.456 → "MK 123.46"
  static String formatMK(num amount, {int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      symbol: 'MK ',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Format number as Malawian Kwacha without symbol (just number with commas)
  /// Examples:
  /// - 1000 → "1,000.00"
  /// - 1000000 → "1,000,000.00"
  static String formatNumberOnly(num amount, {int decimalDigits = 2}) {
    final formatter = NumberFormat('0.00');
    final formatted = formatter.format(amount);
    
    // Add thousand separators
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';
    
    // Reverse, add commas every 3 digits, reverse back
    final reversed = intPart.split('').reversed.join();
    final withCommas = reversed
        .replaceAllMapped(RegExp(r'.{1,3}'), (match) => '${match.group(0)},')
        .split('')
        .reversed
        .join()
        .replaceFirst(',', ''); // Remove leading comma if any
    
    return '$withCommas.$decimalPart';
  }

  /// Format as currency for display in cards/tiles
  /// Examples:
  /// - 1000 → "MK1,000.00"
  /// - 50000 → "MK50,000.00"
  static String formatCompact(num amount, {int decimalDigits = 2}) {
    if (amount >= 1000000) {
      return 'MK${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'MK${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatMK(amount, decimalDigits: decimalDigits);
  }

  /// Format with fixed decimal places for precise values
  static String formatPrecise(num amount) {
    final formatter = NumberFormat('0.00');
    return 'MK ${formatter.format(amount)}';
  }

  /// Format change percentage (e.g., "+12.5%", "-5.2%")
  static String formatPercentage(num amount) {
    final sign = amount >= 0 ? '+' : '';
    return '$sign${amount.toStringAsFixed(1)}%';
  }

  /// Format for table display (right-aligned, consistent width)
  static String formatTableValue(num amount) {
    return formatMK(amount).padLeft(12);
  }
}
