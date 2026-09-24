import '../ui.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});
  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesState();
}

class _CategoriesState extends ConsumerState<CategoriesScreen> {
  String? _cat;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add a biller'), actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/billers/search')),
        ]),
        body: AsyncView(
          value: ref.watch(categoriesProvider),
          onRetry: () => ref.invalidate(categoriesProvider),
          data: (List<BillCategory> cats) {
            final sel = _cat ?? cats.first.id;
            return Column(children: [
              SizedBox(
                height: 60,
                child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), children: [
                  for (final c in cats)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(categoryIcon(c.id), size: 18),
                        label: Text(c.name),
                        selected: sel == c.id,
                        onSelected: (_) => setState(() => _cat = c.id),
                      ),
                    ),
                ]),
              ),
              Expanded(
                child: AsyncView(
                  value: ref.watch(billersByCategoryProvider(sel)),
                  onRetry: () => ref.invalidate(billersByCategoryProvider(sel)),
                  data: (List<Biller> l) => BillerTiles(l),
                ),
              ),
            ]);
          },
        ),
      );
}
