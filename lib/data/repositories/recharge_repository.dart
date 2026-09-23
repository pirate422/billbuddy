import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/error/biller_error.dart';
import '../models/plan.dart';

/// Repository handling mobile recharges and operator plan listings
class RechargeRepository {
  final ApiClient apiClient;

  RechargeRepository({required this.apiClient});

  /// Detects mobile operator and telecom circle from a phone number
  Future<Map<String, String>> detectOperator(String phone) async {
    try {
      final response = await apiClient.dio.get(
        '/recharge/detect',
        queryParameters: {'phone': phone},
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'operator': data['operator'] as String? ?? '',
        'circle': data['circle'] as String? ?? '',
      };
    } on DioException catch (e) {
      throw BillerError(
        message: e.message ?? 'Failed to detect operator',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw BillerError(message: e.toString());
    }
  }

  /// Fetches available recharge plans for a given operator and circle
  Future<List<Plan>> fetchPlans({
    required String operator,
    required String circle,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/recharge/plans',
        queryParameters: {
          'operator': operator,
          'circle': circle,
        },
      );
      final data = response.data as List<dynamic>;
      return data
          .map((json) => Plan.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw BillerError(
        message: e.message ?? 'Failed to fetch recharge plans',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw BillerError(message: e.toString());
    }
  }
}