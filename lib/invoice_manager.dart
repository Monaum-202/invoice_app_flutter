import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/invoice_data.dart' as model;

class InvoiceManager extends StatelessWidget {
  const InvoiceManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Manager'),
      ),
      body: Consumer<model.InvoiceData>(
        builder: (context, invoiceData, child) {
          return ListView.builder(
            itemCount: invoiceData.invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoiceData.invoices[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            invoice['invoiceNumber'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: invoice['status'] == 'Unpaid' 
                                ? Colors.red.shade100 
                                : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              invoice['status'] ?? '',
                              style: TextStyle(
                                color: invoice['status'] == 'Unpaid' 
                                  ? Colors.red.shade900 
                                  : Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Client: ${invoice['clientName'] ?? ''}',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal: ৳${invoice['amount'] ?? '0.00'}'),
                          Text(
                            'Due: ৳${(double.tryParse(invoice['amount'] ?? '0') ?? 0.0).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Created: ${invoice['createdAt'] ?? ''}'),
                          Text('Due: ${invoice['dueDate'] ?? ''}'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/newInvoice');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
