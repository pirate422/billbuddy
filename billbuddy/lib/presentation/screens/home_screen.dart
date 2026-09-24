import '../ui.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('BillBuddy'), actions: [
        IconButton(icon: const Icon(Icons.history), onPressed: () => context.push('/history')),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await ref.read(apiProvider).logout();
            ref.read(sessionProvider.notifier).state = null;
          },
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/billers'), icon: const Icon(Icons.add), label: const Text('Add biller')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myBillersProvider);
          await ref.read(upcomingProvider.future);
        },
        child: AsyncView(
          value: ref.watch(upcomingProvider),
          onRetry: () => ref.invalidate(upcomingProvider),
          data: (List<UpcomingItem> items) {
            final total = items.fold<int>(0, (a, i) => a + (i.bill?.amountPaise ?? 0));
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total due'),
                      Text(rupees(total), style: Theme.of(context).textTheme.headlineMedium),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [
                  ActionChip(avatar: const Icon(Icons.smartphone, size: 18), label: const Text('Recharge'), onPressed: () => context.push('/recharge')),
                  ActionChip(avatar: const Icon(Icons.search, size: 18), label: const Text('Find biller'), onPressed: () => context.push('/billers/search')),
                ]),
                const SizedBox(height: 12),
                Text('Upcoming bills', style: Theme.of(context).textTheme.titleMedium),
                if (items.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: Text('No billers yet. Tap “Add biller” to start.'))),
                for (final i in items) _Tile(i, () => ref.invalidate(upcomingProvider)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item, this.onRetry);
  final UpcomingItem item;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = item.saved;
    final b = item.bill;
    final sub = b == null
        ? 'Could not fetch bill'
        : b.noDue ? (b.settled ? 'Paid for ${b.period}' : 'No bill due') : 'Due ${fmtDate(b.dueDate!)}';
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(categoryIcon(s.category))),
        title: Text(s.nickname),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${s.billerName} · $sub'),
          Wrap(spacing: 6, children: [
            if (b != null && b.overdue) const Tag('Overdue', Colors.red),
            if (b != null && b.dueSoon) const Tag('Due soon', Colors.orange),
            if (s.autopay && !s.paused) const Tag('Autopay', Colors.teal),
            if (s.autopay && s.paused) const Tag('Autopay paused', Colors.grey),
            if (item.needsApproval) const Tag('Approval needed', Colors.purple),
          ]),
        ]),
        trailing: b != null && !b.noDue
            ? Text(rupees(b.amountPaise), style: const TextStyle(fontWeight: FontWeight.bold))
            : (item.error != null ? TextButton(onPressed: onRetry, child: const Text('Retry')) : null),
        onTap: () => context.push('/my-billers/${s.id}'),
      ),
    );
  }
}
