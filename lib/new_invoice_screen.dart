import 'package:flutter/material.dart';
import 'package:invo/models/business_info.dart';
import 'package:invo/models/client_model.dart';
import 'package:invo/models/invoice_item.dart';
import 'package:invo/models/invoice_model.dart';
import 'package:invo/services/InvoiceService.dart';
import 'package:invo/services/ProductService.dart';
import 'package:invo/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'models/invoice_data.dart' as model;

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key});

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  String clientName = '';
  String amount = '0.00';
  String status = 'Unpaid';
  String template = 'Default';
  String language = 'English';
  Map<String, String> businessInfo = {
    'businessName': '',
    'address': '',
    'phone': '',
    'email': '',
    'taxId': '',
    'website': '',
  };

  Map<String, String> clientInfo = {
    'name': '',
    'email': '',
    'phone': '',
    'nid': '',
    'address': '',
  };

  String companyName = '';
  String terms = '';
  String paymentMethod = '';
  final List<Map<String, dynamic>> items = [];
  final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy');

  double _discountPercentage = 0.0;
  double _discountAmount = 0.0;
  double _shipping = 0.0;
  double _advancePaid = 0.0;
  double _paidAmount = 0.0;
  
  final double _taxRate = 0.15;
  int _invoiceNumber = 1;

  DateTime _createdDate = DateTime.now();
  DateTime? _dueDate;  // Changed to nullable and removed default value

  @override
  void initState() {
    super.initState();
    print('=== Initial Client Info ===');
    print(clientInfo);
  }

  @override
  Widget build(BuildContext context) {
    print('=== Build Client Info ===');
    print(clientInfo);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('New Invoice'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildSection(
                context,
                'Templates',
                template,
                Icons.description,
                onTap:
                    () => _showOptionsDialog('Select Template', [
                      'Default',
                      'Professional',
                      'Simple',
                    ], (value) => setState(() => template = value)),
              ),
              // _buildSection(context, 'Language', language, Icons.language,
              //   onTap: () => _showOptionsDialog('Select Language', ['English', 'Bengali'],
              //     (value) => setState(() => language = value))),
              
              _buildInvoiceInfo(),
              
              // _buildSection(context, 'Bill To', clientName.isEmpty ? 'Add Client' : clientName, Icons.person,
              //   onTap: () => _showInputDialog('Client Name', clientName,
              //     (value) => setState(() => clientName = value))),
              _buildClientInfo(),
              _buildSection(
                context,
                'Company Name',
                companyName.isEmpty ? 'Add Company Name' : companyName,
                Icons.assignment,
                onTap:
                    () => _showInputDialog(
                      'Company Name',
                      companyName,
                      (value) => setState(() => companyName = value),
                    ),
              ),
              _buildItemsSection(),
              _buildTotals(),
              // _buildSection(context, 'Currency', 'BDT ৳', Icons.attach_money),
              _buildSection(context, 'Signature', '', Icons.edit),
              _buildSection(
                context,
                'Terms & Conditions',
                terms.isEmpty ? 'Add Terms & Conditions' : terms,
                Icons.factory,
                onTap:
                    () => _showInputDialog(
                      'Terms & Conditions',
                      terms,
                      (value) => setState(() => terms = value),
                    ),
              ),
              _buildSection(
                context,
                'Payment Method',
                paymentMethod.isEmpty ? 'Add Payment Method' : paymentMethod,
                Icons.payment,
                onTap:
                    () => _showOptionsDialog('Payment Method', [
                      'Cash',
                      'Bank Transfer',
                      'Credit Card',
                    ], (value) => setState(() => paymentMethod = value)),
              ),
              _buildSection(
                context,
                'Mark As',
                status,
                Icons.label,
                onTap:
                    () => _showOptionsDialog('Status', [
                      'Unpaid',
                      'Paid',
                      'Partially Paid',
                    ], (value) => setState(() => status = value)),
              ),
              _buildSection(context, 'Attachments', '', Icons.attach_file),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _previewInvoice(),
                      child: Text('Preview'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveInvoice,
                      child: Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      leading: Icon(icon),
      onTap: onTap,
    );
  }

  Widget _buildInvoiceInfo() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Invoice Info',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // trailing: Text(
            //   'INV${_invoiceNumber.toString().padLeft(6, '0')}',
            //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            // ),
          ),
          ListTile(
            title: Row(
              children: [
                Text('Created: ${_dateFormat.format(_createdDate)}'),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _createdDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _createdDate = date;
                        // Automatically update due date to 7 days after created date
                        _dueDate = date.add(Duration(days: 7));
                      });
                    }
                  },
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Text('Due: ${_dueDate != null ? _dateFormat.format(_dueDate!) : 'Not Set'}'),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? _createdDate,
                      firstDate: _createdDate, // Can't be before created date
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _dueDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildBusinessInfo() {
  //   return Card(
  //     child: Column(
  //       children: [
  //         ListTile(
  //           title: Text(
  //             'Business Information',
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           trailing: ElevatedButton.icon(
  //             onPressed: _editBusinessInfo,
  //             icon: Icon(Icons.edit),
  //             label: Text('Edit'),
  //           ),
  //         ),
  //         if (businessInfo['businessName']?.isNotEmpty ?? false)
  //           ListTile(
  //             title: Text(businessInfo['businessName'] ?? ''),
  //             subtitle: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 if (businessInfo['address']?.isNotEmpty ?? false)
  //                   Text(businessInfo['address'] ?? ''),
  //                 if (businessInfo['phone']?.isNotEmpty ??
  //                     false || businessInfo['email']!.isNotEmpty ??
  //                     false)
  //                   Text(
  //                     '${businessInfo['phone'] ?? ''} | ${businessInfo['email'] ?? ''}',
  //                   ),
  //                 if (businessInfo['taxId']?.isNotEmpty ?? false)
  //                   Text('Tax ID: ${businessInfo['taxId']}'),
  //                 if (businessInfo['website']?.isNotEmpty ?? false)
  //                   Text(businessInfo['website'] ?? ''),
  //               ],
  //             ),
  //           )
  //         else
  //           ListTile(
  //             title: Text(
  //               'No business information added',
  //               style: TextStyle(color: Colors.grey),
  //             ),
  //             leading: Icon(Icons.business, color: Colors.grey),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // void _editBusinessInfo() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       Map<String, String> tempInfo = Map.from(businessInfo);

  //       return AlertDialog(
  //         title: Text('Edit Business Information'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Business Name'),
  //                 controller: TextEditingController(
  //                   text: tempInfo['businessName'],
  //                 ),
  //                 onChanged: (value) => tempInfo['businessName'] = value,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Address'),
  //                 controller: TextEditingController(text: tempInfo['address']),
  //                 onChanged: (value) => tempInfo['address'] = value,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Phone'),
  //                 controller: TextEditingController(text: tempInfo['phone']),
  //                 keyboardType: TextInputType.phone,
  //                 onChanged: (value) => tempInfo['phone'] = value,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Email'),
  //                 controller: TextEditingController(text: tempInfo['email']),
  //                 keyboardType: TextInputType.emailAddress,
  //                 onChanged: (value) => tempInfo['email'] = value,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Tax ID'),
  //                 controller: TextEditingController(text: tempInfo['taxId']),
  //                 onChanged: (value) => tempInfo['taxId'] = value,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Website'),
  //                 controller: TextEditingController(text: tempInfo['website']),
  //                 keyboardType: TextInputType.url,
  //                 onChanged: (value) => tempInfo['website'] = value,
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               setState(() => businessInfo = tempInfo);
  //               Navigator.pop(context);
  //             },
  //             child: Text('Save'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildClientInfo() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Client Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: ElevatedButton.icon(
              onPressed: _editClientInfo,
              icon: Icon(Icons.edit),
              label: Text('Edit'),
            ),
          ),
          if (clientInfo['name']?.isNotEmpty ?? false)
            ListTile(
              title: Text(clientInfo['name'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (clientInfo['address']?.isNotEmpty ?? false)
                    Text(clientInfo['address'] ?? ''),
                  if (clientInfo['phone']?.isNotEmpty ??
                      false || clientInfo['email']!.isNotEmpty ??
                      false)
                    Text(
                      '${clientInfo['phone'] ?? ''} | ${clientInfo['email'] ?? ''}',
                    ),
                  if (clientInfo['nid']?.isNotEmpty ?? false)
                    Text('NID: ${clientInfo['nid']}'),
                ],
              ),
            )
          else
            ListTile(
              title: Text(
                'No client information added',
                style: TextStyle(color: Colors.grey),
              ),
              leading: Icon(Icons.person, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  void _editClientInfo() {
    showDialog(
      context: context,
      builder: (context) {
        Map<String, String> tempInfo = Map.from(clientInfo);

        return AlertDialog(
          title: Text('Edit Client Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: tempInfo['name']),
                  decoration: InputDecoration(labelText: 'Client Name'),
                  onChanged: (value) => tempInfo['name'] = value,
                ),
                TextField(
                  controller: TextEditingController(text: tempInfo['email']),
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => tempInfo['email'] = value,
                ),
                TextField(
                  controller: TextEditingController(text: tempInfo['phone']),
                  decoration: InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => tempInfo['phone'] = value,
                ),
                TextField(
                  controller: TextEditingController(text: tempInfo['nid']),
                  decoration: InputDecoration(labelText: 'NID (National ID)'),
                  onChanged: (value) => tempInfo['nid'] = value,
                ),
                TextField(
                  controller: TextEditingController(text: tempInfo['address']),
                  decoration: InputDecoration(labelText: 'Address'),
                  onChanged: (value) => tempInfo['address'] = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => clientInfo = tempInfo);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

 Widget _buildItemsSection() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: ElevatedButton.icon(
              onPressed: _addItem,
              icon: Icon(Icons.add),
              label: Text('Add Item'),
            ),
          ),
          if (items.isEmpty)
            ListTile(
              title: Text(
                'No items added',
                style: TextStyle(color: Colors.grey),
              ),
              leading: Icon(Icons.shopping_cart, color: Colors.grey),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final quantity = double.tryParse(item['unit'] ?? '0') ?? 0;
                  final unitPrice = double.tryParse(item['price'] ?? '0') ?? 0;
                  final tax = double.tryParse(item['tax'] ?? '0') ?? 0;
                  final itemTotal = quantity * unitPrice;
                  final taxAmount = itemTotal * tax / 100;

                  return Dismissible(
                    key: Key('item_$index'),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        items.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Item removed')),
                      );
                    },
                    child: ListTile(
                      title: Text(item['name'] ?? 'Item'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${quantity.toStringAsFixed(0)} × ৳${unitPrice.toStringAsFixed(2)}'),
                          if (tax > 0)
                            Text('Tax: ${tax.toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('৳${itemTotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  if (tax > 0)
                                    Text('+ ৳${taxAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text('Total: ৳${(itemTotal + taxAmount).toStringAsFixed(2)}', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.edit, size: 20, color: Colors.blue),
                              onPressed: () => _editItem(index),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    ),
  );
}


  void _editItem(int index) async {
    final item = items[index];
    final unitController = TextEditingController(text: item['unit']);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Item name (read-only)
                TextField(
                  controller: TextEditingController(text: item['name']),
                  decoration: InputDecoration(labelText: 'Item Name'),
                  readOnly: true,
                ),
                // Description (read-only)
                TextField(
                  controller: TextEditingController(text: item['description']),
                  decoration: InputDecoration(labelText: 'Description'),
                  readOnly: true,
                ),
                // Unit input
                TextField(
                  controller: unitController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                // Price (read-only)
                TextField(
                  controller: TextEditingController(text: item['price']),
                  decoration: InputDecoration(labelText: 'Price per Unit'),
                  readOnly: true,
                ),
                // Tax (read-only)
                TextField(
                  controller: TextEditingController(text: item['tax']),
                  decoration: InputDecoration(labelText: 'Tax (%)'),
                  readOnly: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final unit = double.tryParse(unitController.text) ?? 1;
                final price = double.tryParse(item['price'] ?? '0') ?? 0;
                final amount = unit * price;

                setState(() {
                  items[index] = {
                    ...item,
                    'unit': unit.toString(),
                    'amount': amount.toStringAsFixed(2),
                  };
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveInvoice() async {
    final subtotal = _calculateSubtotal();  // This now includes item prices + tax
    final discountPercentage = _discountPercentage;
    final discountAmount = _discountPercentage > 0 
        ? (subtotal * _discountPercentage / 100) 
        : _discountAmount;
    final itemTax = _calculateItemTax();
    final shipping = _shipping;
    
    // Calculate total before payments
    final totalAmount = _calculateTotal(
      subtotal,
      discountAmount,
      shipping,
      0,
      0,
      itemTax  // This won't be added again since it's in subtotal
    );

    final totalPaid = _advancePaid + _paidAmount;
    final dueAmount = totalAmount - totalPaid;

    print('=== Invoice Calculations ===');
    print('Subtotal (including tax): $subtotal');
    print('Item Level Tax (included in subtotal): $itemTax');
    print('Discount Percentage: $discountPercentage%');
    print('Discount Amount: $discountAmount');
    print('Shipping: $shipping');
    print('Total Amount: $totalAmount');
    print('Total Paid: $totalPaid');
    print('Due Amount: $dueAmount');
    print('========================');

    // Convert items to the correct format
    final List<Map<String, dynamic>> formattedItems =
        items.map((item) {
          final quantity = double.tryParse(item['unit'] ?? '0') ?? 0;
          final unitPrice = double.tryParse(item['price'] ?? '0') ?? 0;
          final tax = double.tryParse(item['tax'] ?? '0') ?? 0;
          final itemTotal = quantity * unitPrice;
          final taxAmount = itemTotal * tax / 100;
          
          return {
            'itemName': item['name'] ?? '',
            'quantity': quantity,
            'unitPrice': unitPrice,
            'totalPrice': itemTotal,
            'tax': tax,
            'taxAmount': taxAmount,
          };
        }).toList();

    final invoice = Invoice(
      issueDate: _createdDate,
      subtotal: subtotal,
      totalAmount: totalAmount,
      paidAmount: totalPaid,
      dueAmount: dueAmount,
      discountPersentage: discountPercentage,
      discountCash: _discountAmount,
      status: dueAmount <= 0 ? 'PAID' : status.toUpperCase(),
      dueDate: _dueDate,
      client: Client(
        name: clientInfo['name'] ?? '',
        email: clientInfo['email'] ?? '',
        phone: clientInfo['phone'] ?? '',
        nid: clientInfo['nid'] ?? '',
        address: clientInfo['address'] ?? '',
      ),
      companyName: companyName,
      createdBy: 1,
      items: formattedItems
          .map(
            (item) => InvoiceItem(
              itemName: item['itemName'] ?? '',
              quantity: item['quantity'].toInt(),
              unitPrice: item['unitPrice'],
              totalPrice: item['totalPrice'],
              tax: item['tax'],
              taxAmount: item['taxAmount'],
            ),
          )
          .toList(),
      
    );

    try {
      final invoiceService = InvoiceService();
      final newInvoice = await invoiceService.createInvoice(invoice);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to previous screen
      Navigator.pop(context, newInvoice);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _calculateSubtotal() {
    return items.fold(0.0, (sum, item) {
      final quantity = double.tryParse(item['unit'] ?? '0') ?? 0;
      final unitPrice = double.tryParse(item['price'] ?? '0') ?? 0;
      final tax = double.tryParse(item['tax'] ?? '0') ?? 0;
      final itemTotal = quantity * unitPrice;
      final itemTax = itemTotal * tax / 100;
      return sum + itemTotal + itemTax;  // Include both price and tax in subtotal
    });
  }

  double _calculateItemTax() {
    return items.fold(0.0, (sum, item) {
      final quantity = double.tryParse(item['unit'] ?? '0') ?? 0;
      final unitPrice = double.tryParse(item['price'] ?? '0') ?? 0;
      final tax = double.tryParse(item['tax'] ?? '0') ?? 0;
      final itemTotal = quantity * unitPrice;
      return sum + (itemTotal * tax / 100);
    });
  }

  double _calculateTotal(
    double subtotal,
    double discountAmount,
    double shipping,
    double advancePaid,
    double paidAmount,
    double itemLevelTax,
  ) {
    // Since tax is now included in subtotal, don't add itemLevelTax again
    return subtotal + shipping - discountAmount;
  }

  Widget _buildTotals() {
    final subtotal = _calculateSubtotal();  // This now includes item prices + tax
    final discountPercentage = _discountPercentage;
    final discountAmount = _discountPercentage > 0 
        ? (subtotal * _discountPercentage / 100) 
        : _discountAmount;
    final itemTax = _calculateItemTax();
    final shipping = _shipping;
    final advancePaid = _advancePaid;
    final paidAmount = _paidAmount;
    final total = _calculateTotal(
      subtotal,
      discountAmount,
      shipping,
      0,
      0,
      itemTax  // This won't be added again since it's in subtotal
    );

    final totalPaid = advancePaid + paidAmount;
    final dueAmount = total - totalPaid;

    return Card(
      child: Column(
        children: [
          _buildTotalRow('Subtotal (including tax)', '৳${subtotal.toStringAsFixed(2)}'),
          _buildTotalRow(
            'Discount Percentage',
            '${_discountPercentage.toStringAsFixed(2)}%',
            isEditable: true,
            onTap: () => _showInputDialog(
              'Enter Discount Percentage',
              _discountPercentage.toString(),
              (value) {
                setState(() {
                  _discountPercentage = double.tryParse(value) ?? 0.0;
                  _discountAmount = 0.0; // Reset amount when percentage is set
                });
              },
            ),
          ),
          _buildTotalRow(
            'Discount Amount',
            '৳${discountAmount.toStringAsFixed(2)}',
            isEditable: true,
            onTap: () => _showInputDialog(
              'Enter Discount Amount',
              _discountAmount.toString(),
              (value) {
                setState(() {
                  _discountAmount = double.tryParse(value) ?? 0.0;
                  _discountPercentage = 0.0; // Reset percentage when amount is set
                });
              },
            ),
          ),
          _buildTotalRow('Item Level Tax (included in subtotal)', '৳${itemTax.toStringAsFixed(2)}'),
          _buildTotalRow(
            'Shipping',
            '৳${shipping.toStringAsFixed(2)}',
            isEditable: true,
            onTap: () => _showInputDialog(
              'Enter Shipping Amount',
              _shipping.toString(),
              (value) => setState(() => _shipping = double.tryParse(value) ?? 0.0),
            ),
          ),
          Divider(),
          _buildTotalRow('Total', '৳${total.toStringAsFixed(2)}', isBold: true),
          _buildTotalRow(
            'Advance Paid',
            '৳${advancePaid.toStringAsFixed(2)}',
            isEditable: true,
            onTap: () => _showInputDialog(
              'Enter Advance Paid Amount',
              _advancePaid.toString(),
              (value) => setState(() => _advancePaid = double.tryParse(value) ?? 0.0),
            ),
          ),
          _buildTotalRow(
            'Paid Amount',
            '৳${paidAmount.toStringAsFixed(2)}',
            isEditable: true,
            onTap: () => _showInputDialog(
              'Enter Paid Amount',
              _paidAmount.toString(),
              (value) => setState(() => _paidAmount = double.tryParse(value) ?? 0.0),
            ),
          ),
          _buildTotalRow(
            'Total Paid', 
            '৳${totalPaid.toStringAsFixed(2)}', 
            isBold: true
          ),
          _buildTotalRow(
            'Due Amount', 
            '৳${dueAmount.toStringAsFixed(2)}', 
            isBold: true
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String title,
    String amount, {
    bool isBold = false,
    bool isEditable = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Row(
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isEditable)
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onTap,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showOptionsDialog(
    String title,
    List<String> options,
    Function(String) onSelect,
  ) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children:
              options
                  .map(
                    (option) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, option),
                      child: Text(option),
                    ),
                  )
                  .toList(),
        );
      },
    );
    if (selected != null) {
      onSelect(selected);
    }
  }

  Future<void> _showInputDialog(
    String title,
    String initialValue,
    Function(String) onSave,
  ) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter $title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      onSave(result);
    }
  }

  void _addItem() async {
    final productService = ProductService();
    List<Product> products = [];
    try {
      products = await productService.getAllProducts();
    } catch (e) {
      print('Error loading products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final unitController = TextEditingController(text: '1');
        Product? selectedProduct;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Dropdown
                    DropdownButtonFormField<Product>(
                      decoration: InputDecoration(labelText: 'Select Product'),
                      value: selectedProduct,
                      items: products.map((Product product) {
                        return DropdownMenuItem<Product>(
                          value: product,
                          child: Text(product.name ?? 'No name'),
                        );
                      }).toList(),
                      onChanged: (Product? value) {
                        setState(() {
                          selectedProduct = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    if (selectedProduct != null) ...[
                      // Description (read-only)
                      TextField(
                        controller: TextEditingController(text: selectedProduct?.description ?? ''),
                        decoration: InputDecoration(labelText: 'Description'),
                        readOnly: true,
                      ),
                      // Unit input
                      TextField(
                        controller: unitController,
                        decoration: InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                      ),
                      // Price (read-only)
                      TextField(
                        controller: TextEditingController(text: selectedProduct?.price?.toString() ?? '0'),
                        decoration: InputDecoration(labelText: 'Price per Unit'),
                        readOnly: true,
                      ),
                      // Tax (read-only)
                      TextField(
                        controller: TextEditingController(text: selectedProduct?.taxRate?.toString() ?? '0'),
                        decoration: InputDecoration(labelText: 'Tax (%)'),
                        readOnly: true,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: selectedProduct == null ? null : () {
                    final unit = double.tryParse(unitController.text) ?? 1;
                    final price = selectedProduct?.price ?? 0;
                    final amount = unit * price;

                    // Update the parent widget's state
                    this.setState(() {
                      items.add({
                        'name': selectedProduct?.name ?? '',
                        'description': selectedProduct?.description ?? '',
                        'unit': unit.toString(),
                        'price': price.toString(),
                        'amount': amount.toStringAsFixed(2),
                        'tax': selectedProduct?.taxRate?.toString() ?? '0',
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _previewInvoice() {
    // TODO: Implement preview functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Preview feature coming soon!')));
    return Future.value();
  }

  void _handleDiscountEdit(String value) {
    setState(() {
      _discountPercentage = double.tryParse(value) ?? 0.0;
    });
  }

  void _handleShippingEdit(String value) {
    setState(() {
      _shipping = double.tryParse(value) ?? 0.0;
    });
  }

  void _handleAdvancePaidEdit(String value) {
    setState(() {
      _advancePaid = double.tryParse(value) ?? 0.0;
    });
  }
}
