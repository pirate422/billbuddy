import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../data/repositories/biller_repository.dart';
import '../data/repositories/bill_payment_repository.dart';
import '../data/repositories/my_biller_repository.dart';
import '../data/repositories/recharge_repository.dart';

/// Provides the singleton ApiClient instance
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Repository providers for dependency injection
final billerRepositoryProvider = Provider<BillerRepository>((ref) {
  return BillerRepository(apiClient: ref.watch(apiClientProvider));
});

final myBillerRepositoryProvider = Provider<MyBillerRepository>((ref) {
  return MyBillerRepository(apiClient: ref.watch(apiClientProvider));
});

final billPaymentRepositoryProvider = Provider<BillPaymentRepository>((ref) {
  return BillPaymentRepository(apiClient: ref.watch(apiClientProvider));
});

final rechargeRepositoryProvider = Provider<RechargeRepository>((ref) {
  return RechargeRepository(apiClient: ref.watch(apiClientProvider));
});