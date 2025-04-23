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
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      productCode: json['productCode']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] is String 
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price']?.toDouble() ?? 0.0),
      taxRate: json['taxRate'] is String 
          ? double.tryParse(json['taxRate']) ?? 0.0
          : (json['taxRate']?.toDouble() ?? 0.0),
    );
  }

  // Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString() ?? '0',  // Convert to String to avoid type issues
      'name': name ?? '',
      'productCode': productCode ?? '',
      'description': description ?? '',
      'price': price?.toString() ?? '0.0',
      'taxRate': taxRate?.toString() ?? '0.0'
    };
  }
}
