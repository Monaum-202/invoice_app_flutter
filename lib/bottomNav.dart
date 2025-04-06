import 'package:flutter/material.dart';
import 'package:invo/new_invoice_screen.dart';
import 'product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    NewInvoiceScreen(),
    Center(child: Text("Estimates Screen")),
    Center(child: Text("Clients Screen")),
    ProductListPage(),
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
                  icon: Icon(Icons.request_quote), // Better suited for invoices
                  label: "Invoices",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit_document), // Represents editing/estimates
                  label: "Estimates",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group), // Represents a list of clients
                  label: "Clients",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.devices_other), // More relevant for products/electronics
                  label: "Products",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings), // More options/settings
                  label: "More",
                ),

        ],
      ),
    );
  }
}