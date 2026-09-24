import '../ui.dart';

class AutopayScreen extends ConsumerStatefulWidget {
  const AutopayScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<AutopayScreen> createState() => _AutopayState();
}

class _AutopayState extends ConsumerState<AutopayScreen> {
  final _max = TextEditingController();
  bool _on = false, _paused = false, _init = false, _busy = false;
  String? _err;

  @override
  void dispose() { _max.dispose(); super.dispose(); }

  Future<void> _save() async {
    final paise = ((double.tryParse(_max.text) ?? 0) * 100).round();
    setState(() { _busy = true; _err = null; });
    try {
      await ref.read(myBillerRepoProvider).setAutopay(widget.id, enabled: _on, maxPaise: paise, paused: _paused);
      ref.invalidate(myBillersProvider);
      ref.invalidate(upcomingProvider);
      if (mounted) context.pop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Autopay')),
        body: AsyncView(
          value: ref.watch(savedBillerProvider(widget.id)),
          onRetry: () => ref.invalidate(savedBillerProvider(widget.id)),
          data: (SavedBiller s) {
            if (!_init) {
              _on = s.autopay;
              _paused = s.paused;
              _max.text = s.maxPaise > 0 ? (s.maxPaise / 100).toStringAsFixed(0) : '';
              _init = true;
            }
            return ListView(padding: const EdgeInsets.all(16), children: [
              Text(s.nickname, style: Theme.of(context).textTheme.titleLarge),
              SwitchListTile(title: const Text('Enable autopay'), value: _on, onChanged: (v) => setState(() => _on = v)),
              SwitchListTile(title: const Text('Pause autopay'), value: _paused, onChanged: _on ? (v) => setState(() => _paused = v) : null),
              const SizedBox(height: 8),
              TextField(
                controller: _max,
                enabled: _on,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Maximum amount per bill (₹)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              const Text('Autopay pays when a bill is due within 3 days (or overdue). Bills above your limit are never paid automatically - you approve them manually.',
                  style: TextStyle(fontSize: 12)),
              if (_err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_err!, style: const TextStyle(color: Colors.red))),
              const SizedBox(height: 20),
              FilledButton(onPressed: _busy ? null : _save, child: Text(_busy ? 'Saving…' : 'Save')),
            ]);
          },
        ),
      );
}
