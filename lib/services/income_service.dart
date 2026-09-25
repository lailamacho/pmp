// services/income_service.dart
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class IncomeService {
  static final IncomeService _instance = IncomeService._internal();
  factory IncomeService() => _instance;
  IncomeService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> setIncome(String monthKey, double amount) async {
    final db = await _dbHelper.database;
    await db.insert('incomes', {
      'monthKey': monthKey,
      'amount': amount,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<double> getIncome(String monthKey) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'incomes',
      where: 'monthKey = ?',
      whereArgs: [monthKey],
    );
    if (maps.isEmpty) return 0.0;
    return maps.first['amount'] as double;
  }

  Future<Map<String, double>> getAllIncomes() async {
    final db = await _dbHelper.database;
    final maps = await db.query('incomes');
    return {
      for (final m in maps) m['monthKey'] as String: m['amount'] as double,
    };
  }
}
