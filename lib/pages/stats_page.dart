// pages/stats_page.dart
import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../utils/date_helper.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ExpenseService _service = ExpenseService();

  Map<String, double> _overallTotals = {};
  Map<String, Map<String, double>> _byMonthTotals = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final overall = await _service.getTotalsByCategory();
    final byMonth = await _service.getCategoryTotalsByMonth();
    setState(() {
      _overallTotals = overall;
      _byMonthTotals = byMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final months = _byMonthTotals.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiky'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Celkové'),
            Tab(text: 'Podle měsíců'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _overallTotals.isEmpty
              ? const Center(child: Text('Žádná data'))
              : ListView(
                  children: _overallTotals.entries
                      .map(
                        (e) => ListTile(
                          title: Text(e.key),
                          trailing: Text('${e.value.toStringAsFixed(2)} Kč'),
                        ),
                      )
                      .toList(),
                ),
          months.isEmpty
              ? const Center(child: Text('Žádná data'))
              : ListView(
                  children: months.map((month) {
                    final cats = _byMonthTotals[month]!;
                    return ExpansionTile(
                      title: Text(
                        monthLabel(month),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: cats.entries
                          .map(
                            (e) => ListTile(
                              title: Text(e.key),
                              trailing: Text(
                                '${e.value.toStringAsFixed(2)} Kč',
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
