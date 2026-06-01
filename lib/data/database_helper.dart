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
        version: 10,
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
        note TEXT DEFAULT '',
        customCategoryName TEXT DEFAULT '',
        recurring_interval TEXT DEFAULT 'none',
        recurring_end_date TEXT,
        parent_recurring_id INTEGER
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
        year INTEGER NOT NULL,
        icon TEXT DEFAULT 'more_horiz',
        color TEXT DEFAULT '#1E88E5'
      )
    ''');
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        type TEXT NOT NULL,
        icon TEXT DEFAULT 'account_balance_wallet',
        color TEXT DEFAULT '#1E88E5',
        is_counted_in_total INTEGER NOT NULL DEFAULT 1
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
    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE accounts ADD COLUMN is_counted_in_total INTEGER NOT NULL DEFAULT 1'
      );
    }
    if (oldVersion < 6) {
      await db.execute(
        "ALTER TABLE accounts ADD COLUMN color TEXT NOT NULL DEFAULT '#1E88E5'"
      );
    }
    if (oldVersion < 7) {
      await db.execute(
        "ALTER TABLE transactions ADD COLUMN customCategoryName TEXT DEFAULT ''"
      );
    }
    if (oldVersion < 8) {
      await db.execute(
        "ALTER TABLE transactions ADD COLUMN recurring_interval TEXT DEFAULT 'none'"
      );
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN recurring_end_date TEXT'
      );
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN parent_recurring_id INTEGER'
      );
    }
    if (oldVersion < 9) {
      await db.execute(
        "ALTER TABLE budgets ADD COLUMN icon TEXT DEFAULT 'more_horiz'"
      );
      await db.execute(
        "ALTER TABLE budgets ADD COLUMN color TEXT DEFAULT '#1E88E5'"
      );
    }
    if (oldVersion < 10) {
      await db.execute('DROP TABLE IF EXISTS goal_contributions');
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS goals');
      await db.execute('DROP TABLE IF EXISTS budgets');
      await db.execute('DROP TABLE IF EXISTS accounts');
      await _onCreate(db, newVersion);
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

  Future<void> updateTransaction(Transaction t) async {
    final db = await database;
    final map = t.toMap();
    map.remove('id');
    await db.update('transactions', map, where: 'id = ?', whereArgs: [t.id]);
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
  Future<Budget?> getBudgetById(int id) async {
    final db = await database;
    final maps = await db.query('budgets', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

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

  Future<void> deleteBudget(int id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> recalculateBudgetSpent({int? month, int? year}) async {
    final db = await database;
    final now = DateTime.now();
    final m = month ?? now.month;
    final y = year ?? now.year;

    final firstDay = DateTime(y, m, 1);
    final lastDay = DateTime(y, m + 1, 0, 23, 59, 59);

    final budgets = await getBudgets(month: m, year: y);
    for (final b in budgets) {
      if (b.category == null) continue;
      final maps = await db.query(
        'transactions',
        where: 'category = ? AND type = ? AND date >= ? AND date <= ?',
        whereArgs: [b.category!.name, 'expense', firstDay.toIso8601String(), lastDay.toIso8601String()],
      );
      final spent = maps.fold(0.0, (sum, m) => sum + (m['amount'] as num).toDouble());
      await db.update(
        'budgets',
        {'spent': spent},
        where: 'id = ?',
        whereArgs: [b.id],
      );
    }
  }

  Future<int> generateRecurringTransactions() async {
    final db = await database;
    final now = DateTime.now();
    int created = 0;

    final recurringTxMaps = await db.query(
      'transactions',
      where: "recurring_interval != 'none' AND (recurring_end_date IS NULL OR recurring_end_date >= ?)",
      whereArgs: [now.toIso8601String()],
    );

    for (final map in recurringTxMaps) {
      final tx = Transaction.fromMap(map);
      if (tx.id == null) continue;
      DateTime nextDate;
      switch (tx.recurringInterval) {
        case RecurringInterval.daily:
          nextDate = tx.date.add(const Duration(days: 1));
        case RecurringInterval.weekly:
          nextDate = tx.date.add(const Duration(days: 7));
        case RecurringInterval.monthly:
          nextDate = DateTime(tx.date.year, tx.date.month + 1, tx.date.day);
        case RecurringInterval.yearly:
          nextDate = DateTime(tx.date.year + 1, tx.date.month, tx.date.day);
        default:
          continue;
      }

      while (!nextDate.isAfter(now)) {
        if (tx.recurringEndDate != null && nextDate.isAfter(tx.recurringEndDate!)) break;

        await db.insert('transactions', {
          'accountId': tx.accountId,
          'title': tx.title,
          'amount': tx.amount,
          'category': tx.category.name,
          'type': tx.type.name,
          'date': nextDate.toIso8601String(),
          'note': tx.note,
          'customCategoryName': tx.customCategoryName,
          'recurring_interval': 'none',
          'parent_recurring_id': tx.id,
        });
        created++;

        switch (tx.recurringInterval) {
          case RecurringInterval.daily:
            nextDate = nextDate.add(const Duration(days: 1));
          case RecurringInterval.weekly:
            nextDate = nextDate.add(const Duration(days: 7));
          case RecurringInterval.monthly:
            nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
          case RecurringInterval.yearly:
            nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
          default:
            break;
        }
      }
    }

    return created;
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
      await txn.delete('goal_contributions');
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

  Future<void> updateAccount(Account account) async {
    final db = await database;
    await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> deleteAccount(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions', where: 'accountId = ?', whereArgs: [id]);
      await txn.delete('accounts', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Transaction>> getTransactionsByAccount(int accountId) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  Future<List<Transaction>> getTransactionsByCategory(String categoryName) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [categoryName],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Transaction.fromMap(m)).toList();
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
