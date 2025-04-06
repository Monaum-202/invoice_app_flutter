// import 'package:flutter/material.dart';
// import 'package:invo/models/business_info.dart';
// import 'package:invo/models/client_model.dart';
// import 'package:invo/models/invoice_item.dart';
// import 'models/invoice_model.dart';

// class EditInvoicePage extends StatefulWidget {
//   final Invoice invoice;

//   EditInvoicePage({required this.invoice});

//   @override
//   _EditInvoicePageState createState() => _EditInvoicePageState();
// }

// class _EditInvoicePageState extends State<EditInvoicePage> {
//   final _formKey = GlobalKey<FormState>();
//   late Invoice invoice;

//   @override
//   void initState() {
//     super.initState();
//     invoice = widget.invoice;
//     invoice.items ??= [];
//     invoice.client ??= Client();
//     invoice.businessInfo ??= BusinessInfo();
//   }

//   void _addItem() {
//     setState(() {
//       invoice.items!.add(InvoiceItem());
//     });
//   }

//   void _removeItem(int index) {
//     setState(() {
//       invoice.items!.removeAt(index);
//     });
//   }

//   void _saveInvoice() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       Navigator.pop(context, invoice);
//     }
//   }

//   Widget _buildItemFields(int index) {
//     final item = invoice.items![index];
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 6),
//       child: Padding(
//         padding: EdgeInsets.all(8),
//         child: Column(
//           children: [
//             TextFormField(
//               decoration: InputDecoration(labelText: 'Item Name'),
//               initialValue: item.itemName,
//               onSaved: (value) => item.itemName = value ?? '',
//             ),
//             TextFormField(
//               decoration: InputDecoration(labelText: 'Quantity'),
//               keyboardType: TextInputType.number,
//               initialValue: item.quantity?.toString(),
//               onSaved: (value) => item.quantity = int.tryParse(value ?? '0'),
//             ),
//             TextFormField(
//               decoration: InputDecoration(labelText: 'Unit Price'),
//               keyboardType: TextInputType.number,
//               initialValue: item.unitPrice?.toString(),
//               onSaved: (value) => item.unitPrice = double.tryParse(value ?? '0.0'),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () => _removeItem(index),
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildClientFields() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Client Info', style: TextStyle(fontWeight: FontWeight.bold)),
//         TextFormField(
//           initialValue: invoice.client?.name,
//           decoration: InputDecoration(labelText: 'Client Name'),
//           onSaved: (value) => invoice.client?.name = value ?? '',
//         ),
//         TextFormField(
//           initialValue: invoice.client?.email,
//           decoration: InputDecoration(labelText: 'Client Email'),
//           onSaved: (value) => invoice.client?.email = value ?? '',
//         ),
//         TextFormField(
//           initialValue: invoice.client?.phone,
//           decoration: InputDecoration(labelText: 'Client Phone'),
//           onSaved: (value) => invoice.client?.phone = value ?? '',
//         ),
//       ],
//     );
//   }

//   Widget _buildBusinessInfoFields() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Business Info', style: TextStyle(fontWeight: FontWeight.bold)),
//         TextFormField(
//           initialValue: invoice.businessInfo?.businessName,
//           decoration: InputDecoration(labelText: 'Business Name'),
//           onSaved: (value) => invoice.businessInfo?.businessName = value ?? '',
//         ),
//         TextFormField(
//           initialValue: invoice.businessInfo?.email,
//           decoration: InputDecoration(labelText: 'Business Email'),
//           onSaved: (value) => invoice.businessInfo?.email = value ?? '',
//         ),
//         TextFormField(
//           initialValue: invoice.businessInfo?.phone,
//           decoration: InputDecoration(labelText: 'Business Phone'),
//           onSaved: (value) => invoice.businessInfo?.phone = value ?? '',
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Invoice'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: _saveInvoice,
//           )
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               _buildClientFields(),
//               SizedBox(height: 20),
//               _buildBusinessInfoFields(),
//               SizedBox(height: 20),
//               Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
//               ...List.generate(invoice.items!.length, _buildItemFields),
//               TextButton.icon(
//                 icon: Icon(Icons.add),
//                 label: Text('Add Item'),
//                 onPressed: _addItem,
//               ),
//               SizedBox(height: 20),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Subtotal'),
//                 keyboardType: TextInputType.number,
//                 initialValue: invoice.subtotal?.toString(),
//                 onSaved: (value) => invoice.subtotal = double.tryParse(value ?? '0'),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Discount (%)'),
//                 keyboardType: TextInputType.number,
//                 initialValue: invoice.discountPersentage?.toString(),
//                 onSaved: (value) => invoice.discountPersentage = double.tryParse(value ?? '0'),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Discount Cash'),
//                 keyboardType: TextInputType.number,
//                 initialValue: invoice.discountCash?.toString(),
//                 onSaved: (value) => invoice.discountCash = double.tryParse(value ?? '0'),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Total Amount'),
//                 keyboardType: TextInputType.number,
//                 initialValue: invoice.totalAmount?.toString(),
//                 onSaved: (value) => invoice.totalAmount = double.tryParse(value ?? '0'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
