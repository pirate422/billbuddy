import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/bill_payment.dart';
import 'repository_providers.dart';

/// State for payment execution
class PayState {
  final bool isLoading;
  final BillPayment? payment;
  final String? errorMessage;

  const PayState({
    this.isLoading = false,
    this.payment,
    this.errorMessage,
  });
}

/// StateNotifier handling idempotent payment execution
class PayNotifier extends StateNotifier<PayState> {
  final Ref ref;

  PayNotifier(this.ref) : super(const PayState());

  Future<void> executePayment({
    required String savedBillerId,
    required int amountPaise,
    required String idempotencyKey,
  }) async {
    state = const PayState(isLoading: true);
    try {
      final repository = ref.read(billPaymentRepositoryProvider);
      final payment = await repository.payBill(
        savedBillerId: savedBillerId,
        amountPaise: amountPaise,
        idempotencyKey: idempotencyKey,
      );
      state = PayState(isLoading: false, payment: payment);
    } catch (e) {
      state = PayState(isLoading: false, errorMessage: e.toString());
    }
  }
}

/// Provider exposing PayNotifier
final payNotifierProvider =
    StateNotifierProvider<PayNotifier, PayState>((ref) {
  return PayNotifier(ref);
});