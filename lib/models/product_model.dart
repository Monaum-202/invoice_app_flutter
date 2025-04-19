// lib/models/product_model.dart

class Product {
  int? id;
  
  String? name;
  String? productCode;
  String? description;
  double? price;
  double? taxRate;

  Product({
    this.id,
    this.name,
    this.productCode,
    this.description,
    this.price,
    this.taxRate,
  });

  // Factory method to create a Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name']?.toString(),
      productCode: json['productCode']?.toString(),
      description: json['description']?.toString(),
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      taxRate: json['taxRate'] != null ? double.parse(json['taxRate'].toString()) : null,
    );
  }

  // Convert Product to JSON
  Map<String, dynamic> toJson() {
    final map = {
      "name": name,
      "productCode": productCode,
      "description": description,
      "price": price,
      "taxRate": taxRate,
    };
    if (id != null) {
      map["id"] = id;
    }
    return map;
  }
}
