import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/budget.dart';
import '../models/account.dart';
import 'mock_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'finanze.db');
    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) => _onCreate(db, version),
        onUpgrade: (db, oldVersion, newVersion) =>
            _onUpgrade(db, oldVersion, newVersion),
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'expense',
        date TEXT NOT NULL,
        note TEXT DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        savedAmount REAL DEFAULT 0,
        deadline TEXT NOT NULL,
        icon TEXT DEFAULT 'flight_takeoff',
        colorHex TEXT DEFAULT '0xFF000000'
      )
    ''');
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryName TEXT NOT NULL,
        category TEXT,
        budget_limit REAL NOT NULL,
        spent REAL DEFAULT 0,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        type TEXT NOT NULL,
        icon TEXT DEFAULT 'account_balance_wallet'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS budgets');
      await db.execute('''
        CREATE TABLE budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          categoryName TEXT NOT NULL,
          category TEXT,
          budget_limit REAL NOT NULL,
          spent REAL DEFAULT 0,
          month INTEGER NOT NULL,
          year INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE transactions ADD COLUMN accountId INTEGER');
    }
  }

  Future<void> insertMockData() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM transactions');
    final count = result.first['cnt'] as int?;
    if (count != null && count > 0) return;

    final batch = db.batch();
    for (final t in MockData.transactions) {
      batch.insert('transactions', t.toMap());
    }
    for (final g in MockData.goals) {
      batch.insert('goals', g.toMap());
    }
    for (final b in MockData.budgets) {
      batch.insert('budgets', b.toMap());
    }
    for (final a in MockData.accounts) {
      batch.insert('accounts', a.toMap());
    }
    await batch.commit(noResult: true);
  }

  // Transactions
  Future<List<Transaction>> getTransactions({String? period}) async {
    final db = await database;
    final now = DateTime.now();
    String? where;

    if (period == 'week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      where = "date >= '${weekAgo.toIso8601String()}'";
    } else if (period == 'month') {
      final monthAgo = now.subtract(const Duration(days: 30));
      where = "date >= '${monthAgo.toIso8601String()}'";
    } else if (period == 'year') {
      final yearAgo = now.subtract(const Duration(days: 365));
      where = "date >= '${yearAgo.toIso8601String()}'";
    }

    final maps = await db.query(
      'transactions',
      where: where,
      orderBy: 'date DESC',
    );
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  Future<void> insertTransaction(Transaction t) async {
    final db = await database;
    await db.insert('transactions', t.toMap());
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Goals
  Future<List<Goal>> getGoals() async {
    final db = await database;
    final maps = await db.query('goals');
    return maps.map((m) => Goal.fromMap(m)).toList();
  }

  Future<void> insertGoal(Goal g) async {
    final db = await database;
    await db.insert('goals', g.toMap());
  }

  Future<void> updateGoal(Goal g) async {
    final db = await database;
    await db.update('goals', g.toMap(), where: 'id = ?', whereArgs: [g.id]);
  }

  // Budgets
  Future<List<Budget>> getBudgets({int? month, int? year}) async {
    final db = await database;
    final now = DateTime.now();
    final maps = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month ?? now.month, year ?? now.year],
    );
    return maps.map((m) => Budget.fromMap(m)).toList();
  }

  Future<void> insertBudget(Budget b) async {
    final db = await database;
    await db.insert('budgets', b.toMap());
  }

  Future<void> updateBudget(Budget b) async {
    final db = await database;
    await db.update('budgets', b.toMap(), where: 'id = ?', whereArgs: [b.id]);
  }

  // Accounts
  Future<List<Account>> getAccounts() async {
    final db = await database;
    final maps = await db.query('accounts');
    return maps.map((m) => Account.fromMap(m)).toList();
  }

  // Stats
  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = 'income'",
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getTotalExpenses({String? period}) async {
    final db = await database;
    final now = DateTime.now();
    String? where = "type = 'expense'";

    if (period == 'week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      where += " AND date >= '${weekAgo.toIso8601String()}'";
    } else if (period == 'month') {
      final monthAgo = now.subtract(const Duration(days: 30));
      where += " AND date >= '${monthAgo.toIso8601String()}'";
    }

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE $where',
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<Map<String, double>> getExpensesByCategory({String? period}) async {
    final db = await database;
    final now = DateTime.now();
    String? where = "type = 'expense'";

    if (period == 'week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      where += " AND date >= '${weekAgo.toIso8601String()}'";
    } else if (period == 'month') {
      final monthAgo = now.subtract(const Duration(days: 30));
      where += " AND date >= '${monthAgo.toIso8601String()}'";
    }

    final result = await db.rawQuery(
      'SELECT category, COALESCE(SUM(amount), 0) as total FROM transactions WHERE $where GROUP BY category',
    );
    return {for (final r in result) r['category'] as String: (r['total'] as num).toDouble()};
  }
}
