import '../models/biller.dart';
import '../../core/api/api_client.dart';

class BillerRepository {
  final ApiClient apiClient;

  BillerRepository({required this.apiClient});

  static const List<Biller> mockBillers = [
    Biller(
      id: 'bescom',
      name: 'BESCOM Electricity - Bangalore',
      category: 'Electricity',
      state: 'Karnataka',
      fields: [
        BillerField(key: 'account_id', label: '10-Digit Account ID', regex: r'^\d{10}$'),
      ],
      allowsPartial: false,
    ),
    Biller(
      id: 'tata_power',
      name: 'Tata Power Electricity - Mumbai',
      category: 'Electricity',
      state: 'Maharashtra',
      fields: [
        BillerField(key: 'consumer_no', label: '12-Digit Consumer Number', regex: r'^\d{12}$'),
      ],
      allowsPartial: false,
    ),
    Biller(
      id: 'airtel_broadband',
      name: 'Airtel Broadband & Fiber',
      category: 'Broadband',
      state: 'Pan India',
      fields: [
        BillerField(key: 'landline_no', label: 'Landline Number with STD Code', regex: r'^\d{10,11}$'),
      ],
      allowsPartial: true,
    ),
    Biller(
      id: 'bwssb_water',
      name: 'BWSSB Bangalore Water Supply',
      category: 'Water',
      state: 'Karnataka',
      fields: [
        BillerField(key: 'rr_no', label: 'RR Number (e.g. W123456)', regex: r'^[A-Z0-9]{6,10}$'),
      ],
      allowsPartial: false,
    ),
  ];

  Future<List<String>> fetchCategories() async {
    return [
      'Electricity',
      'Water',
      'Piped Gas',
      'Broadband',
      'DTH',
      'LPG Cylinder',
      'Landline',
      'Municipal Tax'
    ];
  }

  Future<List<Biller>> searchBillers(String query) async {
    if (query.trim().isEmpty) return mockBillers;
    return mockBillers.where((b) {
      final q = query.toLowerCase();
      return b.name.toLowerCase().contains(q) ||
          b.category.toLowerCase().contains(q) ||
          b.state.toLowerCase().contains(q);
    }).toList();
  }

  Future<Biller> getBillerById(String id) async {
    return mockBillers.firstWhere(
      (b) => b.id == id,
      orElse: () => mockBillers.first,
    );
  }
}