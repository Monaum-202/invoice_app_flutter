import 'package:flutter/material.dart';
import 'package:invo/invoice_screen.dart';
import 'package:invo/new_invoice_screen.dart';
import 'package:provider/provider.dart';
import 'models/invoice_data.dart' as model;
import 'bottomNav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'invoice_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider<model.InvoiceData>(
      create: (context) => model.InvoiceData(),
      child: const InvoiceApp(), // Ensure this is a MaterialApp or wraps one
    ),
  );
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          final loggedIn = snapshot.data ?? false;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
            ),
            home: loggedIn ? HomeScreen(initialIndex: 0) : LoginPage(),
            routes: {
              '/invoice': (context) => HomeScreen(initialIndex: 0),
              '/login': (context) => LoginPage(),
              '/newInvoice': (context) => HomeScreen(initialIndex: 1),
            },
          );
        }
      },
    );
  }
}
