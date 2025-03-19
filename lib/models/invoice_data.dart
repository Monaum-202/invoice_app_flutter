import 'package:flutter/foundation.dart';

class InvoiceData extends ChangeNotifier {
  final List<Map<String, dynamic>> _invoices = [];

  List<Map<String, dynamic>> get invoices => _invoices;

  void addInvoice(Map<String, dynamic> invoice) {
    _invoices.add(invoice);
    notifyListeners();
  }

  void updateInvoice(int index, Map<String, dynamic> invoice) {
    if (index >= 0 && index < _invoices.length) {
      _invoices[index] = invoice;
      notifyListeners();
    }
  }

  void deleteInvoice(int index) {
    if (index >= 0 && index < _invoices.length) {
      _invoices.removeAt(index);
      notifyListeners();
    }
  }
}
