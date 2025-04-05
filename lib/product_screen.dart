import 'package:flutter/material.dart';
import 'package:invo/product_edit.dart';
import 'package:invo/services/ProductService.dart';
import 'models/product_model.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> products;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    products = _productService.getAll();  // Fetch products when the page loads
  }

  // Handle product deletion
  void _deleteProduct(int id) async {
    try {
      await _productService.deleteProduct(id);
      setState(() {
        products = _productService.getAll(); // Refresh the product list after deletion
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product')));
    }
  }

  // Handle product editing
  void _editProduct(Product product) async {
    // Navigate to the edit screen and pass the selected product
    final updatedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(product: product),
      ),
    );

    if (updatedProduct != null) {
      setState(() {
        products = _productService.getAll(); // Refresh product list after editing
      });
    }
  }

  // Handle adding a new product
  void _addProduct() async {
    // Navigate to the product edit screen without a product (for creating a new product)
    final newProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(product: Product()),
      ),
    );

    if (newProduct != null) {
      setState(() {
        products = _productService.getAll(); // Refresh product list after adding
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product List')),
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found'));
          } else {
            List<Product> productList = snapshot.data!;
            return ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];
                return Card(
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.1),
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      product.name ?? 'Unnamed Product',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.description ?? 'No description'),
                        SizedBox(height: 4),
                        Text(
                          'Price: ৳${(product.price ?? 0).toStringAsFixed(2)} | Tax: ${(product.taxRate ?? 0).toStringAsFixed(1)}%',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _editProduct(product); // Navigate to edit page
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteProduct(product.id!); // Call delete function
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: Icon(Icons.add),
        tooltip: 'Add New Product',
        elevation: 10,
        backgroundColor: Colors.blue,
      ),
    );
  }
}
