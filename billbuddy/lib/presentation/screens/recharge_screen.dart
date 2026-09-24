import '../ui.dart';

class RechargeScreen extends ConsumerStatefulWidget {
  const RechargeScreen({super.key});
  @override
  ConsumerState<RechargeScreen> createState() => _RechargeState();
}

class _RechargeState extends ConsumerState<RechargeScreen> {
  final _num = TextEditingController();
  String? _op, _circle;
  String _type = 'All';
  bool _detecting = false;

  bool get _valid => RegExp(r'^[6-9]\d{9}$').hasMatch(_num.text);

  @override
  void dispose() { _num.dispose(); super.dispose(); }

  /// Operator + circle are auto-detected from the number, and can be changed by the user.
  Future<void> _onNumber(String v) async {
    if (!_valid) {
      setState(() { _op = null; _circle = null; });
      return;
    }
    setState(() => _detecting = true);
    final (op, circle) = await ref.read(rechargeRepoProvider).detect(v);
    if (!mounted) return;
    setState(() {
      _detecting = false;
      if (_num.text == v) { _op = op; _circle = circle; }
    });
  }

  void _confirm(Plan p) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ConfirmSheet(plan: p, number: _num.text, operator: _op!, circle: _circle!),
      );

  @override
  Widget build(BuildContext context) {
    const operators = ['Jio', 'Airtel', 'Vi', 'BSNL'];
    const circles = ['Maharashtra', 'Delhi', 'Karnataka', 'Tamil Nadu', 'Gujarat'];
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile recharge')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _num,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            onChanged: _onNumber,
            decoration: InputDecoration(
              labelText: 'Mobile number', border: const OutlineInputBorder(),
              errorText: _num.text.length == 10 && !_valid ? 'Enter a valid Indian mobile number' : null,
            ),
          ),
        ),
        if (_detecting) const LinearProgressIndicator(),
        if (_op != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: DropdownButton<String>(isExpanded: true, value: _op, items: [for (final o in operators) DropdownMenuItem(value: o, child: Text(o))], onChanged: (v) => setState(() => _op = v))),
              const SizedBox(width: 16),
              Expanded(child: DropdownButton<String>(isExpanded: true, value: _circle, items: [for (final c in circles) DropdownMenuItem(value: c, child: Text(c))], onChanged: (v) => setState(() => _circle = v))),
            ]),
          ),
          const Text('Auto-detected - tap to change', style: TextStyle(fontSize: 12)),
          SizedBox(
            height: 52,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), children: [
              for (final t in ['All', 'Data', 'Unlimited', 'Talktime'])
                Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(t), selected: _type == t, onSelected: (_) => setState(() => _type = t))),
            ]),
          ),
          Expanded(
            child: AsyncView(
              value: ref.watch(plansProvider((_op!, _circle!))),
              onRetry: () => ref.invalidate(plansProvider((_op!, _circle!))),
              data: (List<Plan> plans) {
                final list = _type == 'All' ? plans : plans.where((p) => p.type == _type).toList();
                return ListView.builder(
                  itemCount: list.length,
                  itemExtent: 72, // fixed extent keeps 500 plans scrolling smoothly
                  itemBuilder: (_, i) {
                    final p = list[i];
                    return ListTile(
                      title: Text(rupees(p.pricePaise), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.validityDays} days · ${p.benefit}'),
                      trailing: Tag(p.type, Colors.teal),
                      onTap: () => _confirm(p),
                    );
                  },
                );
              },
            ),
          ),
        ] else
          const Expanded(child: Center(child: Text('Enter a 10-digit number to see plans'))),
      ]),
    );
  }
}

class _ConfirmSheet extends ConsumerStatefulWidget {
  const _ConfirmSheet({required this.plan, required this.number, required this.operator, required this.circle});
  final Plan plan;
  final String number, operator, circle;
  @override
  ConsumerState<_ConfirmSheet> createState() => _ConfirmState();
}

class _ConfirmState extends ConsumerState<_ConfirmSheet> {
  final String _key = newKey();
  String _account = kAccounts.first;
  bool _busy = false;
  String? _err;

  Future<void> _pay() async {
    setState(() { _busy = true; _err = null; });
    try {
      final p = await ref.read(rechargeRepoProvider).recharge(
          number: widget.number, operator: widget.operator, amountPaise: widget.plan.pricePaise, account: _account, key: _key);
      ref.invalidate(historyProvider);
      if (!mounted) return;
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      router.push('/payments/${p.id}');
    } catch (e) {
      if (mounted) setState(() { _err = errText(e); _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Recharge ${widget.number}', style: Theme.of(context).textTheme.titleLarge),
            Text('${widget.operator} · ${widget.circle}'),
            Text('${rupees(widget.plan.pricePaise)} · ${widget.plan.validityDays} days · ${widget.plan.benefit}'),
            const SizedBox(height: 16),
            const Text('Pay from'),
            DropdownButton<String>(
              isExpanded: true, value: _account,
              items: [for (final a in kAccounts) DropdownMenuItem(value: a, child: Text(a))],
              onChanged: (v) => setState(() => _account = v!),
            ),
            if (_err != null) Text(_err!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _busy ? null : _pay, child: Text(_busy ? 'Processing…' : 'Pay ${rupees(widget.plan.pricePaise)}'))),
          ]),
        ),
      );
}
