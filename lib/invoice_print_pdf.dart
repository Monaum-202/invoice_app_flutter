// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: InvoiceScreen(),

//       // home: MyBusinessScreen(),
//     );
//   }
// }

// class InvoiceScreen extends StatelessWidget {
//   const InvoiceScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Business Logo',
//               style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [_invoiceMeta()],
//             ),
//             const Divider(height: 40, thickness: 2),

//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _fromSection(),
//                 const SizedBox(width: 40),
//                 _billToSection(),
//               ],
//             ),

//             const SizedBox(height: 30),
//             _tableHeader(),
//             _tableRow('mango', '6', '৳500.00', '৳3,000.00'),
//             _totalRow('৳3,000.00'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _invoiceDetails() => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: const [
//       Text('FROM', style: TextStyle(fontWeight: FontWeight.bold)),
//       Text('Jersey Tenda'),
//       Text('Gazipur'),
//       Text('01567941202'),
//       Text('jerseytenda@gmail.com'),
//       Text('jerseytenda.com'),
//       Text('TIN: BD24201479'),
//     ],
//   );

//   Widget _invoiceMeta() => Column(
//     crossAxisAlignment: CrossAxisAlignment.end,
//     children: const [
//       Text('INVOICE #: INV00003'),
//       Text('ISSUE DATE: 19/04/2025'),
//       Text('DUE DATE: 26/04/2025'),
//     ],
//   );

//   Widget _fromSection() => Expanded(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: const [
//         Text('FROM', style: TextStyle(fontWeight: FontWeight.bold)),
//         Text('Jersey Tenda'),
//         Text('Gazipur'),
//         Text('01567941202'),
//         Text('jerseytenda@gmail.com'),
//         Text('jerseytenda.com'),
//         Text('TIN: BD24201479'),
//       ],
//     ),
//   );

//   Widget _billToSection() => Expanded(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: const [
//         Text('BILL TO', style: TextStyle(fontWeight: FontWeight.bold)),
//         Text('fjskxn'),
//       ],
//     ),
//   );

//   Widget _tableHeader() => Container(
//     color: Colors.black,
//     padding: const EdgeInsets.symmetric(vertical: 10),
//     child: Row(
//       children: const [
//         Expanded(
//           flex: 4,
//           child: Text('DESCRIPTION', style: TextStyle(color: Colors.white)),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text('QTY', style: TextStyle(color: Colors.white)),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text('PRICE', style: TextStyle(color: Colors.white)),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text('AMOUNT', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );

//   Widget _tableRow(String desc, String qty, String price, String amt) =>
//       Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         child: Row(
//           children: [
//             Expanded(flex: 4, child: Text(desc)),
//             Expanded(flex: 2, child: Text(qty)),
//             Expanded(flex: 2, child: Text(price)),
//             Expanded(flex: 2, child: Text(amt)),
//           ],
//         ),
//       );

//   Widget _totalRow(String total) => Align(
//     alignment: Alignment.centerRight,
//     child: Container(
//       color: Colors.black,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Text(
//         'TOTAL  $total',
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     ),
//   );
// }
