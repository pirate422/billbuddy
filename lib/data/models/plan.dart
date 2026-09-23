import 'package:flutter/foundation.dart';

/// Represents a mobile recharge plan listing
@immutable
class Plan {
  final String id;
  final String operator;
  final String circle;
  final int pricePaise;    // Money in integer paise
  final int validityDays;
  final String benefits;

  const Plan({
    required this.id,
    required this.operator,
    required this.circle,
    required this.pricePaise,
    required this.validityDays,
    required this.benefits,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String? ?? '',
      operator: json['operator'] as String? ?? '',
      circle: json['circle'] as String? ?? '',
      pricePaise: json['pricePaise'] as int? ?? 0,
      validityDays: json['validityDays'] as int? ?? 0,
      benefits: json['benefits'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operator': operator,
      'circle': circle,
      'pricePaise': pricePaise,
      'validityDays': validityDays,
      'benefits': benefits,
    };
  }
}