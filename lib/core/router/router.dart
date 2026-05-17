import 'package:go_router/go_router.dart';
import '../../features/portfolio/screens/portfolio_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'portfolio',
        builder: (context, state) => const PortfolioScreen(),
      ),
    ],
  );
}
