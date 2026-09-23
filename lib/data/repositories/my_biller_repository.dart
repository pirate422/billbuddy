import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/error/biller_error.dart';
import '../models/bill.dart';
import '../models/saved_biller.dart';

/// Repository for managing user's saved billers, fetching bills, and updating autopay
class MyBillerRepository {
  final ApiClient apiClient;

  MyBillerRepository({required this.apiClient});

  /// Fetches all billers saved by the current user
  Future<List<SavedBiller>> fetchSavedBillers() async {
    try {
      final response = await apiClient.dio.get('/me/billers');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => SavedBiller.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw BillerError(
        message: e.message ?? 'Failed to fetch saved billers',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw BillerError(message: e.toString());
    }
  }

  /// Saves a new biller to the user's account with custom parameter inputs
  Future<SavedBiller> saveBiller({
    required String billerId,
    required String nickname,
    required Map<String, dynamic> params,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/me/billers',
        data: {
          'billerId': billerId,
          'nickname': nickname,
          'params': params,
        },
      );
      return SavedBiller.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw BillerError(
        message: e.message ?? 'Failed to save biller',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw BillerError(message: e.toString());
    }
  }

  /// Fetches current bill details for a saved biller
  Future<Bill?> fetchBill(String savedBillerId) async {
    try {
      final response = await apiClient.dio.get('/me/billers/$savedBillerId/bill');
      if (response.data == null) return null; // Handle "No bill due" state
      return Bill.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw BillerError(
        message: e.message ?? 'Failed to fetch bill details',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw BillerError(message: e.toString());
    }
  }

  /// Updates Autopay status and max limit for a saved biller
  Future<AutopayConfig> updateAutopay({
    required String savedBillerId,
    required bool enabled,
    required int maxPaise,
  }) async {
    try {
      final response = await apiClient.dio.put(
        '/me/billers/$savedBillerId/autopay',
        data: {
          'enabled': enabled,
          'maxPaise': maxPaise,
        },
      );
      return AutopayConfig.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw BillerError(
        message: e.message ?? 'Failed to update Autopay settings',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw BillerError(message: e.toString());
    }
  }
}