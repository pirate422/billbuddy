import '../ui.dart';

class PayScreen extends ConsumerStatefulWidget {
  const PayScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<PayScreen> createState() => _PayState();
}

class _PayState extends ConsumerState<PayScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final String _key = newKey(); // one idempotency key per screen; a retry reuses it => never pays twice
  String _account = kAccounts.first;
  bool _busy = false, _init = false;
  String? _err;

  @override
  void dispose() { _amount.dispose(); super.dispose(); }

  Future<void> _pay(PayInfo info) async {
    if (!_form.currentState!.validate()) return;
    final paise = (double.parse(_amount.text) * 100).round();
    setState(() { _busy = true; _err = null; });
    try {
      final p = await ref.read(paymentRepoProvider).pay(savedId: info.saved.id, amountPaise: paise, account: _account, key: _key);
      ref.invalidate(billProvider(widget.id));
      ref.invalidate(upcomingProvider);
      ref.invalidate(historyProvider);
      if (mounted) context.pushReplacement('/payments/${p.id}');
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    } catch (_) {
      if (mounted) setState(() => _err = 'Network problem. Tap Pay again - you will not be charged twice.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pay bill')),
        body: AsyncView(
          value: ref.watch(payInfoProvider(widget.id)),
          onRetry: () => ref.invalidate(payInfoProvider(widget.id)),
          data: (PayInfo info) {
            if (!_init) {
              _amount.text = (info.bill.amountPaise / 100).toStringAsFixed(2);
              _init = true;
            }
            return Form(
              key: _form,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                Text(info.saved.nickname, style: Theme.of(context).textTheme.titleLarge),
                Text('${info.saved.billerName} · due ${rupees(info.bill.amountPaise)}'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amount,
                  readOnly: !info.partial,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)', border: const OutlineInputBorder(),
                    helperText: info.partial ? 'You can pay part of this bill' : 'This biller needs the full amount',
                  ),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null) return 'Enter a valid amount';
                    return validateAmount((d * 100).round(), info.bill.amountPaise, info.partial);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Pay from'),
                DropdownButton<String>(
                  isExpanded: true, value: _account,
                  items: [for (final a in kAccounts) DropdownMenuItem(value: a, child: Text(a))],
                  onChanged: (v) => setState(() => _account = v!),
                ),
                if (_err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_err!, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 20),
                FilledButton(onPressed: _busy ? null : () => _pay(info), child: Text(_busy ? 'Processing…' : 'Pay now')),
              ]),
            );
          },
        ),
      );
}
