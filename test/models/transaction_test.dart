import 'package:flutter_test/flutter_test.dart';
import 'package:finanze_app/models/transaction.dart';

void main() {
  group('TransactionCategory', () {
    test('isExpenseCategory returns true for first 7 categories', () {
      expect(TransactionCategory.food.isExpenseCategory, true);
      expect(TransactionCategory.transport.isExpenseCategory, true);
      expect(TransactionCategory.shopping.isExpenseCategory, true);
      expect(TransactionCategory.services.isExpenseCategory, true);
      expect(TransactionCategory.entertainment.isExpenseCategory, true);
      expect(TransactionCategory.health.isExpenseCategory, true);
      expect(TransactionCategory.education.isExpenseCategory, true);
    });

    test('isExpenseCategory returns false for income categories', () {
      expect(TransactionCategory.salary.isExpenseCategory, false);
      expect(TransactionCategory.freelance.isExpenseCategory, false);
      expect(TransactionCategory.gift.isExpenseCategory, false);
    });

    test('all categories have non-empty labels', () {
      for (final cat in TransactionCategory.values) {
        expect(cat.label.isNotEmpty, true);
      }
    });

    test('all categories have non-empty icons', () {
      for (final cat in TransactionCategory.values) {
        expect(cat.icon.isNotEmpty, true);
      }
    });
  });

  group('Transaction', () {
    test('creates with default date as DateTime.now()', () {
      final tx = Transaction(
        title: 'Test',
        amount: 100,
        category: TransactionCategory.food,
      );
      expect(tx.date.day, DateTime.now().day);
    });

    test('copyWith preserves unchanged fields', () {
      final tx = Transaction(
        id: 1,
        accountId: 2,
        title: 'Original',
        amount: 100,
        category: TransactionCategory.food,
        type: TransactionType.expense,
        note: 'note',
        customCategoryName: 'custom',
      );
      final copy = tx.copyWith();
      expect(copy.id, 1);
      expect(copy.title, 'Original');
      expect(copy.amount, 100);
    });

    test('copyWith overrides specified fields', () {
      final tx = Transaction(
        title: 'Original',
        amount: 100,
        category: TransactionCategory.food,
      );
      final copy = tx.copyWith(title: 'Updated', amount: 200);
      expect(copy.title, 'Updated');
      expect(copy.amount, 200);
      expect(copy.category, TransactionCategory.food);
    });

    test('toMap and fromMap round-trip', () {
      final tx = Transaction(
        id: 42,
        accountId: 7,
        title: 'Test',
        amount: 99.99,
        category: TransactionCategory.transport,
        type: TransactionType.expense,
        date: DateTime(2025, 1, 15),
        note: 'test note',
        customCategoryName: '',
      );
      final map = tx.toMap();
      final restored = Transaction.fromMap(map);
      expect(restored.id, tx.id);
      expect(restored.title, tx.title);
      expect(restored.amount, tx.amount);
      expect(restored.category, tx.category);
      expect(restored.type, tx.type);
      expect(restored.date.toIso8601String(), tx.date.toIso8601String());
      expect(restored.note, tx.note);
    });

    test('recurring fields round-trip through toMap/fromMap', () {
      final tx = Transaction(
        id: 10,
        accountId: 1,
        title: 'Recurring',
        amount: 50,
        category: TransactionCategory.food,
        recurringInterval: RecurringInterval.monthly,
        recurringEndDate: DateTime(2025, 12, 31),
        parentRecurringId: 5,
      );
      final map = tx.toMap();
      final restored = Transaction.fromMap(map);
      expect(restored.recurringInterval, RecurringInterval.monthly);
      expect(restored.recurringEndDate?.toIso8601String(), '2025-12-31T00:00:00.000');
      expect(restored.parentRecurringId, 5);
    });

    test('default recurringInterval is none', () {
      final tx = Transaction(
        title: 'Test',
        amount: 100,
        category: TransactionCategory.food,
      );
      expect(tx.recurringInterval, RecurringInterval.none);
      expect(tx.recurringEndDate, null);
      expect(tx.parentRecurringId, null);
    });
  });
}
