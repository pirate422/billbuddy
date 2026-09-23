import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/plan.dart';
import '../../state/plans_family_provider.dart';
import '../../state/repository_providers.dart';

class RechargeScreen extends ConsumerStatefulWidget {
  const RechargeScreen({super.key});

  @override
  ConsumerState<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends ConsumerState<RechargeScreen> {
  final _phoneController = TextEditingController();
  String _operator = 'Jio';
  String _circle = 'Karnataka';
  bool _isDetecting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String val) async {
    if (val.length == 10) {
      setState(() => _isDetecting = true);
      try {
        final repo = ref.read(rechargeRepositoryProvider);
        final result = await repo.detectOperator(val);
        if (mounted) {
          setState(() {
            _operator = result['operator']?.isNotEmpty == true
                ? result['operator']!
                : 'Jio';
            _circle = result['circle']?.isNotEmpty == true
                ? result['circle']!
                : 'Karnataka';
            _isDetecting = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isDetecting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = PlanQueryParams(operator: _operator, circle: _circle);
    final plansAsync = ref.watch(plansFamilyProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Recharge')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone Number Input Field
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                hintText: 'Enter 10-digit mobile number',
                prefixIcon: const Icon(Icons.phone_android),
                border: const OutlineInputBorder(),
                suffixIcon: _isDetecting
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              onChanged: _onPhoneChanged,
            ),

            const SizedBox(height: 12),

            // Operator & Circle Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sim_card, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        '$_operator • $_circle',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  TextButton(onPressed: () {}, child: const Text('Change')),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Select Recharge Plan',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Scrollable Plan List
            Expanded(
              child: plansAsync.when(
                data: (plans) {
                  if (plans.isEmpty) {
                    return _MockPlansList(
                      operator: _operator,
                      phone: _phoneController.text,
                    );
                  }
                  return ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return _PlanCard(
                        plan: plan,
                        onSelect: () => context.push('/vp-billers/${plan.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _MockPlansList(
                  operator: _operator,
                  phone: _phoneController.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onSelect;

  const _PlanCard({required this.plan, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final priceRupees = (plan.pricePaise / 100).toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '₹$priceRupees',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${plan.validityDays} Days Validity',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan.benefits,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockPlansList extends StatelessWidget {
  final String operator;
  final String phone;

  const _MockPlansList({required this.operator, required this.phone});

  @override
  Widget build(BuildContext context) {
    final mockPlans = [
      Plan(
        id: 'plan_299',
        operator: operator,
        circle: 'Karnataka',
        pricePaise: 29900,
        validityDays: 28,
        benefits: '1.5 GB/day • Unlimited Calls • 100 SMS/day',
      ),
      Plan(
        id: 'plan_666',
        operator: operator,
        circle: 'Karnataka',
        pricePaise: 66600,
        validityDays: 84,
        benefits: '1.5 GB/day • Unlimited Calls • 100 SMS/day',
      ),
      Plan(
        id: 'plan_719',
        operator: operator,
        circle: 'Karnataka',
        pricePaise: 71900,
        validityDays: 84,
        benefits: '2 GB/day • Unlimited 5G • 100 SMS/day',
      ),
    ];

    return ListView.builder(
      itemCount: mockPlans.length,
      itemBuilder: (context, index) {
        final plan = mockPlans[index];
        return _PlanCard(
          plan: plan,
          onSelect: () => context.push('/vp-billers/${plan.id}'),
        );
      },
    );
  }
}
