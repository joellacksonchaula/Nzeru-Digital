import 'package:flutter_test/flutter_test.dart';
import 'package:savings_utl/utils/currency_util.dart';

void main() {
  group('CurrencyUtil Tests', () {
    test('Format with decimals', () {
      expect(CurrencyUtil.format(1234.56), 'MK 1,234.56');
      expect(CurrencyUtil.format(0), 'MK 0.00');
    });

    test('Format without decimals', () {
      expect(CurrencyUtil.formatNoDecimal(1234.56), 'MK 1,235'); // Rounds
      expect(CurrencyUtil.formatNoDecimal(1234), 'MK 1,234');
    });

    test('Compact format', () {
      expect(CurrencyUtil.formatCompact(1200), 'MK 1.2K');
      expect(CurrencyUtil.formatCompact(1200000), 'MK 1.2M');
    });
  });
}
