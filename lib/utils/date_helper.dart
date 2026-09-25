// utils/date_helper.dart
/// Vrátí klíč měsíce ve formátu 'yyyy-MM' (pro řazení a jako mapový klíč)
String monthKeyFromDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';

/// Převede klíč 'yyyy-MM' na čitelný popisek "Květen 2025"
String monthLabel(String monthKey) {
  final parts = monthKey.split('-');
  final year = parts[0];
  final month = int.parse(parts[1]);
  const names = [
    'Leden',
    'Únor',
    'Březen',
    'Duben',
    'Květen',
    'Červen',
    'Červenec',
    'Srpen',
    'Září',
    'Říjen',
    'Listopad',
    'Prosinec',
  ];
  return '${names[month - 1]} $year';
}
