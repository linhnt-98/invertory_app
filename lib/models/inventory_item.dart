
class StockHistory {
  final DateTime date;
  final String action; // "in" or "out"
  final int change;

  StockHistory({required this.date, required this.action, required this.change});
}

class InventoryItem {
  String name;
  int quantity;
  String category;
  List<StockHistory> history;

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.category,
    List<StockHistory>? history,
  }) : history = history ?? [];
}
