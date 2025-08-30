import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:presen_neta/app/app_router/app_router.dart';
import 'package:presen_neta/features/start/presentation/page/start_page.dart';

import '../../shared/providers/test_service_providers.dart';

void main() {
  group('appRouter', () {
    testWidgets('ルート / で StartPage が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testServiceOverrides,
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(StartPage), findsOneWidget);
    });

    testWidgets('存在しないルートでエラー画面が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testServiceOverrides,
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );
      appRouter.go('/notfound');
      await tester.pumpAndSettle();
      // errorBuilder で 'Page Not Found' テキストが表示されることを検証
      expect(find.text('Page Not Found'), findsOneWidget);
    });
  });
}
