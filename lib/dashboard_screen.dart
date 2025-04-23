// import 'package:flutter/material.dart';
// import 'package:invo/models/business_info.dart';
// import 'package:invo/models/invoice_model.dart';
// import 'package:invo/services/DashboardService.dart';
// import 'package:invo/services/InvoiceService.dart';

// class DashboardPage extends StatefulWidget {
//   final Invoice invoice;
//   final BusinessInfo businessInfo;

//   const DashboardPage({Key? key, required this.invoice}) : super(key: key);

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   final Dashboardservice _dashboardservice = Dashboardservice();

//   double _totalAmount = 0.0;
//   double _totalDueAmount = 0.0;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadTotalAmount();
//   }

//   Future<void> _loadTotalAmount() async {
//     setState(() {
//       _isLoading = true;
//     });
    
//     try {
//       final futures = await Future.wait([
//         _dashboardservice.getTotalAmount(widget.invoice.id!),
//         _dashboardservice.getTotalDueAmount(widget.invoice.id!),
//       ]);
      
//       setState(() {
//         _totalAmount = futures[0];
//         _totalDueAmount = futures[1];
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading amounts: $e')),
//       );
//     }
//   }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(widget.businessInfo.name ?? 'Unknown businessInfo', style: TextStyle(fontSize: 16)),
//           Text('Dashboard', style: TextStyle(fontSize: 10)),
//         ],
//       ),
//       actions: [IconButton(icon: Icon(Icons.more_vert), onPressed: () {})],
//     ),
//     body: SafeArea(
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             children: [
//               GridView.count(
//                 physics: NeverScrollableScrollPhysics(), // disable GridView's own scroll
//                 shrinkWrap: true, // let GridView size itself based on content
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 8,
//                 crossAxisSpacing: 8,
//                 childAspectRatio: 1.3,
//                 children: [
//                   _buildStatCard(
//                     "Total Due",
//                     _isLoading ? "Loading..." : "৳${_totalDueAmount.toStringAsFixed(2)}",
//                     "Unpaid amount",
//                     color: Colors.red,
//                   ),
//                   _buildStatCard(
//                     "Total Balance",
//                     _isLoading ? "Loading..." : "৳${(_totalAmount - _totalDueAmount).toStringAsFixed(2)}",
//                     "Paid amount",
//                   ),
//                   _buildStatCard(
//                     "Total Amount",
//                     _isLoading ? "Loading..." : "৳${_totalAmount.toStringAsFixed(2)}",
//                     "Total invoice amount",
//                   ),
//                   // _buildStatCard("Total Sales", "৳3,000.00", "1 Invoice issued"),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 45),
//                   backgroundColor: Colors.green,
//                 ),
//                 onPressed: () {
//                   // Export logic here
//                 },
//                 child: Text("Export Statement", style: TextStyle(fontSize: 14)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// Widget _buildStatCard(String title, String value, String subtitle, {Color color = Colors.black}) {
//   return Container(
//     padding: EdgeInsets.all(10),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//         SizedBox(height: 6),
//         Text(
//           value,
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
//           overflow: TextOverflow.ellipsis,
//           maxLines: 1,
//         ),
//         SizedBox(height: 4),
//         Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
//       ],
//     ),
//   );
// }
//   @override
//   void dispose() {
//     super.dispose();
//   }