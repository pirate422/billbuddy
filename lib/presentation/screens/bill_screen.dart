import '../ui.dart';

class BillScreen extends ConsumerWidget {
  const BillScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedBillerProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(saved.valueOrNull?.nickname ?? 'Bill')),
      body: AsyncView(
        value: saved,
        onRetry: () => ref.invalidate(savedBillerProvider(id)),
        data: (SavedBiller s) => AsyncView(
          value: ref.watch(billProvider(id)),
          onRetry: () => ref.invalidate(billProvider(id)), // fetch failure => retry
          data: (Bill bill) => ListView(padding: const EdgeInsets.all(16), children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  if (bill.noDue) ...[
                    const Icon(Icons.check_circle, size: 48, color: Colors.green),
                    const SizedBox(height: 8),
                    Text(bill.settled ? 'Paid for ${bill.period}' : 'No bill due', style: Theme.of(context).textTheme.headlineSmall),
                    const Text("You're all caught up."),
                  ] else ...[
                    const Text('Amount due'),
                    Text(rupees(bill.amountPaise), style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 8),
                    Text('Due ${fmtDate(bill.dueDate!)} · ${bill.period}'),
                    const SizedBox(height: 8),
                    if (bill.overdue) const Tag('Overdue', Colors.red),
                    if (bill.dueSoon) const Tag('Due soon', Colors.orange),
                  ],
                ]),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(dense: true, title: const Text('Biller'), trailing: Text(s.billerName)),
            for (final e in s.fields.entries)
              ListTile(dense: true, title: Text(e.key[0].toUpperCase() + e.key.substring(1)), trailing: Text(e.value)),
            const SizedBox(height: 16),
            if (!bill.noDue)
              FilledButton.icon(icon: const Icon(Icons.payment), label: const Text('Pay bill'), onPressed: () => context.push('/my-billers/$id/pay')),
            const SizedBox(height: 8),
            OutlinedButton.icon(icon: const Icon(Icons.autorenew), label: Text(s.autopay ? 'Autopay settings (on)' : 'Set up autopay'), onPressed: () => context.push('/my-billers/$id/autopay')),
            TextButton.icon(icon: const Icon(Icons.history), label: const Text('Payment history'), onPressed: () => context.push('/history?saved=$id')),
          ]),
        ),
      ),
    );
  }
}
