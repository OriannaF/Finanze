import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';
import '../models/goal.dart';
import '../models/budget.dart';

class GoalProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Goal> _goals = [];
  List<Budget> _budgets = [];
  final Map<int, List<GoalContribution>> _contributions = {};
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  List<GoalContribution> getContributions(int goalId) =>
      _contributions[goalId] ?? [];

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _goals = await _db.getGoals();
    _budgets = await _db.getBudgets();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(Goal g) async {
    await _db.insertGoal(g);
    await loadData();
  }

  Future<void> updateGoal(Goal g) async {
    await _db.updateGoal(g);
    await loadData();
  }

  Future<void> deleteGoal(int id) async {
    await _db.deleteGoal(id);
    await loadData();
  }

  Future<void> addContribution(int goalId, double amount) async {
    await _db.addContribution(goalId, amount);
    _contributions.remove(goalId);
    await loadData();
  }

  Future<void> loadContributions(int goalId) async {
    final list = await _db.getContributions(goalId);
    _contributions[goalId] = list;
    notifyListeners();
  }

  Future<void> updateBudget(Budget b) async {
    await _db.updateBudget(b);
    await loadData();
  }
}
