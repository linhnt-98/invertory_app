import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<InventoryItem> inventoryList = [];
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  void addItem(String name, int quantity, String category) {
    setState(() {
      final item = InventoryItem(
        name: name,
        quantity: quantity,
        category: category,
      );
      item.history.add(StockHistory(
        date: DateTime.now(),
        action: "in",
        change: quantity,
      ));
      inventoryList.add(item);
    });
  }

  void updateItem(String name, int quantity, String category, int index) {
    setState(() {
      final oldItem = inventoryList[index];
      final change = quantity - oldItem.quantity;
      final action = change >= 0 ? "in" : "out";
      oldItem.history.add(StockHistory(
        date: DateTime.now(),
        action: action,
        change: change.abs(),
      ));
      inventoryList[index] = InventoryItem(
        name: name,
        quantity: quantity,
        category: category,
        history: oldItem.history,
      );
    });
  }

  void deleteItem(int index) {
    setState(() {
      final item = inventoryList[index];
      if (item.quantity > 0) {
        item.history.add(StockHistory(
          date: DateTime.now(),
          action: "out",
          change: item.quantity,
        ));
      }
      inventoryList.removeAt(index);
    });
  }

  void showItemDialog({int? index}) {
    if (index != null) {
      nameController.text = inventoryList[index].name;
      qtyController.text = inventoryList[index].quantity.toString();
      categoryController.text = inventoryList[index].category;
    } else {
      nameController.clear();
      qtyController.clear();
      categoryController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "Add Item" : "Edit Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: qtyController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: "Category"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final name = nameController.text;
                final qty = int.tryParse(qtyController.text) ?? 0;
                final category = categoryController.text;
                if (index == null) {
                  addItem(name, qty, category);
                } else {
                  updateItem(name, qty, category, index);
                }
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void showHistoryDialog(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        int runningQty = 0;
        List<Widget> historyWidgets = [];
        for (int i = 0; i < item.history.length; i++) {
          final h = item.history[i];
          if (h.action == "in") {
            runningQty += h.change;
          } else {
            runningQty -= h.change;
          }
          final formattedDate = "${h.date.year}-${h.date.month.toString().padLeft(2, '0')}-${h.date.day.toString().padLeft(2, '0')} ${h.date.hour.toString().padLeft(2, '0')}:${h.date.minute.toString().padLeft(2, '0')}";
          historyWidgets.add(
            Card(
              color: h.action == "in" ? Colors.green[100] : Colors.red[100],
              margin: EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(
                  h.action == "in" ? Icons.arrow_downward : Icons.arrow_upward,
                  color: h.action == "in" ? Colors.green : Colors.red,
                ),
                title: Text(
                  h.action == "in" ? "Stock In" : "Stock Out",
                  style: TextStyle(
                    color: h.action == "in" ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Qty Change: ${h.change}"),
                    Text("Date: $formattedDate"),
                    Text("Quantity After Change: $runningQty"),
                  ],
                ),
              ),
            ),
          );
        }
        return AlertDialog(
          title: Text("Stock History for ${item.name}"),
          content: SizedBox(
            width: 350,
            child: item.history.isEmpty
                ? Text("No history available.")
                : SingleChildScrollView(
                    child: Column(
                      children: historyWidgets,
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<InventoryItem> filteredList = inventoryList.where((item) {
      final query = searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inventory App",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search by name or category",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: filteredList.isEmpty
                  ? Center(child: Text("No items found."))
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final actualIndex = inventoryList.indexOf(item);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          color: Colors.green,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(15),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Qty: ${item.quantity}",
                                    style: TextStyle(color: Colors.white70)),
                                Text("Category: ${item.category}",
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => showHistoryDialog(item),
                                  icon: Icon(Icons.history, color: Colors.white),
                                  tooltip: "View Stock History",
                                ),
                                IconButton(
                                  onPressed: () => showItemDialog(index: actualIndex),
                                  icon: Icon(Icons.edit, color: Colors.white),
                                ),
                                IconButton(
                                  onPressed: () => deleteItem(actualIndex),
                                  icon: Icon(Icons.delete, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () => showItemDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
