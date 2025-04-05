import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/invoice_data.dart' as model;
import 'new_invoice_screen.dart';
import 'bottomNav.dart';

void main() {
  runApp(
    ChangeNotifierProvider<model.InvoiceData>(
      create: (context) => model.InvoiceData(),
      child: const InvoiceApp(),
    ),
  );
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: HomeScreen(),
      routes: {
        '/newInvoice': (context) => NewInvoiceScreen(),
      },
    );
  }
}
