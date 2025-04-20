import 'dart:html' as html;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../models/business_info.dart';

class InvoicePdfGenerator {
  static Future<void> generateInvoice(Invoice invoice, BusinessInfo businessInfo) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(invoice, businessInfo),
            pw.SizedBox(height: 30),
            _buildInvoiceInfo(invoice),
            pw.SizedBox(height: 30),
            _buildItemsTable(invoice),
            pw.SizedBox(height: 30),
            _buildTotal(invoice),
            pw.SizedBox(height: 30),
            _buildFooter(businessInfo),
          ];
        },
      ),
    );

    // Generate PDF bytes
    final bytes = await pdf.save();
    
    // Create the file name
    final fileName = invoice.invoiceNumber?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? 'invoice';
    
    // Create the blob
    final blob = html.Blob([bytes], 'application/pdf');
    
    // Create a URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create an anchor element and trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$fileName.pdf')
      ..click();
    
    // Clean up by revoking the object URL
    html.Url.revokeObjectUrl(url);
    } catch (e, stackTrace) {
      print('Error generating PDF: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to generate PDF: $e');
    }
  }

  static pw.Widget _buildHeader(Invoice invoice, BusinessInfo businessInfo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Business Info
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  businessInfo.businessName ?? '',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(businessInfo.address ?? ''),
                pw.Text(businessInfo.phone ?? ''),
                pw.Text(businessInfo.email ?? ''),
              ],
            ),
            // Invoice Title
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        // Client Info
        if (invoice.client != null) ...[
          pw.Text(
            'Bill To:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(invoice.client!.name ?? ''),
          pw.Text(invoice.client!.address ?? ''),
          pw.Text(invoice.client!.phone ?? ''),
          pw.Text(invoice.client!.email ?? ''),
        ],
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(Invoice invoice) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice Number:'),
              pw.Text('Issue Date:'),
              pw.Text('Due Date:'),
              pw.Text('Status:'),
            ],
          ),
          pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.end,
  children: [
    pw.Text(invoice.invoiceNumber ?? ''),
    pw.Text(invoice.issueDate != null ? dateFormat.format(invoice.issueDate!) : 'N/A'),
    pw.Text(invoice.dueDate != null ? dateFormat.format(invoice.dueDate!) : 'N/A'),
    pw.Text(
      invoice.status ?? '',
      style: pw.TextStyle(
        color: invoice.status?.toLowerCase() == 'paid' 
          ? PdfColors.green700 
          : PdfColors.red700,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  ],
),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Description', isHeader: true),
            _buildTableCell('Quantity', isHeader: true, alignment: pw.Alignment.center),
            _buildTableCell('Unit Price', isHeader: true, alignment: pw.Alignment.center),
            _buildTableCell('Total', isHeader: true, alignment: pw.Alignment.center),
          ],
        ),
        // Table Items
        if (invoice.items != null)
          ...invoice.items!.map((item) => pw.TableRow(
            children: [
              _buildTableCell(item.itemName ?? ''),
              _buildTableCell(item.quantity?.toString() ?? '', alignment: pw.Alignment.center),
              _buildTableCell('BDT ${item.unitPrice?.toStringAsFixed(2) ?? 0.00}', alignment: pw.Alignment.center),
              _buildTableCell('BDT ${((item.quantity ?? 0) * (item.unitPrice ?? 0)).toStringAsFixed(2)}', alignment: pw.Alignment.center),
            ],
          )).toList(),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.Alignment alignment = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: alignment,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  static pw.Widget _buildTotal(Invoice invoice) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildTotalRow('Subtotal:', invoice.subtotal ?? 0),
          if ((invoice.discountPersentage ?? 0) > 0)
            _buildTotalRow('Discount:', invoice.discountCash ?? 0),
          _buildTotalRow('Total:', invoice.totalAmount ?? 0, isTotal: true),
          pw.SizedBox(height: 10),
          _buildTotalRow('Paid Amount:', invoice.paidAmount ?? 0),
          _buildTotalRow('Due Amount:', invoice.dueAmount ?? 0, isDue: true),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, double amount, {bool isTotal = false, bool isDue = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : null,
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Container(
            width: 120,
            child: pw.Text(
              'BDT ${amount.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontWeight: isTotal || isDue ? pw.FontWeight.bold : null,
                color: isDue && amount > 0 ? PdfColors.red700 : null,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(BusinessInfo businessInfo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text('Payment Terms:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        // pw.Text(businessInfo.paymentTerms ?? 'Payment is due within 30 days'),
        // pw.SizedBox(height: 10),
        pw.Text('Notes:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        // pw.Text(businessInfo.notes ?? 'Thank you for your business!'),
      ],
    );
  }


}
