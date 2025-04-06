import 'package:invo/models/business_info.dart';
import 'package:invo/models/client_model.dart';
import 'package:invo/models/invoice_item.dart';

class Invoice {
  int? id;
  String invoiceNumber;
  double subtotal;
  // double totalAmount;
  double discountPersentage;
  double discountCash;
  String status;
  DateTime issueDate;
  DateTime dueDate;
  int createdBy;
  Client client;
  List<InvoiceItem> items;
  BusinessInfo businessInfo;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.subtotal,
    // required this.totalAmount,
    required this.discountPersentage,
    required this.discountCash,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    required this.createdBy,
    required this.client,
    required this.items,
    required this.businessInfo,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      subtotal: json['subtotal'],
      // totalAmount: json['totalAmount'],
      discountPersentage: json['discountPersentage'],
      discountCash: json['discountCash'],
      status: json['status'],
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: DateTime.parse(json['dueDate']),
      createdBy: json['createdBy'],
      client: Client.fromJson(json['client']),
      items:
          (json['items'] as List).map((e) => InvoiceItem.fromJson(e)).toList(),
      businessInfo: BusinessInfo.fromJson(json['businessInfo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "invoiceNumber": invoiceNumber,
      "subtotal": subtotal,
      // "totalAmount": totalAmount,
      "discountPersentage": discountPersentage,
      "discountCash": discountCash,
      "status": status,
      "issueDate": issueDate.toIso8601String(),
      "dueDate": dueDate.toIso8601String(),
      "createdBy": createdBy,
      "client": client.toJson(),
      "items": items.map((e) => e.toJson()).toList(),
      "businessInfo": businessInfo.toJson(),
    };
  }

  @override
  String toString() {
    return 'Invoice{id: $id, invoiceNumber: $invoiceNumber, subtotal: $subtotal, discountPersentage: $discountPersentage, discountCash: $discountCash, status: $status, issueDate: $issueDate, dueDate: $dueDate, createdBy: $createdBy, client: $client, items: $items, businessInfo: $businessInfo}';
  }
}
