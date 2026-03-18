import 'package:intl/intl.dart';

class CurrencyUtil {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'MK ',
    decimalDigits: 2,
  );

  static String format(num amount) {
    return _formatter.format(amount);
  }

  static String formatNoDecimal(num amount) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: 'MK ',
      decimalDigits: 0,
    ).format(amount);
  }

  static String formatCompact(num amount) {
    return NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: 'MK ',
      decimalDigits: 1,
    ).format(amount);
  }
}
