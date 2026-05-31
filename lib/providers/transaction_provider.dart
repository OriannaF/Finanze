import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Transaction> _transactions = [];
  List<Transaction> _allTransactions = [];
  String _selectedPeriod = 'all';
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get selectedPeriod => _selectedPeriod;

  Future<void> loadTransactions({String? period}) async {
    _isLoading = true;
    notifyListeners();

    _selectedPeriod = period ?? 'all';
    _allTransactions = await _db.getTransactions(period: period);
    _transactions = _allTransactions;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _recalculateBudgets() async {
    await _db.recalculateBudgetSpent();
  }

  Future<void> addTransaction(Transaction t) async {
    await _db.insertTransaction(t);
    await _recalculateBudgets();
    await loadTransactions(period: _selectedPeriod);
  }

  Future<void> updateTransaction(Transaction t) async {
    await _db.updateTransaction(t);
    await _recalculateBudgets();
    await loadTransactions(period: _selectedPeriod);
  }

  Future<void> deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
    await _recalculateBudgets();
    await loadTransactions(period: _selectedPeriod);
  }

  Future<double> getTotalIncome() async => await _db.getTotalIncome();

  Future<double> getTotalExpenses({String? period}) async =>
      await _db.getTotalExpenses(period: period);

  Future<Map<String, double>> getExpensesByCategory({String? period}) async =>
      await _db.getExpensesByCategory(period: period);

  double get totalExpense {
    return _allTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalIncome {
    return _allTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalBalance {
    final income = _allTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = _allTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    return income - expense;
  }
}
