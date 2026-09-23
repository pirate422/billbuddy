/// Custom domain exception thrown by BillBuddy repositories
class BillerError implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const BillerError({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() =>
      'BillerError(code: $code, statusCode: $statusCode, message: $message)';
}