import 'package:flutter_test/flutter_test.dart';
import 'package:finanze_app/utils/currency_formatter.dart';

void main() {
  group('formatCurrency', () {
    setUp(() {
      setNumberLocale('es_AR');
    });

    test('formats integer amount with default locale', () {
      expect(formatCurrency(15000), '\$15.000,00');
    });

    test('formats decimal amount', () {
      expect(formatCurrency(99.5), '\$99,50');
    });

    test('formats zero', () {
      expect(formatCurrency(0), '\$0,00');
    });

    test('formats small number', () {
      expect(formatCurrency(1.99), '\$1,99');
    });
  });

  group('formatCompactCurrency', () {
    setUp(() {
      setNumberLocale('es_AR');
    });

    test('formats thousands', () {
      expect(formatCompactCurrency(15000), '\$15k');
    });

    test('formats millions', () {
      expect(formatCompactCurrency(2500000), '\$2,5M');
    });

    test('formats small numbers without compacting', () {
      expect(formatCompactCurrency(500), '\$500,00');
    });
  });

  group('number locale switching', () {
    test('es_AR uses period as thousands separator', () {
      setNumberLocale('es_AR');
      expect(formatCurrency(15000), '\$15.000,00');
    });

    test('en_US uses comma as thousands separator', () {
      setNumberLocale('en_US');
      expect(formatCurrency(15000), '\$15,000.00');
    });
  });
}
