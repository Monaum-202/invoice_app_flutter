import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invo/new_invoice_screen.dart';
import 'package:invo/services/InvoiceService.dart';
import 'models/invoice_model.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  _InvoiceListPageState createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  final InvoiceService _invoiceService = InvoiceService();

  List<Invoice> _invoiceList = [];
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;
  List<Invoice> _filteredInvoiceList = [];
  String _selectedFilter = "All";
  List<String> _filters = ["All", "Paid", "Unpaid", "Overdue"];
  String _selectedSortOption = "Date";

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> response;
      print('Loading invoices with filter: $_selectedFilter');

      switch (_selectedFilter) {
        case 'Paid':
          response = await _invoiceService.getPaidInvoices(
            page: _currentPage,
            direction: 'desc',
          );
          break;
        case 'Unpaid':
          response = await _invoiceService.getUnpaidInvoices(
            page: _currentPage,
            direction: 'desc',
          );
          break;
        case 'Overdue':
          response = await _invoiceService.getOverDueInvoices(
            page: _currentPage,
            direction: 'desc',
          );
          break;
        default:
          response = await _invoiceService.getAll(page: _currentPage);
      }

      setState(() {
        _invoiceList = response['invoices'];
        _totalPages = response['totalPages'];
        _filteredInvoiceList = _invoiceList;
      });
    } catch (e) {
      print('Error loading invoices: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading invoices: $e')),
      );
      setState(() {
        _invoiceList = [];
        _filteredInvoiceList = [];
        _totalPages = 1;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> response;

      switch (_selectedFilter) {
        case 'Paid':
          response = await _invoiceService.getPaidInvoices(
            page: _currentPage,
            direction: 'desc',
          );
          break;
        case 'Unpaid':
          response = await _invoiceService.getUnpaidInvoices(
            page: _currentPage,
            direction: 'desc',
          );
          break;
        case 'Overdue':
          response = await _invoiceService.getOverDueInvoices(
            page: _currentPage,
            direction: 'desc',
          );
          break;
        default:
          response = await _invoiceService.getAll(page: _currentPage);
      }

      setState(() {
        _invoiceList = response['invoices'];
        _totalPages = response['totalPages'];
        _filteredInvoiceList = _invoiceList;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing invoices: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    _loadInvoices();
  }

  void _deleteInvoice(int id) async {
    try {
      await _invoiceService.deleteInvoice(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice deleted successfully')),
      );
      _refreshList();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete invoice')));
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _loadInvoices();
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
      _loadInvoices();
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
            _loadInvoices();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _currentPage == i
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
          ),
          child: Text(
            '${i + 1}',
            style: TextStyle(
              color: _currentPage == i ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }
    return buttons;
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = label;
          _currentPage = 0; // Reset to first page when changing filters
        });
        _applyFilter(); // filter invoices on button tap
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
        foregroundColor:
            isSelected ? Colors.white : Theme.of(context).primaryColor,
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
      child: Text(label),
    );
  }

  // Calculate overdue days
  int _calculateOverdueDays(DateTime? dueDate) {
    if (dueDate == null) return 0;
    final now = DateTime.now();
    if (dueDate.isAfter(now)) return 0;
    return now.difference(dueDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search logic
              print('Search tapped');
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter logic
              print('Filter tapped');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton("All"),
                  const SizedBox(width: 8),
                  _buildFilterButton("Overdue"),
                  const SizedBox(width: 8),
                  _buildFilterButton("Unpaid"),
                  const SizedBox(width: 8),
                  _buildFilterButton("Paid"),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredInvoiceList.isEmpty
                    ? const Center(child: Text('No invoices found'))
                    : RefreshIndicator(
                        onRefresh: _refreshList,
                        child: ListView.builder(
                          itemCount: _filteredInvoiceList.length,
                          itemBuilder: (context, index) {
                            final invoice = _filteredInvoiceList[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              invoice.invoiceNumber ?? 'No Invoice #',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).primaryColorDark,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 14,
                                                  color: Colors.grey[700],
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Issue Date: ${invoice.issueDate != null ? DateFormat('dd/MMM/yyyy').format(invoice.issueDate!) : 'N/A'}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: invoice.status == 'PAID'
                                                ? Colors.green.shade100
                                                : Colors.orange.shade100,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            invoice.status ?? 'N/A',
                                            style: TextStyle(
                                              color: invoice.status == 'PAID'
                                                  ? Colors.green.shade800
                                                  : Colors.orange.shade800,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Dismissible(
                                      key: Key(invoice.id.toString()),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        color: Colors.redAccent,
                                        alignment: Alignment.centerRight,
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onDismissed: (direction) => _deleteInvoice(invoice.id!),
                                      child: Card(
                                        elevation: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // Left side (Client and Business)
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        invoice.client?.name ?? 'Client: N/A',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        invoice.businessInfo?.businessName ?? 'Business: N/A',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      if (invoice.status != 'PAID')
                                                        Text(
                                                          'Due Date: ${invoice.dueDate != null ? DateFormat('dd/MMM/yyyy').format(invoice.dueDate!) : 'N/A'}',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.redAccent,
                                                          ),
                                                        ),
                                                      if (invoice.status != 'PAID' &&
                                                          invoice.dueDate != null &&
                                                          _calculateOverdueDays(invoice.dueDate) > 0)
                                                        Text(
                                                          'Overdue - ${_calculateOverdueDays(invoice.dueDate)} days',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.red,
                                                            fontWeight: FontWeight.bold,
                                                            decoration: TextDecoration.underline,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  // Right side (Amount details)
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        '৳${(invoice.totalAmount ?? 0.0).toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Paid: ৳${(invoice.paidAmount ?? 0.0).toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Due: ৳${(invoice.dueAmount ?? 0.0).toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.redAccent,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
                ElevatedButton(
                  onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                ..._buildPaginationButtons(),
                const SizedBox(width: 8),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewInvoiceScreen()),
          ).then((value) {
            _refreshList();
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}