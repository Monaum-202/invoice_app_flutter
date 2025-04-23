import 'package:flutter/material.dart';
import 'package:invo/client_edit.dart';
import 'package:invo/services/AuthService.dart';
import 'package:invo/services/ClientService.dart';
import 'models/client_model.dart';

class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  _ClientListPageState createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  final ClientService _clientService = ClientService();

  List<Client> _clientList = [];
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });

    final clientService = ClientService();
    List<Client> clients = [];

    try {
      final authService = AuthService();
      final username = await authService.getUsername();

      if (username == null || username.isEmpty) {
        throw Exception('Username is required. Please log in again.');
      }

      final response = await clientService.getClientsByUser(
        username,
        _currentPage,
        10,
      );

      if (response['totalPages'] != null) {
        _totalPages = response['totalPages'];
      }

      if (response['content'] != null) {
        clients =
            (response['content'] as List)
                .map((client) => Client.fromJson(client))
                .toList();
      }

      setState(() {
        _clientList = clients;
        _currentPage = response['currentPage'] ?? 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading clients: $e')));
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
      _loadClients();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _loadClients();
    }
  }

  void _refreshList() {
    setState(() {
      _currentPage = 0;
    });
    _loadClients();
  }

  void _deleteClient(int id) async {
    try {
      await _clientService.deleteClient(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Client deleted successfully')));
      _refreshList();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete client')));
    }
  }

  void _editClient(Client client) async {
    final updatedClient = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditClientPage(client: client)),
    );
    if (updatedClient != null) {
      _refreshList();
    }
  }

  void _addClient() async {
    final newClient = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditClientPage(client: Client())),
    );
    if (newClient != null) {
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
            _loadClients();
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
      appBar: AppBar(title: Text('Client List')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        _clientList.isEmpty
                            ? Center(
                              child: Text(
                                'No clients found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: () async => _refreshList(),
                              child: ListView.builder(
                                itemCount: _clientList.length,
                                itemBuilder: (context, index) {
                                  final client = _clientList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Card(
                                      color: const Color(
                                        0xFFF5F9FF,
                                      ), // Light blue background
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: BorderSide(
                                          color: Colors.blue.shade100,
                                          width: 1,
                                        ),
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ClientDashboardPage(client: client),
                                            ),
                                          );
                                        },
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 16,
                                            ),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue.shade600,
                                          child: Text(
                                            client.name
                                                    ?.substring(0, 1)
                                                    .toUpperCase() ??
                                                "?",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          client.name ?? 'Unnamed Client',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.blueGrey.shade900,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 4),
                                            Text(
                                              client.email ?? 'No email',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              client.phone ?? 'No phone',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Wrap(
                                          spacing: 4,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.blue.shade700,
                                              ),
                                              onPressed:
                                                  () => _editClient(client),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red.shade400,
                                              ),
                                              onPressed:
                                                  () =>
                                                      _deleteClient(client.id!),
                                            ),
                                          ],
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
                        // Previous button
                        ElevatedButton(
                          onPressed:
                              _currentPage > 0 ? _goToPreviousPage : null,
                          child: const Text('Previous'),
                        ),
                        const SizedBox(width: 8),

                        // Pagination numbers with ellipsis
                        ..._buildPaginationButtons(),

                        const SizedBox(width: 8),
                        // Next button
                        ElevatedButton(
                          onPressed:
                              _currentPage < _totalPages - 1
                                  ? _goToNextPage
                                  : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClient,
        tooltip: 'Add New Client',
        elevation: 10,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}

class ClientDashboardPage extends StatefulWidget {
  final Client client;

  const ClientDashboardPage({Key? key, required this.client}) : super(key: key);

  @override
  State<ClientDashboardPage> createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  final ClientService _clientService = ClientService();

  double _totalAmount = 0.0;
  double _totalDueAmount = 0.0;
  double _totalPaidAmount = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTotalAmount();
  }

  Future<void> _loadTotalAmount() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final futures = await Future.wait([
        _clientService.getTotalAmount(widget.client.id!),
        _clientService.getTotalDueAmount(widget.client.id!),
        _clientService.getTotalPaidAmount(widget.client.id!),
      ]);
      
      setState(() {
        _totalAmount = futures[0];
        _totalDueAmount = futures[1];
        _totalPaidAmount = futures[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading amounts: $e')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.client.name ?? 'Unknown Client', style: TextStyle(fontSize: 16)),
          Text('Dashboard', style: TextStyle(fontSize: 10)),
        ],
      ),
      actions: [IconButton(icon: Icon(Icons.more_vert), onPressed: () {})],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              GridView.count(
                physics: NeverScrollableScrollPhysics(), // disable GridView's own scroll
                shrinkWrap: true, // let GridView size itself based on content
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    "Total Due",
                    _isLoading ? "Loading..." : "৳${_totalDueAmount.toStringAsFixed(2)}",
                    "Unpaid amount",
                    color: Colors.red,
                  ),
                  _buildStatCard(
                    "Total Balance",
                    _isLoading ? "Loading..." : "৳${_totalPaidAmount.toStringAsFixed(2)}",
                    "Paid amount",
                  ),
                  _buildStatCard(
                    "Total Amount",
                    _isLoading ? "Loading..." : "৳${_totalAmount.toStringAsFixed(2)}",
                    "Total invoice amount",
                  ),
                  // _buildStatCard("Total Sales", "৳3,000.00", "1 Invoice issued"),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 45),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  // Export logic here
                },
                child: Text("Export Statement", style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildStatCard(String title, String value, String subtitle, {Color color = Colors.black}) {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
      ],
    ),
  );
}
  @override
  void dispose() {
    super.dispose();
  }

}
