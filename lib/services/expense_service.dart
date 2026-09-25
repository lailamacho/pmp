// services/expense_service.dart
import '../models/expense.dart';
import '../utils/date_helper.dart';
import 'database_helper.dart';

class ExpenseService {
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Expense>> getAllExpenses() async {
    final db = await _dbHelper.database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<void> addExpense(Expense expense) async {
    final db = await _dbHelper.database;
    await db.insert('expenses', expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    final db = await _dbHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotal() async {
    final expenses = await getAllExpenses();
    return expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  Future<Map<String, double>> getTotalsByCategory() async {
    final expenses = await getAllExpenses();
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Future<Map<String, List<Expense>>> getExpensesGroupedByMonth() async {
    final expenses = await getAllExpenses();
    final Map<String, List<Expense>> grouped = {};
    for (final e in expenses) {
      final key = monthKeyFromDate(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }
    return grouped; // už seřazeno díky 'date DESC' v getAllExpenses
  }

  Future<Map<String, double>> getMonthlyTotals() async {
    final grouped = await getExpensesGroupedByMonth();
    return grouped.map(
      (key, list) =>
          MapEntry(key, list.fold<double>(0.0, (s, e) => s + e.amount)),
    );
  }

  Future<Map<String, Map<String, double>>> getCategoryTotalsByMonth() async {
    final grouped = await getExpensesGroupedByMonth();
    final Map<String, Map<String, double>> result = {};
    grouped.forEach((month, list) {
      final Map<String, double> catTotals = {};
      for (final e in list) {
        catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
      }
      result[month] = catTotals;
    });
    return result;
  }
}
