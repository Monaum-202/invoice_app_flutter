import 'package:flutter/material.dart';
import 'invoice_manager.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    InvoiceManager(),
    Center(child: Text("Estimates Screen")),
    Center(child: Text("Clients Screen")),
    Center(child: Text("Items Screen")),
    Center(child: Text("More Options Screen")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Invoices",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: "Estimates",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Clients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Items",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: "More",
          ),
        ],
      ),
    );
  }
}