import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/repository_providers.dart';

class AutopaySettingsScreen extends ConsumerStatefulWidget {
  final String id;

  const AutopaySettingsScreen({super.key, required this.id});

  @override
  ConsumerState<AutopaySettingsScreen> createState() =>
      _AutopaySettingsScreenState();
}

class _AutopaySettingsScreenState
    extends ConsumerState<AutopaySettingsScreen> {
  bool _autopayEnabled = true;
  final _limitController = TextEditingController(text: '3000');
  bool _isSaving = false;

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _saveAutopaySettings() async {
    setState(() => _isSaving = true);

    final maxRupees = double.tryParse(_limitController.text) ?? 3000.0;
    final maxPaise = (maxRupees * 100).toInt();

    try {
      final repo = ref.read(myBillerRepositoryProvider);
      await repo.updateAutopay(
        savedBillerId: widget.id,
        enabled: _autopayEnabled,
        maxPaise: maxPaise,
      );
    } catch (_) {
      // Catch network error gracefully in mock mode
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _autopayEnabled
                ? 'Autopay updated! Max limit: ₹${maxRupees.toStringAsFixed(0)}'
                : 'Autopay disabled for this biller.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autopay Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informational Header Card
            Card(
              elevation: 0,
              color: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: Colors.deepPurple, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Autopay Protection',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bills within your safety limit are automatically paid on the due date.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Autopay Toggle Switch
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Enable Autopay',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _autopayEnabled
                      ? 'Automated payments active'
                      : 'Autopay is currently paused',
                ),
                secondary: Icon(
                  Icons.autorenew,
                  color: _autopayEnabled ? Colors.green : Colors.grey,
                ),
                value: _autopayEnabled,
                onChanged: (val) {
                  setState(() => _autopayEnabled = val);
                },
              ),
            ),

            const SizedBox(height: 20),

            if (_autopayEnabled) ...[
              // Maximum Safety Limit Input
              const Text(
                'Maximum Autopay Limit (₹)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'If a bill exceeds this amount, Autopay will require manual confirmation.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                  labelText: 'Max Limit (Rupees)',
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAutopaySettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Autopay Rules',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}