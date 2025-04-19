// import 'package:e_f/PDFGenerator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ShareInvoicePage(),
      // home: MyBusinessScreen(),

    );
  }
}

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Invoice')),
      body: Center(
        child: ElevatedButton(
          onPressed: generateInvoice,
          child: Text('Generate Invoice PDF'),
        ),
      ),
    );
  }
}

Future<String> generateInvoice() async {
  final pdf = pw.Document();
  final image = pw.MemoryImage(
    (await rootBundle.load(
      'assets/images/fedex-express.png',
    )).buffer.asUint8List(),
  );
  // Add a page to the PDF document
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(image),

            pw.Text(
              'Invoice',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Invoice Number: #12345',
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.Text(
              'Date: ${DateTime.now().toString()}',
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Description', 'Unit Price', 'Quantity', 'Total'],
              data: [
                ['Item 1', '\$10', '2', '\$20'],
                ['Item 2', '\$15', '1', '\$15'],
                ['Item 3', '\$5', '3', '\$15'],
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total: \$50',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 20),

            // Client Information
            pw.Text(
              'Bill To:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('John Doe'),
            pw.Text('123 Main Street'),
            pw.Text('City, Country'),
            pw.Text('Email: john.doe@email.com'),
            pw.SizedBox(height: 20),

            // Items List
            pw.Text(
              'Items',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Item ${index + 1}'),
                    pw.Text('₹${(index + 1) * 200}'),
                  ],
                );
              },
            ),
            pw.SizedBox(height: 20),
            // Total Calculation
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Subtotal:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('₹1000'),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Tax (5%):',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('₹50'),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('₹1050'),
              ],
            ),
            pw.SizedBox(height: 20),

            // Payment Method
            pw.Text('Payment Method: Credit Card'),
            pw.SizedBox(height: 20),

            // Footer
            pw.Text(
              'Thank you for your business!',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ],
        );
      },
    ),
  );

  // Get the directory to save the PDF
  final outputDirectory = await getExternalStorageDirectory();
  final file = File("${outputDirectory?.path}/invoice.pdf");

  // Write the PDF to the file
  await file.writeAsBytes(await pdf.save());
  print("Invoice saved at: ${file.path}");

  return file.path; // Return the file path
}

Future<void> generateInvoiceWithImage() async {
  final pdf = pw.Document();
  final image = pw.MemoryImage(
    (await rootBundle.load(
      'assets/images/fedex-express.png',
    )).buffer.asUint8List(),
  );

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(image),
            pw.Text(
              'Invoice',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            // Add other content here
          ],
        );
      },
    ),
  );

  final outputDirectory = await getExternalStorageDirectory();
  final file = File("${outputDirectory?.path}/invoice_with_image.pdf");

  await file.writeAsBytes(await pdf.save());
  print("Invoice with image saved at: ${file.path}");
}

class ShareInvoicePage extends StatelessWidget {
  // final PDFGenerator _pdfGenerator = PDFGenerator();
  final OpenPDF _openPDF = OpenPDF();

  ShareInvoicePage({super.key});

  void shareInvoice() async {
    final invoicePath =
        await generateInvoice(); // Generate the PDF and get the file path

    final xFile = XFile(invoicePath);

    Share.shareXFiles([xFile], text: 'Here is your invoice');
  }

  // Future<void> _generateAndOpenPDF() async {
  //   File pdfFile = await _pdfGenerator.generatePDF();
  //   _openPDF.openPDF(pdfFile);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate and Share Invoice')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: shareInvoice, // Share invoice when pressed
              child: Text('Generate and Share Invoice'),
            ),

            // ElevatedButton(
            //   onPressed: _generateAndOpenPDF,
            //   child: Text('Generate & Open PDF'),
            // ),
          ],
        ),
      ),
    );
  }
}

class OpenPDF {
  Future<void> openPDF(File pdfFile) async {
    await OpenFile.open(pdfFile.path);
  }
}


