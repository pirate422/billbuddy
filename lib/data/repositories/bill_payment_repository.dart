import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/error/biller_error.dart';
import '../models/bill_payment.dart';

/// Repository handling bill payment executions with idempotency key protection
class BillPaymentRepository {
  final ApiClient apiClient;

  BillPaymentRepository({required this.apiClient});

  /// Executes a payment for a biller using integer paise and an idempotency key
  Future<BillPayment> payBill({
    required String savedBillerId,
    required int amountPaise,
    required String idempotencyKey,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/payments',
        data: {
          'savedBillerId': savedBillerId,
          'amountPaise': amountPaise,
        },
        options: Options(
          headers: {'Idempotency-Key': idempotencyKey},
        ),
      );
      return BillPayment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw BillerError(
        message: e.message ?? 'Payment failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw BillerError(message: e.toString());
    }
  }

  /// Checks the current status of a payment by transaction ID
  Future<BillPayment> getPaymentStatus(String paymentId) async {
    try {
      final response = await apiClient.dio.get('/payments/$paymentId');
      return BillPayment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw BillerError(
        message: e.message ?? 'Failed to fetch payment status',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw BillerError(message: e.toString());
    }
  }
}