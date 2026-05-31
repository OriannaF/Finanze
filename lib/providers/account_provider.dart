import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/account.dart';

class AccountProvider extends ChangeNotifier {
  List<Account> _accounts = [];

  List<Account> get accounts => _accounts;

  double get totalBalance {
    return _accounts
        .where((a) => a.isCountedInTotal)
        .fold(0.0, (sum, a) => sum + a.balance);
  }

  Future<void> loadAccounts() async {
    _accounts = await DatabaseHelper().getAccounts();
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    await DatabaseHelper().updateAccount(account);
    await loadAccounts();
  }

  Future<void> insertAccount(Account account) async {
    await DatabaseHelper().insertAccount(account);
    await loadAccounts();
  }

  Future<void> deleteAccount(int id) async {
    await DatabaseHelper().deleteAccount(id);
    await loadAccounts();
  }
}
