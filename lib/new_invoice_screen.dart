import 'package:flutter/material.dart';
import 'package:invo/models/client_model.dart';
import 'package:invo/models/invoice_item.dart';
import 'package:invo/models/invoice_model.dart';
import 'package:invo/services/AuthService.dart';
import 'package:invo/services/ClientService.dart';
import 'package:invo/services/InvoiceService.dart';
import 'package:invo/services/ProductService.dart';
import 'package:invo/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'business_info_edit.dart';
import 'models/invoice_data.dart' as model;

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key, this.invoice});

  final Invoice? invoice;

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  String clientName = '';
  String amount = '0.00';
  String status = 'Unpaid';
  String template = 'Default';
  String language = 'English';
  // Removed duplicate declaration of clientInfo
  String companyName = '';
  List<Map<String, String>> items = [];
  Map<String, dynamic>? _userData;
  DateTime _createdDate = DateTime.now();
  DateTime? _dueDate;
  double _discountAmount = 0;
  double _discountPercentage = 0;
  double _advancePaid = 0;
  double _paidAmount = 0;
  String terms = '';
  String paymentMethod = '';
  File? _logoFile;
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
    'createdBy': '',
  };

  final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy');

  double _shipping = 0.0;

  final double _taxRate = 0.15;
  int _invoiceNumber = 1;
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    final username = prefs.getString('username');

    print('=== Debug User Data ===');
    print('User String from SharedPreferences: $userString');
    print('Username from SharedPreferences: $username');

    Map<String, dynamic> userData = {};

    if (userString != null) {
      userData = jsonDecode(userString);
    }

    // Ensure we have the username
    if (username != null && username.isNotEmpty) {
      userData['userName'] = username;
    }

    print('Final User Data: $userData');
    setState(() {
      _userData = userData;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data first
    if (widget.invoice != null) {
      // Initialize state with existing invoice data
      final invoice = widget.invoice!;
      setState(() {
        clientInfo = {
          'name': invoice.client?.name ?? '',
          'email': invoice.client?.email ?? '',
          'phone': invoice.client?.phone ?? '',
          'nid': invoice.client?.nid ?? '',
          'address': invoice.client?.address ?? '',
        };
        status = invoice.status ?? 'Unpaid';
        _createdDate = invoice.issueDate ?? DateTime.now();
        _dueDate = invoice.dueDate;
        companyName = invoice.companyName ?? '';
        _discountAmount = invoice.discountCash ?? 0;
        _discountPercentage = invoice.discountPersentage ?? 0;
        // Split the total paid amount between paidAmount and advancePaid
        final totalPaid = invoice.paidAmount ?? 0;
        _paidAmount = totalPaid;
        _advancePaid = invoice.advancePaid ?? 0;

        // Convert invoice items to the format expected by the UI
        items = invoice.items?.map((item) => {
          'name': item.itemName ?? '',
          'description': item.description ?? '',
          'unit': item.quantity?.toString() ?? '0',
          'price': item.unitPrice?.toString() ?? '0',
          'tax': item.tax?.toString() ?? '0',
          // Calculate amount with tax for consistent display
          'amount': ((item.quantity ?? 0) * (item.unitPrice ?? 0) * (1 + (item.tax ?? 0) / 100)).toString(),
        }).toList() ?? [];
      });
    }
    _loadUserData();
  }

  @override
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
                Text(
                  'Due: ${_dueDate != null ? _dateFormat.format(_dueDate!) : 'Not Set'}',
                ),
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

  void _editClientInfo() {
    showDialog(
      context: context,
      builder: (context) {
        Map<String, String> tempInfo = Map.from(clientInfo);
        final _formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: Text('Edit Client Information'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: TextEditingController(text: tempInfo['name']),
                    decoration: InputDecoration(labelText: 'Client Name'),
                    onChanged: (value) => tempInfo['name'] = value,
                  ),
                  TextFormField(
                    controller: TextEditingController(text: tempInfo['email']),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      helperText: 'Required',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (value) => tempInfo['email'] = value,
                  ),
                  TextFormField(
                    controller: TextEditingController(text: tempInfo['phone']),
                    decoration: InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => tempInfo['phone'] = value,
                  ),
                  TextFormField(
                    controller: TextEditingController(text: tempInfo['nid']),
                    decoration: InputDecoration(labelText: 'NID (National ID)'),
                    onChanged: (value) => tempInfo['nid'] = value,
                  ),
                  TextFormField(
                    controller: TextEditingController(
                      text: tempInfo['address'],
                    ),
                    decoration: InputDecoration(labelText: 'Address'),
                    onChanged: (value) => tempInfo['address'] = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() => clientInfo = tempInfo);
                  Navigator.pop(context);
                }
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
                final tax = double.tryParse(item['tax'] ?? '0') ?? 0;
                final itemTotal = unit * price;
                final taxAmount = itemTotal * tax / 100;
                final totalWithTax = itemTotal + taxAmount;

                setState(() {
                  items[index] = {
                    ...item,
                    'unit': unit.toString(),
                    'amount': itemTotal.toString(), // Base amount without tax
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

  Future<void> _addItem() async {
    final ProductService productService = ProductService();
    List<Product> products = [];

    try {
      products = await productService.getAllProducts();
    } catch (e) {
      print('Error loading products: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load products')));
      return;
    }

    if (!context.mounted) return;

    final unitController = TextEditingController(text: '1');
    Product? selectedProduct;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      items:
                          products.map((Product product) {
                            return DropdownMenuItem<Product>(
                              value: product,
                              child: Text(product.name ?? 'No name'),
                            );
                          }).toList(),
                      onChanged: (Product? value) {
                        setDialogState(() {
                          selectedProduct = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    if (selectedProduct != null) ...[
                      // Description (read-only)
                      TextField(
                        controller: TextEditingController(
                          text: selectedProduct?.description ?? '',
                        ),
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
                        controller: TextEditingController(
                          text: selectedProduct?.price?.toString() ?? '0',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Price per Unit',
                        ),
                        readOnly: true,
                      ),
                      // Tax (read-only)
                      TextField(
                        controller: TextEditingController(
                          text: selectedProduct?.taxRate?.toString() ?? '0',
                        ),
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
                  onPressed:
                      selectedProduct == null
                          ? null
                          : () {
                            final unit = double.tryParse(unitController.text) ?? 1;
                            final price = selectedProduct?.price ?? 0;
                            final tax = selectedProduct?.taxRate ?? 0;
                            final itemTotal = unit * price;
                            final taxAmount = itemTotal * tax / 100;
                            final totalWithTax = itemTotal + taxAmount;

                            // Update the parent widget's state
                            setState(() {
                              items.add({
                                'name': selectedProduct?.name ?? '',
                                'description': selectedProduct?.description ?? '',
                                'unit': unit.toString(),
                                'price': price.toString(),
                                'amount': itemTotal.toString(), // Base amount without tax
                                'tax': tax.toString(),
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

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Items',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                    final itemTotal = double.tryParse(item['amount'] ?? '0') ?? 0;
                    final taxAmount = itemTotal * tax / 100;
                    final totalWithTax = itemTotal + taxAmount;

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
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Item removed')));
                      },
                      child: ListTile(
                        title: Text(item['name'] ?? 'Item'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${quantity.toStringAsFixed(0)} × ৳${unitPrice.toStringAsFixed(2)}',
                            ),
                            if (tax > 0)
                              Text(
                                'Tax: ${tax.toStringAsFixed(1)}%',
                                style: TextStyle(color: Colors.grey),
                              ),
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
                                    Text(
                                      '৳${itemTotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (tax > 0)
                                      Text(
                                        '+ ৳${taxAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Text(
                                      'Total: ৳${totalWithTax.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 4),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _editItem(index),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
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

  double _calculateTotal(
    double subtotal,
    double discountAmount,
    double shipping,
    double advancePaid,
    double paidAmount,
    double itemLevelTax,
  ) {
    // Calculate total: subtotal + tax + shipping - discount
    return subtotal + itemLevelTax + shipping - discountAmount;
  }

  double _calculateSubtotal() {
    return items.fold(0.0, (sum, item) {
      final quantity = double.tryParse(item['unit'] ?? '0') ?? 0;
      final unitPrice = double.tryParse(item['price'] ?? '0') ?? 0;
      final tax = double.tryParse(item['tax'] ?? '0') ?? 0;
      final itemTotal = quantity * unitPrice;
      return sum + itemTotal; // Subtotal is before tax
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

  Future<void> _saveInvoice() async {
    // InvoiceService will handle setting createdBy from the token
    // Check if client email is provided
    if (clientInfo['email']?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Client email is required. Please add client information.',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(label: 'Add Info', onPressed: _editClientInfo),
        ),
      );
      return;
    }

    if (_userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User information not found. Please try logging in again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final subtotal =
        _calculateSubtotal(); // This now includes item prices + tax
    final discountPercentage = _discountPercentage;
    final discountAmount =
        _discountPercentage > 0
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
      itemTax, // This won't be added again since it's in subtotal
    );

    final totalPaid = _advancePaid + _paidAmount;
    final dueAmount = totalAmount - totalPaid;

    // Convert items to the correct format
    final List<Map<String, dynamic>> formattedItems =
        items.map((item) {
          final quantity = double.tryParse(item['unit'] ?? '0') ?? 0;
          final unitPrice = double.tryParse(item['price'] ?? '0') ?? 0;
          final tax = double.tryParse(item['tax'] ?? '0') ?? 0;
          final itemTotal = quantity * unitPrice;
          final taxAmount = itemTotal * tax / 100;
          final totalWithTax = itemTotal + taxAmount;

          return {
            'itemName': item['name'] ?? '',
            'quantity': quantity,
            'unitPrice': unitPrice,
            'totalPrice': totalWithTax, // Include tax in total price
            'tax': tax,
            'taxAmount': taxAmount,
          };
        }).toList();

    // Create client object
    final client = Client(
      name: clientInfo['name'],
      email: clientInfo['email'],
      phone: clientInfo['phone'],
      nid: clientInfo['nid'],
      address: clientInfo['address'],
    );

    final invoice = Invoice(
      issueDate: _createdDate,
      subtotal: subtotal,
      totalAmount: totalAmount,
      paidAmount: _paidAmount,
      advancePaid: _advancePaid,
      dueAmount: dueAmount,
      discountPersentage: discountPercentage,
      client: client,
      discountCash: _discountAmount,
      status: dueAmount <= 0 ? 'PAID' : status.toUpperCase(),
      dueDate: _dueDate,
      // Preserve invoice number when updating
      invoiceNumber: widget.invoice?.invoiceNumber,
      // createdBy will be set by InvoiceService
      companyName: companyName,
      items:
          formattedItems
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
      Invoice? savedInvoice;
      
      if (widget.invoice != null) {
        // Update existing invoice
        invoice.id = widget.invoice!.id; // Set the ID from existing invoice
        savedInvoice = await invoiceService.updateInvoice(invoice);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Create new invoice
        savedInvoice = await invoiceService.createInvoice(invoice);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate back to previous screen
      Navigator.pop(context, savedInvoice);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.invoice != null ? 'Failed to update invoice: $e' : 'Failed to create invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                IconButton(icon: Icon(Icons.edit), onPressed: onTap),
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

  Future<void> _pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _logoFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Widget _buildTotals() {
    final subtotal = _calculateSubtotal(); // Subtotal before tax
    final discountPercentage = _discountPercentage;
    final discountAmount =
        _discountPercentage > 0
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
      itemTax,
    );

    final totalPaid = advancePaid + paidAmount;
    final dueAmount = total - totalPaid;

    return Card(
      child: Column(
        children: [
          _buildTotalRow(
            'Subtotal',
            '৳${subtotal.toStringAsFixed(2)}',
          ),
          _buildTotalRow(
            'Discount Percentage',
            '${_discountPercentage.toStringAsFixed(2)}%',
            isEditable: true,
            onTap:
                () => _showInputDialog(
                  'Enter Discount Percentage',
                  _discountPercentage.toString(),
                  (value) {
                    setState(() {
                      _discountPercentage = double.tryParse(value) ?? 0.0;
                      _discountAmount =
                          0.0; // Reset amount when percentage is set
                    });
                  },
                ),
          ),
          _buildTotalRow(
            'Discount Amount',
            '৳${discountAmount.toStringAsFixed(2)}',
            isEditable: true,
            onTap:
                () => _showInputDialog(
                  'Enter Discount Amount',
                  _discountAmount.toString(),
                  (value) {
                    setState(() {
                      _discountAmount = double.tryParse(value) ?? 0.0;
                      _discountPercentage =
                          0.0; // Reset percentage when amount is set
                    });
                  },
                ),
          ),
          _buildTotalRow(
            'Tax',
            '৳${itemTax.toStringAsFixed(2)}',
          ),
          _buildTotalRow(
            'Shipping',
            '৳${shipping.toStringAsFixed(2)}',
            isEditable: true,
            onTap:
                () => _showInputDialog(
                  'Enter Shipping Amount',
                  _shipping.toString(),
                  (value) =>
                      setState(() => _shipping = double.tryParse(value) ?? 0.0),
                ),
          ),
          Divider(),
          _buildTotalRow('Total', '৳${total.toStringAsFixed(2)}', isBold: true),
          _buildTotalRow(
            'Advance Paid',
            '৳${advancePaid.toStringAsFixed(2)}',
            isEditable: true,
            onTap:
                () => _showInputDialog(
                  'Enter Advance Paid Amount',
                  _advancePaid.toString(),
                  (value) => setState(
                    () => _advancePaid = double.tryParse(value) ?? 0.0,
                  ),
                ),
          ),
          _buildTotalRow(
            'Paid Amount',
            '৳${paidAmount.toStringAsFixed(2)}',
            isEditable: true,
            onTap:
                () => _showInputDialog(
                  'Enter Paid Amount',
                  _paidAmount.toString(),
                  (value) => setState(
                    () => _paidAmount = double.tryParse(value) ?? 0.0,
                  ),
                ),
          ),
          _buildTotalRow(
            'Total Paid',
            '৳${totalPaid.toStringAsFixed(2)}',
            isBold: true,
          ),
          _buildTotalRow(
            'Due Amount',
            '৳${dueAmount.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

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
}


