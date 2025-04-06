import 'package:flutter/material.dart';
import 'package:invo/models/business_info.dart';
import 'package:invo/models/client_model.dart';
import 'package:invo/models/invoice_item.dart';
import 'package:invo/models/invoice_model.dart';
import 'package:invo/services/InvoiceService.dart';
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

  String terms = '';
  String paymentMethod = '';
  final List<Map<String, dynamic>> items = [];
  final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy');

  double _discount = 0.0;
  double _shipping = 0.0;
  double _advancePaid = 0.0;
  final double _taxRate = 0.15;
  int _invoiceNumber = 1;

  DateTime _createdDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(Duration(days: 7));

  @override
  Widget build(BuildContext context) {
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
              _buildBusinessInfo(),
              // _buildSection(context, 'Bill To', clientName.isEmpty ? 'Add Client' : clientName, Icons.person,
              //   onTap: () => _showInputDialog('Client Name', clientName,
              //     (value) => setState(() => clientName = value))),
              _buildClientInfo(),
              _buildItemsSection(),
              _buildTotals(),
              // _buildSection(context, 'Currency', 'BDT ৳', Icons.attach_money),
              _buildSection(context, 'Signature', '', Icons.edit),
              _buildSection(
                context,
                'Terms & Conditions',
                terms.isEmpty ? 'Add Terms & Conditions' : terms,
                Icons.assignment,
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
            trailing: Text(
              'INV${_invoiceNumber.toString().padLeft(6, '0')}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
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
                Text('Due: ${_dateFormat.format(_dueDate)}'),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
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

  Widget _buildBusinessInfo() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Business Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: ElevatedButton.icon(
              onPressed: _editBusinessInfo,
              icon: Icon(Icons.edit),
              label: Text('Edit'),
            ),
          ),
          if (businessInfo['businessName']?.isNotEmpty ?? false)
            ListTile(
              title: Text(businessInfo['businessName'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (businessInfo['address']?.isNotEmpty ?? false)
                    Text(businessInfo['address'] ?? ''),
                  if (businessInfo['phone']?.isNotEmpty ??
                      false || businessInfo['email']!.isNotEmpty ??
                      false)
                    Text(
                      '${businessInfo['phone'] ?? ''} | ${businessInfo['email'] ?? ''}',
                    ),
                  if (businessInfo['taxId']?.isNotEmpty ?? false)
                    Text('Tax ID: ${businessInfo['taxId']}'),
                  if (businessInfo['website']?.isNotEmpty ?? false)
                    Text(businessInfo['website'] ?? ''),
                ],
              ),
            )
          else
            ListTile(
              title: Text(
                'No business information added',
                style: TextStyle(color: Colors.grey),
              ),
              leading: Icon(Icons.business, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  void _editBusinessInfo() {
    showDialog(
      context: context,
      builder: (context) {
        Map<String, String> tempInfo = Map.from(businessInfo);

        return AlertDialog(
          title: Text('Edit Business Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Business Name'),
                  controller: TextEditingController(
                    text: tempInfo['businessName'],
                  ),
                  onChanged: (value) => tempInfo['businessName'] = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Address'),
                  controller: TextEditingController(text: tempInfo['address']),
                  onChanged: (value) => tempInfo['address'] = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Phone'),
                  controller: TextEditingController(text: tempInfo['phone']),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => tempInfo['phone'] = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                  controller: TextEditingController(text: tempInfo['email']),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => tempInfo['email'] = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Tax ID'),
                  controller: TextEditingController(text: tempInfo['taxId']),
                  onChanged: (value) => tempInfo['taxId'] = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Website'),
                  controller: TextEditingController(text: tempInfo['website']),
                  keyboardType: TextInputType.url,
                  onChanged: (value) => tempInfo['website'] = value,
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
                setState(() => businessInfo = tempInfo);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

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
                  decoration: InputDecoration(labelText: 'Client Name'),
                  controller: TextEditingController(text: tempInfo['name']),
                  onChanged: (value) => tempInfo['name'] = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                  controller: TextEditingController(text: tempInfo['email']),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => tempInfo['email'] = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Phone'),
                  controller: TextEditingController(text: tempInfo['phone']),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => tempInfo['phone'] = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'NID (National ID)'),
                  controller: TextEditingController(text: tempInfo['nid']),
                  onChanged: (value) => tempInfo['nid'] = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Address'),
                  controller: TextEditingController(text: tempInfo['address']),
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

  void _saveInvoice() async {
    final subtotal = _calculateSubtotal();
    final totalAmount = _calculateTotal(
      subtotal,
      _discount,
      _shipping,
      _advancePaid,
      _taxRate,
    );
    print('Subtotal: $subtotal');
    print('Total Amount: $totalAmount');
    // Convert items to the correct format
    final List<Map<String, dynamic>> formattedItems =
        items.map((item) {
          return {
            'itemName': item['name'] ?? '',
            'quantity': double.tryParse(item['unit'] ?? '0') ?? 0,
            'unitPrice': double.tryParse(item['price'] ?? '0') ?? 0,
            'totalPrice': double.tryParse(item['amount'] ?? '0') ?? 0,
          };
        }).toList();

    final invoice = Invoice(
      invoiceNumber: 'INV${_invoiceNumber.toString().padLeft(6, '0')}',
      issueDate: _createdDate,
      subtotal: subtotal ?? 0.0,
      discountPersentage: _discount > 0 ? (_discount / subtotal) * 100 : 0.0,
      discountCash: _discount ?? 0.0,
      // totalAmount: totalAmount ?? 0.0,
      dueDate: _dueDate,
      status: status.toUpperCase(),
      client: Client(
        name: clientInfo['name'] ?? '',
        email: clientInfo['email'] ?? '',
        phone: clientInfo['phone'] ?? '',
        nid: clientInfo['nid'] ?? '',
        address: clientInfo['address'] ?? '',
      ),
      createdBy: 1, // You might want to get this from user authentication
      items:
          formattedItems
              .map(
                (item) => InvoiceItem(
                  itemName: item['itemName'] ?? '',
                  quantity: item['quantity'] ?? 0,
                  unitPrice: item['unitPrice'] ?? 0,
                  totalPrice: item['totalPrice'] ?? 0,
                ),
              )
              .toList(),
      businessInfo: BusinessInfo(
        businessName: businessInfo['businessName'] ?? '',
        address: businessInfo['address'] ?? '',
        phone: businessInfo['phone'] ?? '',
        email: businessInfo['email'] ?? '',
        taxId: businessInfo['taxId'] ?? '',
        website: businessInfo['website'] ?? '',
      ),
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
      final amount = double.tryParse(item['amount'] ?? '0') ?? 0;
      return sum + amount;
    });
  }

  double _calculateItemTax() {
    return items.fold(0.0, (sum, item) {
      final amount = double.tryParse(item['amount'] ?? '0') ?? 0;
      final taxPercent = double.tryParse(item['tax'] ?? '0') ?? 0;
      return sum + (amount * (taxPercent / 100));
    });
  }

  double _calculateTotal(
    double subtotal,
    double discount,
    double shipping,
    double advancePaid,
    double taxRate,
  ) {
    final itemLevelTax = _calculateItemTax();
    return subtotal + itemLevelTax - discount + shipping - advancePaid;
  }

  Widget _buildItemsSection() {
    return Card(
      child: Column(
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
            ...items.map((item) {
              final quantity = double.tryParse(item['unit'] ?? '0') ?? 0;
              final unitPrice = double.tryParse(item['price'] ?? '0') ?? 0;
              final totalPrice = quantity * unitPrice;

              return ListTile(
                title: Text(item['name'] ?? 'Item'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item['description']?.isNotEmpty ?? false)
                      Text(item['description'] ?? ''),
                    Text(
                      '${quantity.toStringAsFixed(0)} × ৳${unitPrice.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '৳${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    final subtotal = _calculateSubtotal();
    final itemTax = _calculateItemTax();
    final discount = _discount;
    final shipping = _shipping;
    final advancePaid = _advancePaid;
    final total = _calculateTotal(
      subtotal,
      discount,
      shipping,
      advancePaid,
      _taxRate,
    );

    return Card(
      child: Column(
        children: [
          _buildTotalRow('Subtotal', '৳${subtotal.toStringAsFixed(2)}'),
          _buildTotalRow(
            'Discount',
            '৳${discount.toStringAsFixed(2)}',
            isEditable: true,
          ),
          _buildTotalRow('Tax', '৳${itemTax.toStringAsFixed(2)}'),
          _buildTotalRow(
            'Shipping',
            '৳${shipping.toStringAsFixed(2)}',
            isEditable: true,
          ),
          _buildTotalRow(
            'Advance Paid',
            '৳${advancePaid.toStringAsFixed(2)}',
            isEditable: true,
          ),
          Divider(),
          _buildTotalRow('Total', '৳${total.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String title,
    String amount, {
    bool isBold = false,
    bool isEditable = false,
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
                  onPressed: () {
                    final controller = TextEditingController(
                      text: amount.replaceAll('৳', ''),
                    );
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Edit $title'),
                            content: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: 'Amount'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final value = controller.text;
                                  if (title == 'Discount') {
                                    _handleDiscountEdit(value);
                                  } else if (title == 'Shipping') {
                                    _handleShippingEdit(value);
                                  } else if (title == 'Advance Paid') {
                                    _handleAdvancePaidEdit(value);
                                  }
                                  Navigator.pop(context);
                                },
                                child: Text('Save'),
                              ),
                            ],
                          ),
                    );
                  },
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

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final descriptionController = TextEditingController();
        final priceController = TextEditingController();
        final taxController = TextEditingController();
        final unitController = TextEditingController();
        return AlertDialog(
          title: Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: unitController,
                  decoration: InputDecoration(labelText: 'Unit'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price per Unit'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: taxController,
                  decoration: InputDecoration(
                    labelText: 'Tax (%)',
                    hintText: '0',
                  ),
                  keyboardType: TextInputType.number,
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
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    unitController.text.isNotEmpty) {
                  setState(() {
                    final unit = double.tryParse(unitController.text) ?? 1;
                    final price = double.tryParse(priceController.text) ?? 0;
                    final tax = double.tryParse(taxController.text) ?? 0;
                    final amount = unit * price;

                    items.add({
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'unit': unit.toString(),
                      'price': price.toString(),
                      'amount': amount.toStringAsFixed(2),
                      'tax': tax.toString(),
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _previewInvoice() {
    // TODO: Implement preview functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Preview feature coming soon!')));
  }

  void _handleDiscountEdit(String value) {
    setState(() {
      _discount = double.tryParse(value) ?? 0.0;
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
