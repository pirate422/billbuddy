import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/my_billers_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myBillersAsync = ref.watch(myBillersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              'BillBuddy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Payment History',
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Quick Actions Dashboard ---
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Add Biller',
                  color: Colors.deepPurple,
                  onTap: () => context.push('/billers/add'),
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.phone_android,
                  label: 'Recharge',
                  color: Colors.blue,
                  onTap: () => context.push('/recharge'),
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.category,
                  label: 'Categories',
                  color: Colors.orange,
                  onTap: () => context.push('/billers'),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // --- 2. Upcoming Bills Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Bills',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.push('/billers/search'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Watch saved billers provider
            myBillersAsync.when(
              data: (billers) {
                if (billers.isEmpty) {
                  return const _EmptyBillsWidget();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: billers.length,
                  itemBuilder: (context, index) {
                    final savedBiller = billers[index];
                    return _UpcomingBillCard(savedBillerId: savedBiller.id, nickname: savedBiller.nickname);
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => _MockUpcomingBillsList(), // Fallback mock list for preview
            ),
          ],
        ),
      ),
    );
  }
}

// Quick action button tile widget
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget displaying bill item with due status badge
class _UpcomingBillCard extends ConsumerWidget {
  final String savedBillerId;
  final String nickname;

  const _UpcomingBillCard({
    required this.savedBillerId,
    required this.nickname,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(billFamilyProvider(savedBillerId));

    return billAsync.when(
      data: (bill) {
        if (bill == null) return const SizedBox.shrink();

        final amountInRupees = (bill.amountPaise / 100).toStringAsFixed(2);
        final isOverdue = bill.status == 'OVERDUE';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              nickname,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Due: ${bill.duedate} • ${bill.period}'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red.shade100 : Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isOverdue ? 'OVERDUE' : 'DUE SOON',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isOverdue ? Colors.red.shade900 : Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹$amountInRupees',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () => context.push('/vp-billers/$savedBillerId/pay'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(60, 30),
                  ),
                  child: const Text('Pay'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// Empty state widget when no bills are due
class _EmptyBillsWidget extends StatelessWidget {
  const _EmptyBillsWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
          SizedBox(height: 8),
          Text(
            'No Bills Due!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            'You are all caught up on your upcoming utility payments.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Fallback preview widget while backend API is not connected
class _MockUpcomingBillsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MockBillCard(
          nickname: 'Home Electricity (Bescom)',
          dueDate: '25 Sep 2026',
          amount: '₹1,450.00',
          isOverdue: true,
          onPay: () => context.push('/vp-billers/biller_1/pay'),
        ),
        _MockBillCard(
          nickname: 'Airtel Broadband Fiber',
          dueDate: '28 Sep 2026',
          amount: '₹999.00',
          isOverdue: false,
          onPay: () => context.push('/vp-billers/biller_2/pay'),
        ),
      ],
    );
  }
}

class _MockBillCard extends StatelessWidget {
  final String nickname;
  final String dueDate;
  final String amount;
  final bool isOverdue;
  final VoidCallback onPay;

  const _MockBillCard({
    required this.nickname,
    required this.dueDate,
    required this.amount,
    required this.isOverdue,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Due: $dueDate'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isOverdue ? Colors.red.shade100 : Colors.amber.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isOverdue ? 'OVERDUE' : 'DUE SOON',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isOverdue ? Colors.red.shade900 : Colors.amber.shade900,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: onPay,
              child: const Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }
}