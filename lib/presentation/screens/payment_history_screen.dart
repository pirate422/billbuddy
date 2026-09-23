import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/bill_payment.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Choice Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['ALL', 'SUCCESS', 'PENDING', 'FAILED'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: Colors.deepPurple.shade100,
                      checkmarkColor: Colors.deepPurple,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.deepPurple : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // History List
            Expanded(
              child: _MockPaymentHistoryList(filterStatus: _selectedFilter),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockPaymentHistoryList extends StatelessWidget {
  final String filterStatus;

  const _MockPaymentHistoryList({required this.filterStatus});

  @override
  Widget build(BuildContext context) {
    final mockPayments = [
      BillPayment(
        id: 'pay_tx_101',
        savedBillerId: 'BESCOM Electricity',
        amountPaise: 145000,
        status: 'SUCCESS',
        bankRef: 'BKREF889210',
        billerRef: 'BLREF98412039',
        at: '22 Sep 2026, 10:15 AM',
      ),
      BillPayment(
        id: 'pay_tx_102',
        savedBillerId: 'Airtel Broadband',
        amountPaise: 99900,
        status: 'SUCCESS',
        bankRef: 'BKREF889211',
        billerRef: 'BLREF98412040',
        at: '18 Sep 2026, 04:30 PM',
      ),
      BillPayment(
        id: 'pay_tx_103',
        savedBillerId: 'BWSSB Water',
        amountPaise: 54000,
        status: 'PENDING',
        bankRef: 'BKREF889212',
        billerRef: 'BLREF98412041',
        at: '15 Sep 2026, 02:20 PM',
      ),
      BillPayment(
        id: 'pay_tx_104',
        savedBillerId: 'Tata Power Electricity',
        amountPaise: 210000,
        status: 'FAILED',
        bankRef: 'BKREF889213',
        billerRef: 'BLREF98412042',
        at: '01 Sep 2026, 11:00 AM',
      ),
    ];

    final filtered = mockPayments.where((p) {
      if (filterStatus == 'ALL') return true;
      return p.status == filterStatus;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No $filterStatus transactions found',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final payment = filtered[index];
        final amountRupees = (payment.amountPaise / 100).toStringAsFixed(2);

        Color statusColor;
        switch (payment.status) {
          case 'SUCCESS':
            statusColor = Colors.green;
            break;
          case 'PENDING':
            statusColor = Colors.orange;
            break;
          case 'FAILED':
          default:
            statusColor = Colors.red;
            break;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                payment.status == 'SUCCESS'
                    ? Icons.check_circle_outline
                    : (payment.status == 'PENDING'
                        ? Icons.hourglass_empty
                        : Icons.error_outline),
                color: statusColor,
              ),
            ),
            title: Text(
              payment.savedBillerId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(payment.at, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  'Ref: ${payment.bankRef}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹$amountRupees',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    payment.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () => context.push('/payments/${payment.id}'),
          ),
        );
      },
    );
  }
}