// pages/add_expense_page.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../views/expense_form.dart';

class AddExpensePage extends StatelessWidget {
  final DateTime? initialDate;

  const AddExpensePage({this.initialDate, super.key});

  @override
  Widget build(BuildContext context) {
    final service = ExpenseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Nový výdaj')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpenseForm(
          initialDate: initialDate,
          onSubmit: (amount, category, date, note) async {
            await service.addExpense(
              Expense(
                amount: amount,
                category: category,
                date: date,
                note: note,
              ),
            );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
