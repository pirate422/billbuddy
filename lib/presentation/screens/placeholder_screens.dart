import 'package:flutter/material.dart';

/// Temporary placeholder widget helper for developing screen skeletons
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? extraInfo;

  const PlaceholderScreen({super.key, required this.title, this.extraInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            if (extraInfo != null) ...[
              const SizedBox(height: 8),
              Text(extraInfo!, style: const TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

// // 1. Home Screen (/home)
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//   @override
//   Widget build(BuildContext context) => const PlaceholderScreen(title: 'Home Screen');
// }

// 2. Categories Screen (/billers)
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: 'Biller Categories');
}

// 3. Search Screen (/billers/search)
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: 'Biller Search');
}

// 4. Add Biller Screen (/billers/add)
class AddBillerScreen extends StatelessWidget {
  const AddBillerScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: 'Add New Biller');
}

// 5. Bill Details Screen (/vp-billers/:id)
class BillDetailsScreen extends StatelessWidget {
  final String id;
  const BillDetailsScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: 'Bill Details', extraInfo: 'Biller ID: $id');
}

// 6. Pay Bill Screen (/vp-billers/:id/pay)
class PayBillScreen extends StatelessWidget {
  final String id;
  const PayBillScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: 'Pay Bill', extraInfo: 'Biller ID: $id');
}

// 7. Payment Status Screen (/payments/:id)
class PaymentStatusScreen extends StatelessWidget {
  final String id;
  const PaymentStatusScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: 'Payment Status', extraInfo: 'Payment ID: $id');
}

// 8. Recharge Screen (/recharge)
class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: 'Mobile Recharge');
}

// 9. Autopay Settings Screen (/vp-billers/:id/autopay)
class AutopaySettingsScreen extends StatelessWidget {
  final String id;
  const AutopaySettingsScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: 'Autopay Settings', extraInfo: 'Biller ID: $id');
}

// 10. Payment History Screen (/history)
class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: 'Payment History');
}
