import '../models/biller.dart';

/// Helper to dynamically validate inputs for server-driven biller fields
class DynamicFormBuilder {
  /// Validates user input map against regex rules specified in biller fields.
  /// Returns null if all fields are valid, or an error message string for the first invalid field.
  static String? validateInputs({
    required List<BillerField> fields,
    required Map<String, String> userInputs,
  }) {
    for (final field in fields) {
      final value = userInputs[field.key] ?? '';

      // Check if required field is empty
      if (value.trim().isEmpty) {
        return '${field.label} is required';
      }

      // Check if value matches the server-provided regex rule
      if (field.regex.isNotEmpty) {
        final regExp = RegExp(field.regex);
        if (!regExp.hasMatch(value)) {
          return 'Invalid ${field.label} format';
        }
      }
    }
    return null; // All inputs are valid
  }
}