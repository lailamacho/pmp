// pages/monht_detail_page.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../utils/date_helper.dart';
import '../views/expense_title.dart';
import 'add_expense_page.dart';

class MonthDetailPage extends StatefulWidget {
  final String monthKey;
  const MonthDetailPage({required this.monthKey, super.key});

  @override
  State<MonthDetailPage> createState() => _MonthDetailPageState();
}

class _MonthDetailPageState extends State<MonthDetailPage> {
  final ExpenseService _expenseService = ExpenseService();
  final IncomeService _incomeService = IncomeService();
  final _incomeController = TextEditingController();

  List<Expense> _expenses = [];
  Map<String, double> _categoryTotals = {};
  double _income = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final grouped = await _expenseService.getExpensesGroupedByMonth();
    final catTotals = await _expenseService.getCategoryTotalsByMonth();
    final income = await _incomeService.getIncome(widget.monthKey);
    setState(() {
      _expenses = grouped[widget.monthKey] ?? [];
      _categoryTotals = catTotals[widget.monthKey] ?? {};
      _income = income;
      _incomeController.text = income == 0 ? '' : income.toString();
    });
  }

  double get _totalExpenses =>
      _expenses.fold<double>(0.0, (s, e) => s + e.amount);
  double get _balance => _income - _totalExpenses;

  Future<void> _saveIncome() async {
    final value = double.tryParse(_incomeController.text) ?? 0;
    await _incomeService.setIncome(widget.monthKey, value);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Příjem uložen')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(monthLabel(widget.monthKey))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _incomeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Příjem za měsíc (Kč)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveIncome,
                child: const Text('Uložit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: _balance >= 0 ? Colors.green[50] : Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Výdaje celkem: ${_totalExpenses.toStringAsFixed(2)} Kč',
                  ),
                  Text('Příjem: ${_income.toStringAsFixed(2)} Kč'),
                  const Divider(),
                  Text(
                    'Bilance: ${_balance >= 0 ? '+' : ''}${_balance.toStringAsFixed(2)} Kč',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _balance >= 0
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Podle kategorií',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ..._categoryTotals.entries.map(
            (e) => ListTile(
              title: Text(e.key),
              trailing: Text('${e.value.toStringAsFixed(2)} Kč'),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Jednotlivé výdaje',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ..._expenses.map(
            (e) => ExpenseTile(
              expense: e,
              onDelete: () async {
                await _expenseService.deleteExpense(e.id);
                await _load();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final parts = widget.monthKey.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddExpensePage(initialDate: DateTime(year, month, 1)),
            ),
          );
          _load();
        },
      ),
    );
  }
}
