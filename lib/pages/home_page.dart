// pages/home_page.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../views/expense_title.dart';
import '../services/expense_service.dart';
import 'add_expense_page.dart';
import 'stats_page.dart';
import 'monthly_overview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExpenseService _service = ExpenseService();
  List<Expense> _expenses = [];
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final expenses = await _service.getAllExpenses();
    final total = await _service.getTotal();
    setState(() {
      _expenses = expenses;
      _total = total;
    });
  }

  Future<void> _deleteExpense(String id) async {
    await _service.deleteExpense(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Výdaje'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyOverviewPage()),
              );
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsPage()),
              );
              _loadData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Celkem: ${_total.toStringAsFixed(2)} Kč',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('Zatím žádné výdaje'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (ctx, i) => ExpenseTile(
                      expense: _expenses[i],
                      onDelete: () => _deleteExpense(_expenses[i].id),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );
          _loadData(); // po návratu z formuláře znovu načteme data
        },
      ),
    );
  }
}
