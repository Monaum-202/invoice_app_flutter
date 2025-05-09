class InvoiceItem {
  int? id;
  String itemName;
  String? description;
  int quantity;
  double unitPrice;
  double totalPrice;
  double tax;
  double taxAmount;

  InvoiceItem({
    this.id,
    required this.itemName,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.tax = 0.0,
    this.taxAmount = 0.0,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      itemName: json['itemName'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      totalPrice: json['totalPrice'],
      tax: json['tax']?.toDouble() ?? 0.0,
      taxAmount: json['taxAmount']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemName': itemName,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'tax': tax,
        'taxAmount': taxAmount,
      };
}
