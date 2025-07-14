import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:presen_neta/app/app_router/app_router.dart';
import 'package:presen_neta/features/result/presentation/page/result_page.dart';
import 'package:presen_neta/features/start/presentation/page/start_page.dart';

void main() {
  group('appRouter', () {
    testWidgets('ルート / で StartPage が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(StartPage), findsOneWidget);
    });

    testWidgets('ルート /result で ResultPage が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter,
        ),
      );
      appRouter.go('/result');
      await tester.pumpAndSettle();
      expect(find.byType(ResultPage), findsOneWidget);
    });

    testWidgets('存在しないルートでエラー画面が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter,
        ),
      );
      appRouter.go('/notfound');
      await tester.pumpAndSettle();
      // errorBuilder で 'Page Not Found' テキストが表示されることを検証
      expect(find.text('Page Not Found'), findsOneWidget);
    });
  });
}
