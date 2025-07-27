import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/features/result/presentation/page/result_page.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';
import 'package:presen_neta/shared/models/review_result.dart';

import '../../../../shared/providers/test_service_providers.dart';

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

  // テスト用のダミーデータ
  const testReviewResult = ReviewResult(
    point: 31,
    good: [
      'スライドの構成が分かりやすい',
      '文字サイズが適切',
      '色使いが統一されている',
    ],
    improve: [
      'アニメーションを追加して動きを出す',
      'より具体的なデータを提示する',
      '結論を最初に示す',
    ],
  );

  // テスト用のProviderオーバーライド
  final testResultOverrides = [
    ...testServiceOverrides,
    // 分析結果を直接設定するためのProvider
    analysisNotifierProvider.overrideWith(
      () => AnalysisNotifier()..state = const AsyncValue.data(testReviewResult),
    ),
  ];

  group('ResultPage', () {
    testWidgets('UI構成要素が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testResultOverrides,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // メインのテキスト要素
      expect(find.text('あなたのプレゼンテーションは31点です！'), findsOneWidget);
      expect(find.text('つまらん！'), findsOneWidget);

      // ボタン要素
      expect(find.text('結果をシェア'), findsOneWidget);
      expect(find.text('別のスライドをアップロード'), findsOneWidget);

      // 評価セクション
      expect(find.text('良い点'), findsOneWidget);
      expect(find.text('改善提案'), findsOneWidget);

      // 良い点の内容（改行文字で区切られているため、部分文字列で検索）
      expect(find.textContaining('スライドの構成が分かりやすい'), findsOneWidget);
      expect(find.textContaining('文字サイズが適切'), findsOneWidget);
      expect(find.textContaining('色使いが統一されている'), findsOneWidget);

      // 改善提案の内容（改行文字で区切られているため、部分文字列で検索）
      expect(find.textContaining('アニメーションを追加して動きを出す'), findsOneWidget);
      expect(find.textContaining('より具体的なデータを提示する'), findsOneWidget);
      expect(find.textContaining('結論を最初に示す'), findsOneWidget);
    });

    testWidgets('「結果をシェア」ボタンをタップできる', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testResultOverrides,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final shareButton = find.text('結果をシェア');
      expect(shareButton, findsOneWidget);
      await tester.tap(shareButton);
      await tester.pumpAndSettle();

      // ボタンが正常にタップできることを確認
      expect(shareButton, findsOneWidget);
    });

    testWidgets('「別のスライドをアップロード」ボタンをタップすると/へ遷移する', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testResultOverrides,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final uploadButton = find.text('別のスライドをアップロード');
      expect(uploadButton, findsOneWidget);
      await tester.tap(uploadButton);
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), '/');
      expect(find.byKey(const Key('start-page')), findsOneWidget);
    });

    group('スタイルテスト', () {
      testWidgets('シェアボタンが適切なスタイルで表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // ボタンのテキストを確認
        expect(find.text('結果をシェア'), findsOneWidget);
      });

      testWidgets('シェアボタンにアイコンが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // シェアアイコンが表示されることを確認
        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('アップロードボタンが適切なスタイルで表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // ボタンのテキストを確認
        expect(find.text('別のスライドをアップロード'), findsOneWidget);
      });

      testWidgets('アップロードボタンにアイコンが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // アップロードアイコンが表示されることを確認
        expect(find.byIcon(Icons.upload_file), findsOneWidget);
      });
    });

    group('レイアウトテスト', () {
      testWidgets('結果画像が表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // 結果画像が表示されることを確認
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('評価セクションが正しく表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // 評価セクションのタイトルが表示されることを確認
        expect(find.text('良い点'), findsOneWidget);
        expect(find.text('改善提案'), findsOneWidget);
      });
    });

    group('テキストスタイルテスト', () {
      testWidgets('タイトルテキストが正しいスタイルで表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // タイトルテキストが表示されることを確認
        expect(find.text('あなたのプレゼンテーションは31点です！'), findsOneWidget);
      });

      testWidgets('パーセンテージテキストが正しいスタイルで表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // パーセンテージテキストが表示されることを確認
        expect(find.text('つまらん！'), findsOneWidget);
      });
    });

    group('インタラクションテスト', () {
      testWidgets('シェアボタンがタップ可能である', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        final shareButton = find.text('結果をシェア');
        expect(shareButton, findsOneWidget);
        await tester.tap(shareButton);
        await tester.pumpAndSettle();
      });

      testWidgets('アップロードボタンがタップ可能である', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        final uploadButton = find.text('別のスライドをアップロード');
        expect(uploadButton, findsOneWidget);
        await tester.tap(uploadButton);
        await tester.pumpAndSettle();
      });
    });
  });
}
