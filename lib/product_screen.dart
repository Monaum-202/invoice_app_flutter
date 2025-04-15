import 'package:flutter/material.dart';
import 'package:invo/product_edit.dart';
import 'package:invo/services/ProductService.dart';
import 'models/product_model.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();

  List<Product> _productList = [];
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _productService.getAll(page: _currentPage);
      setState(() {
        _productList = response['products'];
        _totalPages = response['totalPages'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
      _loadProducts();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _loadProducts();
    }
  }

  void _refreshList() {
    setState(() {
      _currentPage = 0;
    });
    _loadProducts();
  }

  void _deleteProduct(int id) async {
    try {
      await _productService.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
      _refreshList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product')),
      );
    }
  }

  void _editProduct(Product product) async {
    final updatedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(product: product),
      ),
    );
    if (updatedProduct != null) {
      _refreshList();
    }
  }

  void _addProduct() async {
    final newProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(product: Product()),
      ),
    );
    if (newProduct != null) {
      _refreshList();
    }
  }

  List<Widget> _buildPaginationButtons() {
    List<Widget> buttons = [];
    for (int i = 0; i < _totalPages; i++) {
      buttons.add(
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentPage = i;
            });
            _loadProducts();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: i == _currentPage ? Colors.blue : Colors.grey,
          ),
          child: Text('${i + 1}'),
        ),
      );
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product List')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _productList.isEmpty
                      ? Center(child: Text('No products found'))
                      : RefreshIndicator(
                          onRefresh: () async {
                            _refreshList();
                          },
                          child: ListView.builder(
                            itemCount: _productList.length,
                            itemBuilder: (context, index) {
                              final product = _productList[index];
                              return Card(
                                elevation: 5,
                                shadowColor: Colors.black.withOpacity(0.1),
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  title: Text(
                                    product.name ?? 'Unnamed Product',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          product.description ?? 'No description'),
                                      SizedBox(height: 4),
                                      Text(
                                        'Price: ৳${(product.price ?? 0).toStringAsFixed(2)} | Tax: ${(product.taxRate ?? 0).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon:
                                            Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editProduct(product),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteProduct(product.id!),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
                Padding(
  padding: const EdgeInsets.all(8.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Previous button
      ElevatedButton(
        onPressed: _currentPage > 0 ? _goToPreviousPage : null,
        child: const Text('Previous'),
      ),
      const SizedBox(width: 8),

      // Pagination numbers with ellipsis
      ..._buildPaginationButtons(),

      const SizedBox(width: 8),
      // Next button
      ElevatedButton(
        onPressed: _currentPage < _totalPages - 1 ? _goToNextPage : null,
        child: const Text('Next'),
      ),
    ],
  ),
),

              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        tooltip: 'Add New Product',
        elevation: 10,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}
