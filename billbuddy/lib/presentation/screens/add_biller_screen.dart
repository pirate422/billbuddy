import '../ui.dart';

/// Dynamic form: fields, labels and regex validators all come from the biller definition.
class AddBillerScreen extends ConsumerStatefulWidget {
  const AddBillerScreen({super.key, required this.billerId});
  final String billerId;
  @override
  ConsumerState<AddBillerScreen> createState() => _AddBillerState();
}

class _AddBillerState extends ConsumerState<AddBillerScreen> {
  final _form = GlobalKey<FormState>();
  final _nick = TextEditingController();
  final _c = <String, TextEditingController>{};
  final _server = <String, String>{}; // 422 messages returned by the biller
  bool _busy = false;

  @override
  void dispose() {
    _nick.dispose();
    for (final c in _c.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save(Biller b) async {
    _server.clear();
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(myBillerRepoProvider).add(b.id, _nick.text, {for (final f in b.fields) f.key: _c[f.key]!.text.trim()});
      ref.invalidate(myBillersProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_nick.text.trim()} saved')));
      context.go('/home');
    } on ApiException catch (e) {
      if (e.field != null) {
        _server[e.field!] = e.message; // shown on the field
        _form.currentState!.validate();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add biller')),
        body: AsyncView(
          value: ref.watch(billerProvider(widget.billerId)),
          onRetry: () => ref.invalidate(billerProvider(widget.billerId)),
          data: (Biller b) => Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text(b.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nick,
                decoration: const InputDecoration(labelText: 'Nickname (e.g. Home electricity)', border: OutlineInputBorder()),
                validator: (v) => (v ?? '').trim().length < 2 ? 'A nickname is required' : null,
              ),
              for (final f in b.fields) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _c.putIfAbsent(f.key, TextEditingController.new),
                  keyboardType: f.numeric ? TextInputType.number : TextInputType.text,
                  decoration: InputDecoration(labelText: f.label, helperText: f.hint, border: const OutlineInputBorder()),
                  onChanged: (_) => _server.remove(f.key),
                  validator: (v) => _server[f.key] ?? validateField(f, v),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(onPressed: _busy ? null : () => _save(b), child: Text(_busy ? 'Saving…' : 'Save biller')),
            ]),
          ),
        ),
      );
}
