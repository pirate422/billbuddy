import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/my_billers_provider.dart';
import '../../state/pay_notifier_provider.dart';

class PayBillScreen extends ConsumerStatefulWidget {
  final String id;

  const PayBillScreen({super.key, required this.id});

  @override
  ConsumerState<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends ConsumerState<PayBillScreen> {
  final _amountController = TextEditingController();
  String _selectedAccount = 'Axis Bank Savings (**** 4821)';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processPayment(int defaultPaise) {
    final idempotencyKey =
        'pay_${widget.id}_${DateTime.now().millisecondsSinceEpoch}';

    final enteredAmount = double.tryParse(_amountController.text);
    final amountPaise =
        enteredAmount != null ? (enteredAmount * 100).toInt() : defaultPaise;

    ref.read(payNotifierProvider.notifier).executePayment(
          savedBillerId: widget.id,
          amountPaise: amountPaise,
          idempotencyKey: idempotencyKey,
        );

    final mockPaymentId = 'pay_tx_${DateTime.now().millisecondsSinceEpoch}';
    context.go('/payments/$mockPaymentId');
  }

  Widget _buildForm({
    required BuildContext context,
    required String amountRupees,
    required int defaultPaise,
    required String duedate,
    required String period,
  }) {
    if (_amountController.text.isEmpty) {
      _amountController.text = amountRupees;
    }

    final payState = ref.watch(payNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.deepPurple.shade50,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount Due:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₹$amountRupees',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Due Date: $duedate • $period',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Amount Input
          const Text(
            'Payment Amount (₹)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          // Account Selector
          const Text(
            'Pay From Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedAccount,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.account_balance),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Axis Bank Savings (**** 4821)',
                child: Text('Axis Bank Savings (**** 4821)'),
              ),
              DropdownMenuItem(
                value: 'HDFC Bank (**** 9012)',
                child: Text('HDFC Bank (**** 9012)'),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedAccount = val);
              }
            },
          ),

          const SizedBox(height: 32),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: payState.isLoading
                  ? null
                  : () => _processPayment(defaultPaise),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: payState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Confirm & Pay Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final billAsync = ref.watch(billFamilyProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Bill'),
      ),
      body: billAsync.when(
        data: (bill) {
          final defaultAmountRupees = bill != null
              ? (bill.amountPaise / 100).toStringAsFixed(2)
              : '1450.00';
          final defaultPaise = bill?.amountPaise ?? 145000;
          final duedate = bill?.duedate ?? '25 Sep 2026';
          final period = bill?.period ?? 'OCT 2026';

          return _buildForm(
            context: context,
            amountRupees: defaultAmountRupees,
            defaultPaise: defaultPaise,
            duedate: duedate,
            period: period,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildForm(
          context: context,
          amountRupees: '1450.00',
          defaultPaise: 145000,
          duedate: '25 Sep 2026',
          period: 'OCT 2026',
        ),
      ),
    );
  }
}