import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:invo/new_invoice_screen.dart';
import 'package:invo/services/InvoiceService.dart';
import 'package:invo/services/BusinessInfoService.dart';
import 'package:invo/services/AuthService.dart';
import 'package:invo/services/invoice_print_pdf.dart' as pdf_generator;
import 'package:invo/screens/pdf_viewer_screen.dart';
import 'models/invoice_model.dart';
import 'models/business_info.dart';

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

  Future<void> _fetchInvoices({bool isRefresh = false}) async {
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
      String errorMessage;
      if (e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      } else {
        errorMessage =
            isRefresh ? 'Error refreshing invoices' : 'Error loading invoices';
      }

      print('$errorMessage: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));

      if (!isRefresh) {
        setState(() {
          _invoiceList = [];
          _filteredInvoiceList = [];
          _totalPages = 1;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInvoices() => _fetchInvoices(isRefresh: false);
  Future<void> _refreshList() => _fetchInvoices(isRefresh: true);

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

  Future<void> _generateAndOpenInvoicePdf(Invoice invoice) async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final username = await authService.getUsername();
      if (username == null) {
        throw Exception('You must be logged in to generate invoices');
      }

      final businessService = BusinessInfoService();
      final businessInfo = await businessService.getBusinessInfoByUser(
        username,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generating PDF...')));

      final pdfBytes = await pdf_generator.InvoicePdfGenerator.generateInvoice(
        invoice,
        businessInfo,
      );
      ScaffoldMessenger.of(context).clearSnackBars();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PdfViewerScreen(
                pdfBytes: pdfBytes,
                title: 'Invoice ${invoice.invoiceNumber}',
              ),
        ),
      );
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied to create or open PDF';
      } else if (e.toString().contains('storage')) {
        errorMessage = 'Not enough storage space to create PDF';
      } else {
        errorMessage = 'Error generating PDF. Please try again.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch() async {
    String searchQuery = _searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await _invoiceService.searchInvoices(searchQuery);
        if (mounted) {
          final List<dynamic> invoiceList =
              response['invoices'] as List<dynamic>;
          setState(() {
            _filteredInvoiceList = invoiceList.cast<Invoice>();
            _totalPages = response['totalPages'] ?? 1;
            _currentPage = response['currentPage'] ?? 0;
          });
          print('Found ${_filteredInvoiceList.length} invoices');
        }
      } catch (e, stackTrace) {
        print('Search error: $e\n$stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error searching invoices: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'), // Title stays simple
        actions: [
          Container(
            width: 200, // fixed width for search box
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Color.fromARGB(255, 15, 15, 15)),
              textInputAction:
                  TextInputAction.search, // <-- Important for Enter button
              onSubmitted: (value) async {
                await _performSearch();
              }, // <-- Important to handle Enter key
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(
                  color: Color.fromARGB(179, 73, 73, 73),
                ),
                prefixIcon: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 26, 25, 25),
                  ),
                  onPressed: () async {
                    await _performSearch();
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 150, 150, 150),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredInvoiceList.isEmpty
                    ? const Center(child: Text('No invoices found'))
                    : RefreshIndicator(
                      onRefresh: _refreshList,
                      child: ListView.builder(
                        itemCount: _filteredInvoiceList.length,
                        itemBuilder: (context, index) {
                          final invoice = _filteredInvoiceList[index];
                          return Dismissible(
                            key: Key(invoice.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed:
                                (direction) => _deleteInvoice(invoice.id!),
                            child: InkWell(
                              onTap:
                                  () => _generateAndOpenInvoicePdf(
                                    invoice,
                                  ), // PDF logic
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Top Row: Invoice number and status
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoice.invoiceNumber ??
                                                    'No Invoice #',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColorDark,
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
                                              color:
                                                  invoice.status == 'PAID'
                                                      ? Colors.green.shade100
                                                      : Colors.orange.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              invoice.status ?? 'N/A',
                                              style: TextStyle(
                                                color:
                                                    invoice.status == 'PAID'
                                                        ? Colors.green.shade800
                                                        : Colors
                                                            .orange
                                                            .shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Divider(height: 16),

                                      // Bottom Row: Client, Company, Dates and Amounts
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Left section
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoice.client?.name ??
                                                    'Client: N/A',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                invoice.companyName ??
                                                    'Company: N/A',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              if (invoice.status != 'PAID') ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Due Date: ${invoice.dueDate != null ? DateFormat('dd/MMM/yyyy').format(invoice.dueDate!) : 'N/A'}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ],
                                              if (invoice.status != 'PAID' &&
                                                  invoice.dueDate != null &&
                                                  _calculateOverdueDays(
                                                        invoice.dueDate,
                                                      ) >
                                                      0)
                                                Text(
                                                  'Overdue - ${_calculateOverdueDays(invoice.dueDate)} days',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          // Right section
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
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
                                              const SizedBox(height: 6),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                tooltip: 'Edit Invoice',
                                                onPressed:
                                                    () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                NewInvoiceScreen(
                                                                  invoice:
                                                                      invoice,
                                                                ),
                                                      ),
                                                    ).then((value) {
                                                      _refreshList();
                                                    }),
                                              ),
                                              const SizedBox(height: 6),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.picture_as_pdf,
                                                  color: Colors.deepPurple,
                                                ),
                                                tooltip: 'Download PDF',
                                                onPressed:
                                                    () =>
                                                        _generateAndOpenInvoicePdf(
                                                          invoice,
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
                  onPressed:
                      _currentPage < _totalPages - 1 ? _goToNextPage : null,
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
