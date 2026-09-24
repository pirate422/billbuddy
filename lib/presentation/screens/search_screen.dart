import 'dart:async';
import '../ui.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchState();
}

class _SearchState extends ConsumerState<SearchScreen> {
  Timer? _t;

  void _changed(String v) {
    _t?.cancel(); // debounce: 300 ms after the last keystroke
    _t = Timer(const Duration(milliseconds: 300), () => ref.read(searchQueryProvider.notifier).state = v);
  }

  @override
  void dispose() { _t?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: TextField(
            autofocus: true,
            onChanged: _changed,
            decoration: const InputDecoration(hintText: 'Search billers', border: InputBorder.none),
          ),
        ),
        body: AsyncView(
          value: ref.watch(billerSearchProvider),
          onRetry: () => ref.invalidate(billerSearchProvider),
          data: (List<Biller> l) => BillerTiles(l),
        ),
      );
}
