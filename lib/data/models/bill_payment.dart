import 'package:flutter/foundation.dart';

/// Represents an executed payment transaction
@immutable
class BillPayment {
  final String id;
  final String savedBillerId;
  final int amountPaise; // Money in integer paise
  final String status;    // "SUCCESS", "PENDING", or "FAILED"
  final String bankRef;   // Bank reference mapper number
  final String billerRef; // Biller reference number
  final String at;        // ISO-8601 UTC execution timestamp

  const BillPayment({
    required this.id,
    required this.savedBillerId,
    required this.amountPaise,
    required this.status,
    required this.bankRef,
    required this.billerRef,
    required this.at,
  });

  factory BillPayment.fromJson(Map<String, dynamic> json) {
    return BillPayment(
      id: json['id'] as String? ?? '',
      savedBillerId: json['savedBillerId'] as String? ?? '',
      amountPaise: json['amountPaise'] as int? ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      bankRef: json['bankRef'] as String? ?? '',
      billerRef: json['billerRef'] as String? ?? '',
      at: json['at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'savedBillerId': savedBillerId,
      'amountPaise': amountPaise,
      'status': status,
      'bankRef': bankRef,
      'billerRef': billerRef,
      'at': at,
    };
  }
}