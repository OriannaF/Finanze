import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/budget.dart';
import '../models/account.dart';

class MockData {
  static final List<Transaction> transactions = [
    Transaction(
      title: 'Starbucks', amount: 6.50,
      category: TransactionCategory.food, accountId: 1,
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Transaction(
      title: 'Apple Store', amount: 129.00,
      category: TransactionCategory.shopping, accountId: 2,
      date: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Transaction(
      title: 'Salary Deposit', amount: 3200.00,
      category: TransactionCategory.salary,
      type: TransactionType.income, accountId: 2,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    Transaction(
      title: 'Uber', amount: 24.50,
      category: TransactionCategory.transport, accountId: 1,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    ),
    Transaction(
      title: 'Cold Storage', amount: 6.71,
      category: TransactionCategory.food, accountId: 1,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Transaction(
      title: 'Prudential', amount: 2312.08,
      category: TransactionCategory.services, accountId: 2,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      title: 'Netflix', amount: 15.99,
      category: TransactionCategory.entertainment, accountId: 2,
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Transaction(
      title: 'Spotify', amount: 9.99,
      category: TransactionCategory.entertainment, accountId: 2,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Transaction(
      title: 'Supermarket', amount: 85.30,
      category: TransactionCategory.food, accountId: 1,
      date: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Transaction(
      title: 'Gas Station', amount: 45.00,
      category: TransactionCategory.transport, accountId: 1,
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Transaction(
      title: 'Freelance Payment', amount: 500.00,
      category: TransactionCategory.freelance,
      type: TransactionType.income, accountId: 2,
      date: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Transaction(
      title: 'Amazon', amount: 67.99,
      category: TransactionCategory.shopping, accountId: 2,
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  static final List<Goal> goals = [
    Goal(
      title: 'Japan Trip',
      targetAmount: 3000,
      savedAmount: 900,
      deadline: 'Aug 2026',
      icon: 'flight_takeoff',
    ),
    Goal(
      title: 'Emergency Fund',
      targetAmount: 10000,
      savedAmount: 3500,
      deadline: 'Dec 2026',
      icon: 'savings',
    ),
  ];

  static final List<Budget> budgets = [
    Budget(
      categoryName: 'Groceries',
      category: TransactionCategory.food,
      limit: 500,
      spent: 380,
    ),
    Budget(
      categoryName: 'Dining',
      category: TransactionCategory.food,
      limit: 200,
      spent: 215,
    ),
    Budget(
      categoryName: 'Transport',
      category: TransactionCategory.transport,
      limit: 150,
      spent: 70,
    ),
    Budget(
      categoryName: 'Shopping',
      category: TransactionCategory.shopping,
      limit: 300,
      spent: 196,
    ),
  ];

  static final List<Account> accounts = [
    Account(name: 'Efectivo', balance: 420.50, type: AccountType.cash),
    Account(name: 'Débito', balance: 15000, type: AccountType.debit),
    Account(name: 'Ahorros', balance: 5000, type: AccountType.savings),
  ];
}
