import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'models/invoice_data.dart' as model;

class NewInvoiceScreen extends StatefulWidget {
  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  String clientName = '';
  String amount = '0.00';
  String status = 'Unpaid';
  String template = 'Default';
  String language = 'English';
  String businessInfo = '';
  String terms = '';
  String paymentMethod = '';
  final List<Map<String, dynamic>> items = [];
  final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy');

  double _discount = 0.0;
  double _shipping = 0.0;
  double _advancePaid = 0.0;
  double _taxRate = 0.15;
  int _invoiceNumber = 1;

  DateTime _createdDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            _buildSection(context, 'Templates', template, Icons.description, 
              onTap: () => _showOptionsDialog('Select Template', ['Default', 'Professional', 'Simple'], 
                (value) => setState(() => template = value))),
            _buildSection(context, 'Language', language, Icons.language,
              onTap: () => _showOptionsDialog('Select Language', ['English', 'Bengali'], 
                (value) => setState(() => language = value))),
            _buildInvoiceInfo(),
            _buildSection(context, 'Business Info', businessInfo.isEmpty ? 'Add Your Business Details' : businessInfo, 
              Icons.business, onTap: () => _showInputDialog('Business Info', businessInfo, 
                (value) => setState(() => businessInfo = value))),
            _buildSection(context, 'Bill To', clientName.isEmpty ? 'Add Client' : clientName, Icons.person,
              onTap: () => _showInputDialog('Client Name', clientName, 
                (value) => setState(() => clientName = value))),
            _buildItemsSection(),
            _buildTotals(),
            _buildSection(context, 'Currency', 'BDT ৳', Icons.attach_money),
            _buildSection(context, 'Signature', '', Icons.edit),
            _buildSection(context, 'Terms & Conditions', terms.isEmpty ? 'Add Terms & Conditions' : terms, 
              Icons.assignment, onTap: () => _showInputDialog('Terms & Conditions', terms, 
                (value) => setState(() => terms = value))),
            _buildSection(context, 'Payment Method', paymentMethod.isEmpty ? 'Add Payment Method' : paymentMethod, 
              Icons.payment, onTap: () => _showOptionsDialog('Payment Method', 
                ['Cash', 'Bank Transfer', 'Credit Card'], (value) => setState(() => paymentMethod = value))),
            _buildSection(context, 'Mark As', status, Icons.label,
              onTap: () => _showOptionsDialog('Status', ['Unpaid', 'Paid', 'Partially Paid'], 
                (value) => setState(() => status = value))),
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
    );
  }

  Widget _buildSection(BuildContext context, String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
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
            title: Text('Invoice Info', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('INV${_invoiceNumber.toString().padLeft(6, '0')}', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  void _saveInvoice() {
    if (clientName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a client name')),
      );
      return;
    }

    final totalAmount = _calculateTotal(_calculateSubtotal(), _discount, _shipping, _advancePaid, _taxRate);

    Provider.of<model.InvoiceData>(context, listen: false).addInvoice({
      'clientName': clientName,
      'amount': totalAmount.toString(),
      'status': status,
      'template': template,
      'language': language,
      'businessInfo': businessInfo,
      'terms': terms,
      'paymentMethod': paymentMethod,
      'createdAt': _dateFormat.format(_createdDate),
      'dueDate': _dateFormat.format(_dueDate),
      'items': items,
      'invoiceNumber': 'INV${_invoiceNumber.toString().padLeft(6, '0')}',
    });

    setState(() {
      _invoiceNumber++;
    });

    Navigator.pop(context);
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

  double _calculateTotal(double subtotal, double discount, double shipping, double advancePaid, double taxRate) {
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
          ...items.map((item) {
            final amount = double.tryParse(item['amount'] ?? '0') ?? 0;
            final tax = double.tryParse(item['tax'] ?? '0') ?? 0;
            final taxAmount = amount * (tax / 100);
            
            return ListTile(
              title: Text(item['name'] ?? 'Item'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['description'] ?? ''),
                  Text('${item['unit']} units × ৳${item['price']} + ${item['tax']}% tax'),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('৳${amount.toStringAsFixed(2)}'),
                  Text(
                    '+ ৳${taxAmount.toStringAsFixed(2)} tax',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
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
    final total = _calculateTotal(subtotal, discount, shipping, advancePaid, _taxRate);

    return Card(
      child: Column(
        children: [
          _buildTotalRow('Subtotal', '৳${subtotal.toStringAsFixed(2)}'),
          _buildTotalRow('Discount', '৳${discount.toStringAsFixed(2)}', isEditable: true),
          _buildTotalRow('Tax', '৳${itemTax.toStringAsFixed(2)}'),
          _buildTotalRow('Shipping', '৳${shipping.toStringAsFixed(2)}', isEditable: true),
          _buildTotalRow('Advance Paid', '৳${advancePaid.toStringAsFixed(2)}', isEditable: true),
          Divider(),
          _buildTotalRow('Total', '৳${total.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String title, String amount, {bool isBold = false, bool isEditable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Row(
            children: [
              Text(amount, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
              if (isEditable) IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  final controller = TextEditingController(text: amount.replaceAll('৳', ''));
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
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

  Future<void> _showOptionsDialog(String title, List<String> options, Function(String) onSelect) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children: options.map((option) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, option),
            child: Text(option),
          )).toList(),
        );
      },
    );
    if (selected != null) {
      onSelect(selected);
    }
  }

  Future<void> _showInputDialog(String title, String initialValue, Function(String) onSave) async {
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
                  decoration: InputDecoration(labelText: 'Tax (%)', hintText: '0'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preview feature coming soon!')),
    );
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