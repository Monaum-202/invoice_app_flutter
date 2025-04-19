import 'package:flutter/material.dart';
import 'package:invo/invoice_screen.dart';
import 'package:invo/more_screen.dart';
import 'package:invo/new_invoice_screen.dart';
import 'product_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    InvoiceListPage(),
    Center(child: Text("Estimates Screen")),
    Center(child: Text("Clients Screen")),
    ProductListPage(),
    MoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
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