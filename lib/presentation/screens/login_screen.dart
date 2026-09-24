import '../ui.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false, _hide = true;
  String? _error;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final email = await ref.read(apiProvider).login(_email.text, _pass.text);
      ref.read(sessionProvider.notifier).state = email; // router redirects to /home
    } catch (e) {
      if (mounted) setState(() => _error = errText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _form,
                  child: Column(children: [
                    Icon(Icons.account_balance_wallet, size: 64, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    Text('BillBuddy', style: Theme.of(context).textTheme.headlineMedium),
                    const Text('All your bills in one place'),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Gmail address', border: OutlineInputBorder()),
                      validator: (v) => RegExp(r'^[\w.+-]+@gmail\.com$', caseSensitive: false).hasMatch((v ?? '').trim())
                          ? null : 'Enter a valid @gmail.com address',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pass,
                      obscureText: _hide,
                      decoration: InputDecoration(
                        labelText: 'Password', border: const OutlineInputBorder(),
                        suffixIcon: IconButton(icon: Icon(_hide ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _hide = !_hide)),
                      ),
                      validator: (v) => (v ?? '').length >= 6 ? null : 'At least 6 characters',
                    ),
                    if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, child: FilledButton(onPressed: _busy ? null : _submit, child: Text(_busy ? 'Signing in…' : 'Sign in'))),
                    const SizedBox(height: 8),
                    const Text('Demo: any @gmail.com + 6+ char password (new emails are registered automatically).',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}
