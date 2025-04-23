import 'package:flutter/material.dart';
import 'package:invo/services/AuthService.dart';
import 'package:invo/services/DashboardService.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  double _totalAmount = 0.0;
  double _totalDueAmount = 0.0;
  double _totalPaidAmount = 0.0;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final username = await _authService.getUsername();
      if (username == null) {
        throw Exception('Please log in to view the dashboard');
      }

      setState(() => _username = username);
      
      final amounts = await _dashboardService.getTotalAmountsByUser(username);
      
      if (!mounted) return;
      
      setState(() {
        _totalAmount = amounts[0];
        _totalDueAmount = amounts[1];
        _totalPaidAmount = amounts[2];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      final errorMessage = e.toString().contains('Failed to load dashboard data')
          ? 'Could not load dashboard data. Please try again.'
          : e.toString().replaceAll('Exception: ', '');
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
        ),
      );
      
      if (errorMessage.contains('Please log in')) {
        Navigator.of(context).pop();
      }
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: TextStyle(fontSize: 16)),
            if (_username != null)
              Text(_username!, style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        GridView.count(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.3,
                          children: [
                            _buildStatCard(
                              "Total Due",
                              "৳${_totalDueAmount.toStringAsFixed(2)}",
                              "Total unpaid amount",
                              color: Colors.red,
                            ),
                            _buildStatCard(
                              "Total Balance",
                              "৳${_totalPaidAmount.toStringAsFixed(2)}",
                              "Total paid amount",
                            ),
                            _buildStatCard(
                              "Total Amount",
                              "৳${_totalAmount.toStringAsFixed(2)}",
                              "Total invoice amount",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
