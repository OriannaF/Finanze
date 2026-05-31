import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/budget.dart';
import '../models/account.dart';

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
        version: 4,
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
    await db.execute('''
      CREATE TABLE goal_contributions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goalId INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (goalId) REFERENCES goals(id) ON DELETE CASCADE
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
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE goal_contributions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goalId INTEGER NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL
        )
      ''');
    }
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

  Future<void> deleteGoal(int id) async {
    final db = await database;
    await db.delete('goal_contributions', where: 'goalId = ?', whereArgs: [id]);
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // Goal contributions
  Future<List<GoalContribution>> getContributions(int goalId) async {
    final db = await database;
    final maps = await db.query(
      'goal_contributions',
      where: 'goalId = ?',
      whereArgs: [goalId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => GoalContribution.fromMap(m)).toList();
  }

  Future<void> addContribution(int goalId, double amount) async {
    final db = await database;
    await db.insert('goal_contributions', {
      'goalId': goalId,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    });
    await db.rawUpdate(
      'UPDATE goals SET savedAmount = savedAmount + ? WHERE id = ?',
      [amount, goalId],
    );
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

  // Bulk operations
  Future<Map<String, List<Map<String, dynamic>>>> exportAllData() async {
    final db = await database;
    final transactions = await db.query('transactions', orderBy: 'date DESC');
    final goals = await db.query('goals');
    final budgets = await db.query('budgets');
    final accounts = await db.query('accounts');
    return {
      'transactions': transactions,
      'goals': goals,
      'budgets': budgets,
      'accounts': accounts,
    };
  }

  Future<void> importAllData(Map<String, List<Map<String, dynamic>>> data) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('goals');
      await txn.delete('budgets');
      await txn.delete('accounts');
      for (final t in data['transactions'] ?? []) {
        final map = Map<String, dynamic>.from(t);
        map.remove('id');
        await txn.insert('transactions', map);
      }
      for (final g in data['goals'] ?? []) {
        final map = Map<String, dynamic>.from(g);
        map.remove('id');
        await txn.insert('goals', map);
      }
      for (final b in data['budgets'] ?? []) {
        final map = Map<String, dynamic>.from(b);
        map.remove('id');
        await txn.insert('budgets', map);
      }
      for (final a in data['accounts'] ?? []) {
        final map = Map<String, dynamic>.from(a);
        map.remove('id');
        await txn.insert('accounts', map);
      }
    });
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('goals');
      await txn.delete('budgets');
      await txn.delete('accounts');
    });
  }

  // Accounts
  Future<List<Account>> getAccounts() async {
    final db = await database;
    final maps = await db.query('accounts');
    return maps.map((m) => Account.fromMap(m)).toList();
  }

  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
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
