import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/payment_history_screen.dart';
import '../screens/search_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/autopay_settings_screen.dart';
import '../screens/bill_details_screen.dart';
import '../screens/recharge_screen.dart';
import '../screens/payment_status_screen.dart';
import '../screens/pay_bill_screen.dart';
import '../screens/add_biller_screen.dart';
import '../screens/home_screen.dart';
import '../screens/placeholder_screens.dart'
    hide
        AddBillerScreen,
        PayBillScreen,
        PaymentStatusScreen,
        RechargeScreen,
        BillDetailsScreen,
        AutopaySettingsScreen,
        CategoriesScreen,
        SearchScreen,
        PaymentHistoryScreen;

/// Provider for GoRouter navigation mapping all 10 biller routes
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      // 1. Home Screen
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

      // 2. Categories Screen
      GoRoute(
        path: '/billers',
        builder: (context, state) => const CategoriesScreen(),
        routes: [
          // 3. Search Screen (/billers/search)
          GoRoute(
            path: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          // 4. Add Biller Screen (/billers/add)
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddBillerScreen(),
          ),
        ],
      ),

      // 5. Bill Details Screen (/vp-billers/:id)
      GoRoute(
        path: '/vp-billers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BillDetailsScreen(id: id);
        },
        routes: [
          // 6. Pay Bill Screen (/vp-billers/:id/pay)
          GoRoute(
            path: 'pay',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return PayBillScreen(id: id);
            },
          ),
          // 9. Autopay Settings Screen (/vp-billers/:id/autopay)
          GoRoute(
            path: 'autopay',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return AutopaySettingsScreen(id: id);
            },
          ),
        ],
      ),

      // 7. Payment Status Screen (/payments/:id)
      GoRoute(
        path: '/payments/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PaymentStatusScreen(id: id);
        },
      ),

      GoRoute(
        path: 'add',
        builder: (context, state) {
          final billerId = state.uri.queryParameters['billerId'];
          return AddBillerScreen(billerId: billerId);
        },
      ),

      // 8. Recharge Screen (/recharge)
      GoRoute(
        path: '/recharge',
        builder: (context, state) => const RechargeScreen(),
      ),

      // 10. Payment History Screen (/history)
      GoRoute(
        path: '/history',
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
    ],
  );
});
