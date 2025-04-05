// lib/models/product_model.dart

class Product {
  int? id;
  String? productCode;
  String? name;
  String? description;
  double? price;
  double? taxRate;

  Product({
    this.id,
    this.productCode,
    this.name,
    this.description,
    this.price,
    this.taxRate,
  });

  // Factory method to create a Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productCode: json['productCode']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      taxRate: json['taxRate'] != null ? double.parse(json['taxRate'].toString()) : null,
    );
  }

  // Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "productCode": productCode,
      "name": name,
      "description": description,
      "price": price,
      "taxRate": taxRate,
    };
  }
}
