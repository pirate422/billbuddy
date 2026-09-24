import '../ui.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key, this.savedId});
  final String? savedId;
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<HistoryScreen> {
  PayStatus? _filter;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Payment history'), actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(historyProvider)),
        ]),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(spacing: 8, children: [
              ChoiceChip(label: const Text('All'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null)),
              for (final s in PayStatus.values)
                ChoiceChip(label: Text(s.name[0].toUpperCase() + s.name.substring(1)), selected: _filter == s, onSelected: (_) => setState(() => _filter = s)),
            ]),
          ),
          Expanded(
            child: AsyncView(
              value: ref.watch(historyProvider),
              onRetry: () => ref.invalidate(historyProvider),
              data: (List<Payment> all) {
                final list = all.where((p) => (widget.savedId == null || p.savedId == widget.savedId) && (_filter == null || p.status == _filter)).toList();
                return RefreshIndicator(
                  onRefresh: () async { ref.invalidate(historyProvider); await ref.read(historyProvider.future); },
                  child: list.isEmpty
                      ? ListView(children: const [Padding(padding: EdgeInsets.all(48), child: Center(child: Text('No payments yet')))])
                      : ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (_, i) {
                            final p = list[i];
                            final color = switch (p.status) { PayStatus.success => Colors.green, PayStatus.pending => Colors.orange, PayStatus.failed => Colors.red };
                            return ListTile(
                              leading: CircleAvatar(child: Icon(categoryIcon(p.category))),
                              title: Text(p.title),
                              subtitle: Text('${fmtDate(p.at)} · ${p.account}'),
                              trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(rupees(p.amountPaise), style: const TextStyle(fontWeight: FontWeight.bold)),
                                Tag(p.status.name, color),
                              ]),
                              onTap: () => context.push('/payments/${p.id}'),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ]),
      );
}
