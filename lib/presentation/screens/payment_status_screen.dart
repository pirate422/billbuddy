import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/pay_notifier_provider.dart';

class PaymentStatusScreen extends ConsumerWidget {
  final String id;

  const PaymentStatusScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payState = ref.watch(payNotifierProvider);
    final payment = payState.payment;

    // Default status values for demonstration
    final isSuccess = payState.errorMessage == null;
    final statusTitle = isSuccess ? 'Payment Successful!' : 'Payment Failed';
    final amountText = payment != null
        ? (payment.amountPaise / 100).toStringAsFixed(2)
        : '1450.00';
    final bankRef = payment?.bankRef.isNotEmpty == true
        ? payment!.bankRef
        : 'BKREF${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final billerRef = payment?.billerRef.isNotEmpty == true
        ? payment!.billerRef
        : 'BLREF98412039';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Status'),
        automaticallyImplyLeading: false, // Prevent going back with back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error_outline,
                color: isSuccess ? Colors.green : Colors.red,
                size: 72,
              ),
            ),

            const SizedBox(height: 20),

            // Status Title
            Text(
              statusTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '₹$amountText',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.deepPurple : Colors.red,
              ),
            ),

            const SizedBox(height: 32),

            // Transaction Details Card
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _DetailRow(label: 'Transaction ID', value: id),
                    const Divider(),
                    _DetailRow(label: 'Bank Reference', value: bankRef),
                    const Divider(),
                    _DetailRow(label: 'Biller Reference', value: billerRef),
                    const Divider(),
                    _DetailRow(
                      label: 'Payment Method',
                      value: 'Axis Bank (**** 4821)',
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Generating PDF Receipt...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Receipt'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}