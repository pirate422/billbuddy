import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/my_billers_provider.dart';

class BillDetailsScreen extends ConsumerWidget {
  final String id;

  const BillDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(billFamilyProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
      ),
      body: billAsync.when(
        data: (bill) {
          final amountRupees = bill != null
              ? (bill.amountPaise / 100).toStringAsFixed(2)
              : '1,450.00';
          final period = bill?.period ?? 'OCT 2026';
          final dueDate = bill?.duedate ?? '25 Sep 2026';
          final isOverdue = bill?.status == 'OVERDUE';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bill Summary Header Card
                Card(
                  elevation: 0,
                  color: Colors.deepPurple.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long,
                                color: Colors.deepPurple, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bill Summary',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Biller Ref: $id',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Amount Due:'),
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
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Billing Period: $period'),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? Colors.red.shade100
                                    : Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isOverdue ? 'OVERDUE' : 'DUE SOON',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isOverdue
                                      ? Colors.red.shade900
                                      : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Due Date: $dueDate',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Link to Autopay Settings
                ListTile(
                  leading: const Icon(Icons.autorenew, color: Colors.deepPurple),
                  title: const Text('Autopay Settings'),
                  subtitle: const Text('Manage automatic monthly payments'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/vp-billers/$id/autopay'),
                ),
                const Divider(),

                const Spacer(),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.push('/vp-billers/$id/pay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Pay',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _MockBillDetails(id: id),
      ),
    );
  }
}

class _MockBillDetails extends StatelessWidget {
  final String id;

  const _MockBillDetails({required this.id});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: Colors.deepPurple.shade50,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long,
                          color: Colors.deepPurple, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bill Details',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text('Ref ID: $id',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount Due', style: TextStyle(fontSize: 14)),
                      Text(
                        '₹1,450.00',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Due Date: 25 Sep 2026 • Billing Period: OCT 2026',
                      style: TextStyle(
                          color: Colors.grey.shade800, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.autorenew, color: Colors.deepPurple),
            title: const Text('Autopay Settings'),
            subtitle: const Text('Configure monthly automatic payment limit'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/vp-billers/$id/autopay'),
          ),
          const Divider(),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.push('/vp-billers/$id/pay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Proceed to Pay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}