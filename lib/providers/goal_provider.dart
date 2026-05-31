import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';
import '../models/goal.dart';
import '../models/budget.dart';

class GoalProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Goal> _goals = [];
  List<Budget> _budgets = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

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

  Future<void> updateBudget(Budget b) async {
    await _db.updateBudget(b);
    await loadData();
  }
}
