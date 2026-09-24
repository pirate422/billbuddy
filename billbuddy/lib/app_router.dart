import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'state/providers.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/categories_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/add_biller_screen.dart';
import 'presentation/screens/bill_screen.dart';
import 'presentation/screens/pay_screen.dart';
import 'presentation/screens/status_screen.dart';
import 'presentation/screens/recharge_screen.dart';
import 'presentation/screens/autopay_screen.dart';
import 'presentation/screens/history_screen.dart';

/// Every route except /login is guarded by the session.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ValueNotifier<String?>(ref.read(sessionProvider));
  ref.listen<String?>(sessionProvider, (_, n) => auth.value = n);
  ref.onDispose(auth.dispose);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = ref.read(sessionProvider) != null;
      final atLogin = state.matchedLocation == '/login';
      if (!loggedIn) return atLogin ? null : '/login';
      if (atLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/billers', builder: (_, __) => const CategoriesScreen()),
      GoRoute(path: '/billers/search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/billers/:id/add', builder: (_, s) => AddBillerScreen(billerId: s.pathParameters['id']!)),
      GoRoute(path: '/my-billers/:id', builder: (_, s) => BillScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/my-billers/:id/pay', builder: (_, s) => PayScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/my-billers/:id/autopay', builder: (_, s) => AutopayScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/payments/:id', builder: (_, s) => StatusScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/recharge', builder: (_, __) => const RechargeScreen()),
      GoRoute(path: '/history', builder: (_, s) => HistoryScreen(savedId: s.uri.queryParameters['saved'])),
    ],
  );
});
