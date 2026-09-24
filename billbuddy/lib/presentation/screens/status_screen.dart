import '../ui.dart';

/// Payment status + receipt (biller ref + bank ref).
class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void refresh() {
      ref.invalidate(paymentProvider(id)); // pending payments update when refreshed
      ref.invalidate(historyProvider);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment status'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: refresh)]),
      body: AsyncView(
        value: ref.watch(paymentProvider(id)),
        onRetry: refresh,
        data: (Payment p) {
          final (icon, color, label) = switch (p.status) {
            PayStatus.success => (Icons.check_circle, Colors.green, 'Payment successful'),
            PayStatus.pending => (Icons.hourglass_top, Colors.orange, 'Payment pending'),
            PayStatus.failed => (Icons.cancel, Colors.red, 'Payment failed'),
          };
          return ListView(padding: const EdgeInsets.all(16), children: [
            Icon(icon, size: 72, color: color),
            Center(child: Text(label, style: Theme.of(context).textTheme.headlineSmall)),
            Center(child: Text(rupees(p.amountPaise), style: Theme.of(context).textTheme.headlineMedium)),
            const SizedBox(height: 16),
            Card(
              child: Column(children: [
                for (final (k, v) in [
                  ('Biller', '${p.title} (${p.billerName})'), ('Date', fmtDate(p.at)), ('Paid from', p.account),
                  ('Biller reference', p.billerRef), ('Bank reference', p.bankRef),
                ])
                  ListTile(dense: true, title: Text(k), trailing: Text(v)),
              ]),
            ),
            const SizedBox(height: 16),
            if (p.status == PayStatus.pending) FilledButton.icon(icon: const Icon(Icons.refresh), label: const Text('Refresh status'), onPressed: refresh),
            if (p.status == PayStatus.failed)
              FilledButton(onPressed: () => context.pushReplacement(p.savedId == 'recharge' ? '/recharge' : '/my-billers/${p.savedId}/pay'), child: const Text('Try again')),
            if (p.status == PayStatus.success)
              OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy receipt'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: p.receiptText));
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt copied')));
                },
              ),
            TextButton(onPressed: () => context.go('/home'), child: const Text('Done')),
          ]);
        },
      ),
    );
  }
}
