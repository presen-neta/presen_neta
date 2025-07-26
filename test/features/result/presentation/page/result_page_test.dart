import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:presen_neta/features/result/presentation/page/result_page.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox(key: Key('start-page')),
        ),
        GoRoute(
          path: '/result',
          builder: (context, state) => const ResultPage(),
        ),
      ],
      initialLocation: '/result',
    );
  });

  testWidgets('UI構成要素が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('つまらん！'), findsOneWidget);
    expect(find.text('69人が寝た!'), findsOneWidget);
    expect(find.text('結果をシェア'), findsOneWidget);
    expect(find.text('別のスライドをアップロード'), findsOneWidget);
    expect(find.text('良い点'), findsOneWidget);
    expect(find.text('改善提案'), findsOneWidget);
  });

  testWidgets('「結果をシェア」ボタンをタップできる', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    final shareButton = find.text('結果をシェア');
    await tester.ensureVisible(shareButton);
    await tester.tap(shareButton);
    await tester.pumpAndSettle();
  });

  testWidgets('「別のスライドをアップロード」ボタンをタップすると/へ遷移する', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    final uploadButton = find.text('別のスライドをアップロード');
    await tester.ensureVisible(uploadButton);
    await tester.tap(uploadButton);
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/');
    expect(find.byKey(const Key('start-page')), findsOneWidget);
  });
}
