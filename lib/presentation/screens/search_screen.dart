import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/biller.dart';
import '../../state/biller_search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(billerSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search billers (e.g. BESCOM, Tata Power)...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            setState(() => _searchQuery = val);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_searchQuery.isEmpty) ...[
              Text(
                'Popular Service Providers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _MockSearchList(query: '')),
            ] else ...[
              Expanded(
                child: searchResultsAsync.when(
                  data: (billers) {
                    if (billers.isEmpty) {
                      return _MockSearchList(query: _searchQuery);
                    }
                    return ListView.builder(
                      itemCount: billers.length,
                      itemBuilder: (context, index) {
                        final biller = billers[index];
                        return _BillerSearchCard(biller: biller);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => _MockSearchList(query: _searchQuery),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BillerSearchCard extends StatelessWidget {
  final Biller biller;

  const _BillerSearchCard({required this.biller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.bolt, color: Colors.deepPurple),
        ),
        title: Text(
          biller.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${biller.category} • ${biller.state}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/billers/add?billerId=${biller.id}'),
      ),
    );
  }
}

class _MockSearchList extends StatelessWidget {
  final String query;

  const _MockSearchList({required this.query});

  @override
  Widget build(BuildContext context) {
    final mockBillers = [
      const Biller(
        id: 'bescom',
        name: 'BESCOM Electricity - Bangalore',
        category: 'Electricity',
        state: 'Karnataka',
        fields: [],
        allowsPartial: false,
      ),
      const Biller(
        id: 'tata_power',
        name: 'Tata Power Electricity - Mumbai',
        category: 'Electricity',
        state: 'Maharashtra',
        fields: [],
        allowsPartial: false,
      ),
      const Biller(
        id: 'airtel_broadband',
        name: 'Airtel Broadband & Fiber',
        category: 'Broadband',
        state: 'Pan India',
        fields: [],
        allowsPartial: true,
      ),
      const Biller(
        id: 'bwssb_water',
        name: 'BWSSB Bangalore Water Supply',
        category: 'Water',
        state: 'Karnataka',
        fields: [],
        allowsPartial: false,
      ),
    ];

    final filtered = mockBillers.where((b) {
      if (query.isEmpty) return true;
      return b.name.toLowerCase().contains(query.toLowerCase()) ||
          b.category.toLowerCase().contains(query.toLowerCase()) ||
          b.state.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No billers found matching "$query"',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _BillerSearchCard(biller: filtered[index]);
      },
    );
  }
}