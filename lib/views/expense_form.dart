// views/expense_form.dart
import 'package:flutter/material.dart';

class ExpenseForm extends StatefulWidget {
  final void Function(
    double amount,
    String category,
    DateTime date,
    String? note,
  )
  onSubmit;
  final DateTime? initialDate;

  const ExpenseForm({required this.onSubmit, this.initialDate, super.key});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = 'Potraviny';
  late DateTime _date;

  final _categories = [
    'Bydlení',
    'Doprava',
    'Drogerie',
    'Potraviny',
    'Zábava',
    'Ostatní',
  ];

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Částka (Kč)'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Zadej částku';
              if (double.tryParse(value) == null) return 'Neplatné číslo';
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Kategorie'),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Datum: ${_date.day}.${_date.month}.${_date.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Poznámka (volitelné)',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  double.parse(_amountController.text),
                  _category,
                  _date,
                  _noteController.text.isEmpty ? null : _noteController.text,
                );
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Uložit výdaj'),
            ),
          ),
        ],
      ),
    );
  }
}
