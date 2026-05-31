import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart' as formatter;

class SettingsProvider extends ChangeNotifier {
  String _currency = 'ARS';
  String _numberLocale = 'es_AR';
  double _monthlyBudgetLimit = 0;
  int? _defaultAccountId;
  String _dateFormat = 'DD/MM';
  String _weekStartDay = 'Lunes';
  Map<String, String> _customCategoryLabels = {};
  Map<String, Map<String, String>> _customCategories = {};
  bool _onboardingCompleted = false;
  String? _onboardingGoal;
  String? _onboardingFrequency;
  bool? _onboardingWantsGoal;
  String _userName = '';

  String get currency => _currency;
  String get numberLocale => _numberLocale;
  double get monthlyBudgetLimit => _monthlyBudgetLimit;
  int? get defaultAccountId => _defaultAccountId;
  String get dateFormat => _dateFormat;
  String get weekStartDay => _weekStartDay;
  Map<String, String> get customCategoryLabels => _customCategoryLabels;
  Map<String, Map<String, String>> get customCategories => _customCategories;
  bool get onboardingCompleted => _onboardingCompleted;
  String? get onboardingGoal => _onboardingGoal;
  String? get onboardingFrequency => _onboardingFrequency;
  bool? get onboardingWantsGoal => _onboardingWantsGoal;
  String get userName => _userName;

  static const _keyCurrency = 'currency';
  static const _keyNumberLocale = 'numberLocale';
  static const _keyBudgetLimit = 'monthlyBudgetLimit';
  static const _keyDefaultAccount = 'defaultAccountId';
  static const _keyDateFormat = 'dateFormat';
  static const _keyWeekStart = 'weekStartDay';
  static const _keyCategoryLabels = 'customCategoryLabels';
  static const _keyCustomCategories = 'customCategories';
  static const _keyOnboardingCompleted = 'onboardingCompleted';
  static const _keyOnboardingGoal = 'onboardingGoal';
  static const _keyOnboardingFrequency = 'onboardingFrequency';
  static const _keyOnboardingWantsGoal = 'onboardingWantsGoal';
  static const _keyUserName = 'userName';

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString(_keyCurrency) ?? 'ARS';
    _numberLocale = prefs.getString(_keyNumberLocale) ?? 'es_AR';
    formatter.setNumberLocale(_numberLocale);
    _monthlyBudgetLimit = prefs.getDouble(_keyBudgetLimit) ?? 0;
    _defaultAccountId = prefs.getInt(_keyDefaultAccount);
    _dateFormat = prefs.getString(_keyDateFormat) ?? 'DD/MM';
    _weekStartDay = prefs.getString(_keyWeekStart) ?? 'Lunes';
    final labelsJson = prefs.getString(_keyCategoryLabels);
    if (labelsJson != null) {
      _customCategoryLabels = Map<String, String>.from(jsonDecode(labelsJson));
    }
    final catsJson = prefs.getString(_keyCustomCategories);
    if (catsJson != null) {
      final decoded = jsonDecode(catsJson);
      _customCategories = (decoded as Map<String, dynamic>).map((k, v) =>
          MapEntry(k, Map<String, String>.from(v as Map)));
    }
    _onboardingCompleted = prefs.getBool(_keyOnboardingCompleted) ?? false;
    _onboardingGoal = prefs.getString(_keyOnboardingGoal);
    _onboardingFrequency = prefs.getString(_keyOnboardingFrequency);
    _onboardingWantsGoal = prefs.getBool(_keyOnboardingWantsGoal);
    _userName = prefs.getString(_keyUserName) ?? '';
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    _currency = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, value);
    notifyListeners();
  }

  Future<void> updateNumberLocale(String value) async {
    _numberLocale = value;
    formatter.setNumberLocale(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNumberLocale, value);
    notifyListeners();
  }

  Future<void> setMonthlyBudgetLimit(double value) async {
    _monthlyBudgetLimit = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBudgetLimit, value);
    notifyListeners();
  }

  Future<void> setDefaultAccountId(int? id) async {
    _defaultAccountId = id;
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setInt(_keyDefaultAccount, id);
    } else {
      await prefs.remove(_keyDefaultAccount);
    }
    notifyListeners();
  }

  Future<void> setDateFormat(String value) async {
    _dateFormat = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDateFormat, value);
    notifyListeners();
  }

  Future<void> setWeekStartDay(String value) async {
    _weekStartDay = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWeekStart, value);
    notifyListeners();
  }

  Future<void> setCustomCategoryLabel(TransactionCategory cat, String label) async {
    _customCategoryLabels[cat.name] = label;
    await _saveCategoryLabels();
    notifyListeners();
  }

  Future<void> resetCustomCategoryLabel(TransactionCategory cat) async {
    _customCategoryLabels.remove(cat.name);
    await _saveCategoryLabels();
    notifyListeners();
  }

  Future<void> _saveCategoryLabels() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCategoryLabels, jsonEncode(_customCategoryLabels));
  }

  Future<void> addCustomCategory(String name, String icon, String color) async {
    _customCategories[name] = {'icon': icon, 'color': color};
    await _saveCustomCategories();
    notifyListeners();
  }

  Future<void> editCustomCategory(String oldName, String newName, String icon, String color) async {
    _customCategories.remove(oldName);
    _customCategories[newName] = {'icon': icon, 'color': color};
    await _saveCustomCategories();
    notifyListeners();
  }

  Future<void> deleteCustomCategory(String name) async {
    _customCategories.remove(name);
    await _saveCustomCategories();
    notifyListeners();
  }

  Future<void> _saveCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomCategories, jsonEncode(_customCategories));
  }

  String getCategoryLabel(TransactionCategory cat) {
    return _customCategoryLabels[cat.name] ?? cat.label;
  }

  String get currencySymbol {
    switch (_currency) {
      case 'USD': return r'$';
      case 'EUR': return r'€';
      case 'ARS': return r'$';
      default: return r'$';
    }
  }

  String get currencyCode {
    switch (_currency) {
      case 'USD': return 'en_US';
      case 'EUR': return 'de_DE';
      case 'ARS': return 'es_AR';
      default: return 'es_AR';
    }
  }

  Future<void> setOnboardingCompleted(bool value) async {
    _onboardingCompleted = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, value);
    notifyListeners();
  }

  Future<void> setOnboardingGoal(String? value) async {
    _onboardingGoal = value;
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(_keyOnboardingGoal, value);
    } else {
      await prefs.remove(_keyOnboardingGoal);
    }
    notifyListeners();
  }

  Future<void> setOnboardingFrequency(String? value) async {
    _onboardingFrequency = value;
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(_keyOnboardingFrequency, value);
    } else {
      await prefs.remove(_keyOnboardingFrequency);
    }
    notifyListeners();
  }

  Future<void> setOnboardingWantsGoal(bool? value) async {
    _onboardingWantsGoal = value;
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setBool(_keyOnboardingWantsGoal, value);
    } else {
      await prefs.remove(_keyOnboardingWantsGoal);
    }
    notifyListeners();
  }

  Future<void> setUserName(String value) async {
    _userName = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, value);
    notifyListeners();
  }
}
