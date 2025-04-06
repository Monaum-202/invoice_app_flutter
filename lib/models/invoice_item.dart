class InvoiceItem {
  int? id;
  String itemName;
  int quantity;
  double unitPrice;
  double totalPrice;

  InvoiceItem({
    this.id,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      itemName: json['itemName'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      totalPrice: json['totalPrice'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemName': itemName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };
}
