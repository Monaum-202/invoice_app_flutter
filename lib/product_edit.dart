import 'package:flutter/material.dart';
import 'package:invo/services/ProductService.dart';
import 'models/product_model.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late TextEditingController _nameController;
  late TextEditingController _productCodeController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _taxRateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _productCodeController = TextEditingController(text: widget.product.productCode);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _taxRateController = TextEditingController(text: widget.product.taxRate.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _productCodeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

void _saveProduct() async {
  if (_formKey.currentState!.validate()) {
    try {
      Product newProduct = Product(
        name: _nameController.text.trim(),
        productCode: _productCodeController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        taxRate: double.tryParse(_taxRateController.text) ?? 0.0,
      );

      final result = await _productService.createProduct(newProduct);
      Navigator.pop(context, result); // Navigate back with the created product
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating product: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a product name' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _productCodeController,
                decoration: InputDecoration(labelText: 'Product Code'),
                validator: (value) => value!.isEmpty ? 'Please enter a product code' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty || double.tryParse(value) == 0.0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _taxRateController,
                decoration: InputDecoration(labelText: 'Tax Rate (%)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty || double.tryParse(value) == 0.0) {
                    return 'Enter a valid tax rate';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
