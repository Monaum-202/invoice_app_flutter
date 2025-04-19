  // Future<void> _saveBusinessInfo() async {
  //   // Check if client email is provided

  //   if (_userData == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'User information not found. Please try logging in again.',
  //         ),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }


  //   final invoice = Invoice(
      
  //     companyName: companyName,
  //     createdBy: _userData!['userName'],
  //     items:
  //         formattedItems
  //             .map(
  //               (item) => InvoiceItem(
  //                 itemName: item['itemName'] ?? '',
  //                 quantity: item['quantity'].toInt(),
  //                 unitPrice: item['unitPrice'],
  //                 totalPrice: item['totalPrice'],
  //                 tax: item['tax'],
  //                 taxAmount: item['taxAmount'],
  //               ),
  //             )
  //             .toList(),
  //   );

  //   try {
  //     final invoiceService = InvoiceService();
  //     final newInvoice = await invoiceService.createInvoice(invoice);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Invoice created successfully!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );

  //     // Navigate back to previous screen
  //     Navigator.pop(context, newInvoice);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to create invoice: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }