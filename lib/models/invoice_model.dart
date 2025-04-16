import 'package:invo/models/business_info.dart';
import 'package:invo/models/client_model.dart';
import 'package:invo/models/invoice_item.dart';

class Invoice {
  int? id;
  String? invoiceNumber;
  double? subtotal;
  double? totalAmount;
  double? paidAmount;
  double? dueAmount;
  double? discountPersentage;
  double? discountCash;
  String? status;
  DateTime? issueDate;
  DateTime? dueDate;
  int? createdBy;
  Client? client;
  List<InvoiceItem>? items;
  BusinessInfo? businessInfo;

  Invoice({
    this.id,
    this.invoiceNumber,
    this.subtotal,
    this.totalAmount,
    this.paidAmount,
    this.dueAmount,
    this.discountPersentage,
    this.discountCash,
    this.status,
    this.issueDate,
    this.dueDate,
    this.createdBy,
    this.client,
    this.items,
    this.businessInfo,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      subtotal: json['subtotal']?.toDouble(),
      totalAmount: json['totalAmount']?.toDouble(),
      paidAmount: json['paidAmount']?.toDouble(),
      dueAmount: json['dueAmount']?.toDouble(),
      discountPersentage: json['discountPersentage']?.toDouble(),
      discountCash: json['discountCash']?.toDouble(),
      status: json['status'],
      issueDate: json['issueDate'] != null ? DateTime.parse(json['issueDate']) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdBy: json['createdBy'],
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      items: json['items'] != null 
          ? (json['items'] as List).map((e) => InvoiceItem.fromJson(e)).toList()
          : null,
      businessInfo: json['businessInfo'] != null 
          ? BusinessInfo.fromJson(json['businessInfo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "invoiceNumber": invoiceNumber,
      "subtotal": subtotal,
      "totalAmount": totalAmount,
      "paidAmount": paidAmount,
      "dueAmount": dueAmount,
      "discountPersentage": discountPersentage,
      "discountCash": discountCash,
      "status": status,
      "issueDate": issueDate?.toIso8601String(),
      "dueDate": dueDate?.toIso8601String(),
      "createdBy": createdBy,
      "client": client?.toJson(),
      "items": items?.map((e) => e.toJson()).toList(),
      "businessInfo": businessInfo?.toJson(),
    };
  }

  @override
  String toString() {
    return 'Invoice{id: $id, invoiceNumber: $invoiceNumber, subtotal: $subtotal, totalAmount: $totalAmount, paidAmount: $paidAmount, dueAmount: $dueAmount, discountPersentage: $discountPersentage, discountCash: $discountCash, status: $status, issueDate: $issueDate, dueDate: $dueDate, createdBy: $createdBy, client: ${client?.toString()}, items: ${items?.toString()}, businessInfo: ${businessInfo?.toString()}}';
  }
}
