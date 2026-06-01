import '../data/database_helper.dart';

Future<void> loadSeedData() async {
  final db = DatabaseHelper();
  final existing = await db.getAccounts();
  if (existing.isNotEmpty) return;

  final d = await db.database;

  // ── Accounts ──
  final efectivoId = await d.insert('accounts', {
    'name': 'Efectivo',
    'balance': 85430.00,
    'type': 'cash',
    'icon': 'wallet',
    'color': '#1E88E5',
    'is_counted_in_total': 1,
  });
  final debitoId = await d.insert('accounts', {
    'name': 'Débito',
    'balance': 142150.00,
    'type': 'debit',
    'icon': 'savings',
    'color': '#43A047',
    'is_counted_in_total': 1,
  });
  final creditoId = await d.insert('accounts', {
    'name': 'Crédito',
    'balance': -12800.00,
    'type': 'credit',
    'icon': 'credit_card',
    'color': '#E53935',
    'is_counted_in_total': 1,
  });

  // ── Transactions (June 2026) ──
  Future<void> addTx(int? accountId, String title, double amount, String category, String type, int day) async {
    await d.insert('transactions', {
      'accountId': accountId,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': '2026-06-${day.toString().padLeft(2, '0')}T12:00:00.000',
      'note': '',
      'customCategoryName': '',
      'recurring_interval': 'none',
    });
  }

  await addTx(debitoId, 'Sueldo', 95000, 'salary', 'income', 1);
  addTx(efectivoId, 'Supermercado', 8540, 'food', 'expense', 2);
  addTx(efectivoId, 'Taxi', 1200, 'transport', 'expense', 3);
  addTx(efectivoId, 'Netflix', 1500, 'entertainment', 'expense', 4);
  addTx(creditoId, 'Combustible', 6000, 'transport', 'expense', 5);
  addTx(efectivoId, 'Remera', 3500, 'shopping', 'expense', 5);
  addTx(efectivoId, 'Expensas', 5000, 'services', 'expense', 6);
  addTx(efectivoId, 'Farmacia', 1200, 'health', 'expense', 7);
  addTx(efectivoId, 'Curso online', 3500, 'education', 'expense', 8);
  addTx(creditoId, 'Amazon', 12500, 'shopping', 'expense', 9);
  addTx(debitoId, 'Restaurante', 4200, 'food', 'expense', 10);
  addTx(debitoId, 'Luz', 2800, 'services', 'expense', 12);
  addTx(creditoId, 'Spotify', 1500, 'entertainment', 'expense', 13);
  addTx(debitoId, 'Gas', 1200, 'services', 'expense', 14);
  addTx(creditoId, 'PedidosYa', 3200, 'food', 'expense', 15);
  addTx(debitoId, 'Cine', 2800, 'entertainment', 'expense', 16);
  addTx(debitoId, 'Curso Udemy', 5000, 'education', 'expense', 18);
  addTx(creditoId, 'Farmacia', 800, 'health', 'expense', 19);
  addTx(debitoId, 'Librería', 2000, 'education', 'expense', 20);

  // ── Goals ──
  final goal1Id = await d.insert('goals', {
    'title': 'Viaje a Europa',
    'targetAmount': 500000,
    'savedAmount': 125000,
    'deadline': 'Dic 2026',
    'icon': 'flight_takeoff',
    'colorHex': '0xFF1E88E5',
  });
  final goal2Id = await d.insert('goals', {
    'title': 'Fondo de emergencia',
    'targetAmount': 200000,
    'savedAmount': 80000,
    'deadline': 'Jun 2027',
    'icon': 'savings',
    'colorHex': '0xFF43A047',
  });

  // ── Goal Contributions ──
  await d.insert('goal_contributions', {
    'goalId': goal1Id, 'amount': 50000, 'date': '2026-05-10T12:00:00.000',
  });
  await d.insert('goal_contributions', {
    'goalId': goal1Id, 'amount': 75000, 'date': '2026-06-05T12:00:00.000',
  });
  await d.insert('goal_contributions', {
    'goalId': goal2Id, 'amount': 20000, 'date': '2026-03-15T12:00:00.000',
  });
  await d.insert('goal_contributions', {
    'goalId': goal2Id, 'amount': 30000, 'date': '2026-04-20T12:00:00.000',
  });
  await d.insert('goal_contributions', {
    'goalId': goal2Id, 'amount': 30000, 'date': '2026-06-01T12:00:00.000',
  });

  // ── Budgets ──
  final now = DateTime.now();
  await d.insert('budgets', {
    'categoryName': 'Comida', 'category': 'food', 'budget_limit': 30000,
    'spent': 0, 'month': now.month, 'year': now.year,
    'icon': 'restaurant', 'color': '#E53935',
  });
  await d.insert('budgets', {
    'categoryName': 'Transporte', 'category': 'transport', 'budget_limit': 15000,
    'spent': 0, 'month': now.month, 'year': now.year,
    'icon': 'directions_car', 'color': '#1E88E5',
  });
  await d.insert('budgets', {
    'categoryName': 'Entretenimiento', 'category': 'entertainment', 'budget_limit': 10000,
    'spent': 0, 'month': now.month, 'year': now.year,
    'icon': 'local_activity', 'color': '#AB47BC',
  });
  await d.insert('budgets', {
    'categoryName': 'Servicios', 'category': 'services', 'budget_limit': 15000,
    'spent': 0, 'month': now.month, 'year': now.year,
    'icon': 'bolt', 'color': '#FFA726',
  });
  await d.insert('budgets', {
    'categoryName': 'Compras', 'category': 'shopping', 'budget_limit': 20000,
    'spent': 0, 'month': now.month, 'year': now.year,
    'icon': 'shopping_bag', 'color': '#EC407A',
  });
  await d.insert('budgets', {
    'categoryName': 'Salud', 'category': 'health', 'budget_limit': 10000,
    'spent': 0, 'month': now.month, 'year': now.year,
    'icon': 'local_hospital', 'color': '#43A047',
  });
  await d.insert('budgets', {
    'categoryName': 'Educación', 'category': 'education', 'budget_limit': 10000,
    'spent': 0, 'month': now.month, 'year': now.year,
    'icon': 'school', 'color': '#26A69A',
  });

  // ── Recalculate budget spent ──
  await db.recalculateBudgetSpent();
}
