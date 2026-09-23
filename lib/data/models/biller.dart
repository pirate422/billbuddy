import 'package:flutter/foundation.dart';

/// Represents a dynamic input field required by a biller (e.g., Consumer Number)
class BillerField {
  final String key;
  final String label;
  final String regex;

  const BillerField({
    required this.key,
    required this.label,
    required this.regex,
  });

  /// Factory constructor to convert JSON map from backend API into Dart object
  factory BillerField.fromJson(Map<String, dynamic> json) {
    return BillerField(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      regex: json['regex'] as String? ?? '',
    );
  }

  /// Converts Dart object back into JSON map
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'regex': regex,
    };
  }
}

/// Represents a utility provider or biller in the BillBuddy directory
@immutable
class Biller {
  final String id;
  final String name;
  final String category;
  final String state;
  final List<BillerField> fields;
  final bool allowsPartial;

  const Biller({
    required this.id,
    required this.name,
    required this.category,
    required this.state,
    required this.fields,
    required this.allowsPartial,
  });

  /// Factory constructor to create a Biller instance from backend JSON data
  factory Biller.fromJson(Map<String, dynamic> json) {
    return Biller(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      state: json['state'] as String? ?? '',
      fields: (json['fields'] as List<dynamic>?)
              ?.map((f) => BillerField.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      allowsPartial: json['allowsPartial'] as bool? ?? false,
    );
  }

  /// Converts a Biller instance into JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'state': state,
      'fields': fields.map((f) => f.toJson()).toList(),
      'allowsPartial': allowsPartial,
    };
  }
}