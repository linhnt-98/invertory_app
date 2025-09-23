import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}

// ==========================
// Inventory Item Model
// ==========================
class InventoryItem {
  String name;
  int quantity;
  String category;

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.category,
  });
}

// ==========================
// Home Screen
// ==========================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of inventory items
  List<InventoryItem> inventoryList = [];

  // Controllers for input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  // Function to add a new item
  void addItem(String name, int quantity, String category) {
    setState(() {
      inventoryList.add(InventoryItem(
        name: name,
        quantity: quantity,
        category: category,
      ));
    });
  }

  // Function to update an existing item
  void updateItem(String name, int quantity, String category, int index) {
    setState(() {
      inventoryList[index] =
          InventoryItem(name: name, quantity: quantity, category: category);
    });
  }

  // Function to delete an item
  void deleteItem(int index) {
    setState(() {
      inventoryList.removeAt(index);
    });
  }

  // Show dialog for add/edit
  void showItemDialog({int? index}) {
    if (index != null) {
      // Editing
      nameController.text = inventoryList[index].name;
      qtyController.text = inventoryList[index].quantity.toString();
      categoryController.text = inventoryList[index].category;
    } else {
      // Adding
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

  // ==========================
  // Build UI
  // ==========================
  @override
  Widget build(BuildContext context) {
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
        child: ListView.builder(
          itemCount: inventoryList.length,
          itemBuilder: (context, index) {
            final item = inventoryList[index];
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
                      onPressed: () => showItemDialog(index: index),
                      icon: Icon(Icons.edit, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => deleteItem(index),
                      icon: Icon(Icons.delete, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
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
