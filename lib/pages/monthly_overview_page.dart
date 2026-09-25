// pages/monthly_overview_page.dart
import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../utils/date_helper.dart';
import 'month_detail_page.dart';

class MonthlyOverviewPage extends StatefulWidget {
  const MonthlyOverviewPage({super.key});

  @override
  State<MonthlyOverviewPage> createState() => _MonthlyOverviewPageState();
}

class _MonthlyOverviewPageState extends State<MonthlyOverviewPage> {
  final ExpenseService _expenseService = ExpenseService();
  final IncomeService _incomeService = IncomeService();

  Map<String, double> _monthlyExpenses = {};
  Map<String, double> _incomes = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final expenses = await _expenseService.getMonthlyTotals();
    final incomes = await _incomeService.getAllIncomes();
    setState(() {
      _monthlyExpenses = expenses;
      _incomes = incomes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final months = {..._monthlyExpenses.keys, ..._incomes.keys}.toList()
      ..sort(
        (a, b) => b.compareTo(a),
      ); // 'yyyy-MM' -> lexikografické řazení funguje

    return Scaffold(
      appBar: AppBar(title: const Text('Měsíční přehled')),
      body: months.isEmpty
          ? const Center(child: Text('Zatím žádná data'))
          : ListView.builder(
              itemCount: months.length,
              itemBuilder: (ctx, i) {
                final key = months[i];
                final expenseTotal = _monthlyExpenses[key] ?? 0.0;
                final income = _incomes[key] ?? 0.0;
                final balance = income - expenseTotal;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      monthLabel(key),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Výdaje: ${expenseTotal.toStringAsFixed(2)} Kč • Příjem: ${income.toStringAsFixed(2)} Kč',
                    ),
                    trailing: Text(
                      '${balance >= 0 ? '+' : ''}${balance.toStringAsFixed(2)} Kč',
                      style: TextStyle(
                        color: balance >= 0
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MonthDetailPage(monthKey: key),
                        ),
                      );
                      _load();
                    },
                  ),
                );
              },
            ),
    );
  }
}
