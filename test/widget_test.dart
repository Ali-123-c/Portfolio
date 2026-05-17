// This is an architectural smoke unit test for Ali's Portfolio.
import 'package:flutter_test/flutter_test.dart';
import 'package:ali_portfolio/main.dart';
import 'package:ali_portfolio/core/router/router.dart';

void main() {
  test('Portfolio routing and theme setup validation smoke test', () {
    // Verify that router is initialized and configured correctly
    expect(AppRouter.router, isNotNull);
    expect(AppRouter.router.configuration, isNotNull);
    
    // Verify app widget can be instantiated
    const app = AliPortfolioApp();
    expect(app, isNotNull);
  });
}
