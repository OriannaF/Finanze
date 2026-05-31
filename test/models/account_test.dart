import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanze_app/models/account.dart';

void main() {
  group('Account', () {
    test('default isCountedInTotal is true', () {
      final a = Account(name: 'Test', balance: 0, type: AccountType.cash, icon: 'wallet');
      expect(a.isCountedInTotal, true);
    });

    test('default color is #1E88E5', () {
      final a = Account(name: 'Test', balance: 0, type: AccountType.cash, icon: 'wallet');
      expect(a.color, '#1E88E5');
    });

    test('copyWith overrides fields', () {
      final a = Account(
        id: 1,
        name: 'Original',
        balance: 100,
        type: AccountType.savings,
        icon: 'wallet',
        color: '#FF0000',
        isCountedInTotal: true,
      );
      final copy = a.copyWith(name: 'Updated', balance: 200);
      expect(copy.name, 'Updated');
      expect(copy.balance, 200);
      expect(copy.id, 1);
      expect(copy.color, '#FF0000');
    });

    test('toMap and fromMap round-trip', () {
      final a = Account(
        id: 5,
        name: 'Savings',
        balance: 1500.50,
        type: AccountType.savings,
        icon: 'savings',
        color: '#2E7D32',
        isCountedInTotal: false,
      );
      final map = a.toMap();
      final restored = Account.fromMap(map);
      expect(restored.id, a.id);
      expect(restored.name, a.name);
      expect(restored.balance, a.balance);
      expect(restored.icon, a.icon);
      expect(restored.color, a.color);
      expect(restored.isCountedInTotal, a.isCountedInTotal);
    });

    test('accountColors contains expected colors', () {
      expect(accountColors.length, 10);
      expect(accountColors[0], const Color(0xFF1E88E5));
      expect(accountColors[3], const Color(0xFF43A047));
    });
  });
}
