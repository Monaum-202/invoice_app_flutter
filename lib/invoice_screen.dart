import 'package:flutter/material.dart';

import 'package:invo/services/InvoiceService.dart';
import 'package:invo/invoice_edit.dart';
import 'models/invoice_model.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  _InvoiceListPageState createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  late Future<List<Invoice>> invoices;
  final InvoiceService _invoiceService = InvoiceService();

  @override
  void initState() {
    super.initState();
    invoices = _invoiceService.getAll();
  }

  void _deleteInvoice(int id) async {
    try {
      await _invoiceService.deleteInvoice(id);
      setState(() {
        invoices = _invoiceService.getAll();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invoice deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete invoice')));
    }
  }

  // void _editInvoice(Invoice invoice) async {
  //   final updated = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => EditInvoicePage(invoice: invoice)),
  //   );

  //   if (updated != null) {
  //     setState(() {
  //       invoices = _invoiceService.getAll();
  //     });
  //   }
  // }

  // void _addInvoice() async {
  //   final created = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => EditInvoicePage(invoice: Invoice())),
  //   );

  //   if (created != null) {
  //     setState(() {
  //       invoices = _invoiceService.getAll();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Invoices')),
      body: FutureBuilder<List<Invoice>>(
        future: invoices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) return Center(child: Text('No invoices found'));

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final invoice = data[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(invoice.invoiceNumber ?? 'No Invoice #'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Client: ${invoice.client.name ?? 'N/A'}'),
                      Text('Subtotal: ৳${(invoice.subtotal ?? 0.0).toStringAsFixed(2)}'),
Text('Discount: ৳${(invoice.discountCash ?? 0.0).toStringAsFixed(2)}'),
Text('Discount %: ${(invoice.discountPersentage ?? 0.0).toStringAsFixed(1)}%'),
                      Text('Status: ${invoice.status ?? 'N/A'}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // IconButton(
                      //   icon: Icon(Icons.edit, color: Colors.orange),
                      //   onPressed: () => _editInvoice(invoice),
                      // ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteInvoice(invoice.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _addInvoice,
      //   child: Icon(Icons.add),
      //   tooltip: 'Add New Invoice',
      //   backgroundColor: Colors.blue,
      // ),
    );
  }
}
