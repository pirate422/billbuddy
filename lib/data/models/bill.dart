import 'package:flutter/foundation.dart';

/// Represents a bill fetched for a saved biller
@immutable
class Bill {
  final String billerRef;
  final int amountPaise; // Money in integer paise
  final String duedate;   // ISO-8601 UTC timestamp
  final String period;    // e.g. "OCT 2026"
  final String status;    // e.g. "DUE", "OVERDUE", "PAID"

  const Bill({
    required this.billerRef,
    required this.amountPaise,
    required this.duedate,
    required this.period,
    required this.status,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      billerRef: json['billerRef'] as String? ?? '',
      amountPaise: json['amountPaise'] as int? ?? 0,
      duedate: json['duedate'] as String? ?? '',
      period: json['period'] as String? ?? '',
      status: json['status'] as String? ?? 'DUE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billerRef': billerRef,
      'amountPaise': amountPaise,
      'duedate': duedate,
      'period': period,
      'status': status,
    };
  }
}