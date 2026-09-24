// Shared barrel + small reusable widgets used by every screen.
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:go_router/go_router.dart';
export '../core/models.dart';
export '../state/providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/models.dart';

String errText(Object e) => e is ApiException ? e.message : 'Something went wrong. Please try again.';

IconData categoryIcon(String id) => switch (id) {
      'electricity' => Icons.bolt,
      'water' => Icons.water_drop,
      'gas' => Icons.local_fire_department,
      'broadband' => Icons.wifi,
      'mobile' => Icons.smartphone,
      'dth' => Icons.tv,
      'credit_card' => Icons.credit_card,
      _ => Icons.receipt_long,
    };

/// Loading / error(+retry) / data wrapper.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.data, required this.onRetry});
  final AsyncValue<T> value;
  final Widget Function(T) data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => value.when(
        data: data,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(errText(e), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
            ]),
          ),
        ),
      );
}

class Tag extends StatelessWidget {
  const Tag(this.text, this.color, {super.key});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}

class BillerTiles extends StatelessWidget {
  const BillerTiles(this.billers, {super.key});
  final List<Biller> billers;
  @override
  Widget build(BuildContext context) => billers.isEmpty
      ? const Center(child: Text('No billers found'))
      : ListView.builder(
          itemCount: billers.length,
          itemBuilder: (ctx, i) {
            final b = billers[i];
            return ListTile(
              leading: CircleAvatar(child: Icon(categoryIcon(b.category))),
              title: Text(b.name),
              subtitle: Text(b.fields.map((f) => f.label).join(' · ')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ctx.push('/billers/${b.id}/add'),
            );
          },
        );
}
