// Add these class variables
double _discount = 0.0;
double _shipping = 0.0;
double _advancePaid = 0.0;
double _taxRate = 0.15; // Default tax rate of 15%

// Add these calculation methods
double _calculateSubtotal() {
  return items.fold(0.0, (sum, item) {
    final price = double.tryParse(item['amount']) ?? 0;
    final tax = double.tryParse(item['tax']) ?? 0;
    return sum + price * (1 + tax / 100);
  });
}

double _calculateTotal(double subtotal, double discount, double shipping, double advancePaid) {
  return subtotal - discount + shipping - advancePaid;
}

// Update the totals section
Widget _buildTotals() {
  final subtotal = _calculateSubtotal();
  final discount = _discount;
  final shipping = _shipping;
  final advancePaid = _advancePaid;
  final total = _calculateTotal(subtotal, discount, shipping, advancePaid);

  return Card(
    child: Column(
      children: [
        _buildTotalRow('Subtotal', '৳${subtotal.toStringAsFixed(2)}'),
        _buildTotalRow('Discount', '৳${discount.toStringAsFixed(2)}', isEditable: true),
        _buildTotalRow('Tax', '৳${(subtotal * _taxRate).toStringAsFixed(2)}'),
        _buildTotalRow('Shipping', '৳${shipping.toStringAsFixed(2)}', isEditable: true),
        _buildTotalRow('Advance Paid', '৳${advancePaid.toStringAsFixed(2)}', isEditable: true),
        Divider(),
        _buildTotalRow('Total', '৳${total.toStringAsFixed(2)}', isBold: true),
      ],
    ),
  );
}

// Add edit handlers
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

// Update _buildTotalRow to use the correct handlers
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
}// Add these class variables
double _discount = 0.0;
double _shipping = 0.0;
double _advancePaid = 0.0;
double _taxRate = 0.15; // Default tax rate of 15%

// Add these calculation methods
double _calculateSubtotal() {
  return items.fold(0.0, (sum, item) {
    final price = double.tryParse(item['amount']) ?? 0;
    final tax = double.tryParse(item['tax']) ?? 0;
    return sum + price * (1 + tax / 100);
  });
}

double _calculateTotal(double subtotal, double discount, double shipping, double advancePaid) {
  return subtotal - discount + shipping - advancePaid;
}

// Update the totals section
Widget _buildTotals() {
  final subtotal = _calculateSubtotal();
  final discount = _discount;
  final shipping = _shipping;
  final advancePaid = _advancePaid;
  final total = _calculateTotal(subtotal, discount, shipping, advancePaid);

  return Card(
    child: Column(
      children: [
        _buildTotalRow('Subtotal', '৳${subtotal.toStringAsFixed(2)}'),
        _buildTotalRow('Discount', '৳${discount.toStringAsFixed(2)}', isEditable: true),
        _buildTotalRow('Tax', '৳${(subtotal * _taxRate).toStringAsFixed(2)}'),
        _buildTotalRow('Shipping', '৳${shipping.toStringAsFixed(2)}', isEditable: true),
        _buildTotalRow('Advance Paid', '৳${advancePaid.toStringAsFixed(2)}', isEditable: true),
        Divider(),
        _buildTotalRow('Total', '৳${total.toStringAsFixed(2)}', isBold: true),
      ],
    ),
  );
}

// Add edit handlers
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

// Update _buildTotalRow to use the correct handlers
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
              // Add these class variables
              double _discount = 0.0;
              double _shipping = 0.0;
              double _advancePaid = 0.0;
              double _taxRate = 0.15; // Default tax rate of 15%
              
              // Add these calculation methods
              double _calculateSubtotal() {
                return items.fold(0.0, (sum, item) {
                  final price = double.tryParse(item['amount']) ?? 0;
                  final tax = double.tryParse(item['tax']) ?? 0;
                  return sum + price * (1 + tax / 100);
                });
              }
              
              double _calculateTotal(double subtotal, double discount, double shipping, double advancePaid) {
                return subtotal - discount + shipping - advancePaid;
              }
              
              // Update the totals section
              Widget _buildTotals() {
                final subtotal = _calculateSubtotal();
                final discount = _discount;
                final shipping = _shipping;
                final advancePaid = _advancePaid;
                final total = _calculateTotal(subtotal, discount, shipping, advancePaid);
              
                return Card(
                  child: Column(
                    children: [
                      _buildTotalRow('Subtotal', '৳${subtotal.toStringAsFixed(2)}'),
                      _buildTotalRow('Discount', '৳${discount.toStringAsFixed(2)}', isEditable: true),
                      _buildTotalRow('Tax', '৳${(subtotal * _taxRate).toStringAsFixed(2)}'),
                      _buildTotalRow('Shipping', '৳${shipping.toStringAsFixed(2)}', isEditable: true),
                      _buildTotalRow('Advance Paid', '৳${advancePaid.toStringAsFixed(2)}', isEditable: true),
                      Divider(),
                      _buildTotalRow('Total', '৳${total.toStringAsFixed(2)}', isBold: true),
                    ],
                  ),
                );
              }
              
              // Add edit handlers
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
              
              // Update _buildTotalRow to use the correct handlers
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
              }      ],
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