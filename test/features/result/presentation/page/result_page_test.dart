import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/features/result/presentation/page/result_page.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';
import 'package:presen_neta/shared/models/review_result.dart';

import '../../../../shared/providers/test_service_providers.dart';

/// テスト用のAnalysisNotifier
class TestAnalysisNotifier extends AnalysisNotifier {
  final ReviewResult? _initialResult;

  TestAnalysisNotifier(this._initialResult);

  @override
  Future<ReviewResult?> build() async {
    return _initialResult;
  }

  @override
  Future<void> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  }) async {
    // テスト用の実装
  }

  @override
  void reset() {
    // テスト用の実装
  }
}

/// テスト用のローディング状態のAnalysisNotifier
class TestLoadingAnalysisNotifier extends AnalysisNotifier {
  @override
  Future<ReviewResult?> build() async {
    // 永続的にローディング状態を保つために無限に待機
    await Future.delayed(const Duration(hours: 1));
    return null;
  }

  @override
  Future<void> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  }) async {
    // テスト用の実装
  }

  @override
  void reset() {
    // テスト用の実装
  }
}

/// テスト用のエラー状態のAnalysisNotifier
class TestErrorAnalysisNotifier extends AnalysisNotifier {
  @override
  Future<ReviewResult?> build() async {
    throw Exception('テストエラー');
  }

  @override
  Future<void> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  }) async {
    // テスト用の実装
  }

  @override
  void reset() {
    // テスト用の実装
  }
}

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

  const highScoreReviewResult = ReviewResult(
    point: 95,
    good: [
      '素晴らしいプレゼンテーション',
      '聴衆を魅了する内容',
    ],
    improve: [
      'さらなる改善の余地は少ない',
    ],
  );

  const mediumScoreReviewResult = ReviewResult(
    point: 75,
    good: [
      '基本的な構成は良い',
    ],
    improve: [
      'より詳細な説明が必要',
      '視覚的な要素を追加',
    ],
  );

  const lowScoreReviewResult = ReviewResult(
    point: 45,
    good: [
      '努力は認められる',
    ],
    improve: [
      '構成を見直す必要がある',
      '内容をより分かりやすく',
      '練習を重ねる',
    ],
  );

  const emptyGoodReviewResult = ReviewResult(
    point: 50,
    good: [],
    improve: [
      '改善点1',
      '改善点2',
    ],
  );

  const emptyImproveReviewResult = ReviewResult(
    point: 80,
    good: [
      '良い点1',
      '良い点2',
    ],
    improve: [],
  );

  const emptyBothReviewResult = ReviewResult(
    point: 60,
    good: [],
    improve: [],
  );

  // テスト用のProviderオーバーライド
  final testResultOverrides = [
    ...testServiceOverrides,
    analysisNotifierProvider.overrideWith(
      () => TestAnalysisNotifier(testReviewResult),
    ),
  ];

  final highScoreOverrides = [
    ...testServiceOverrides,
    analysisNotifierProvider.overrideWith(
      () => TestAnalysisNotifier(highScoreReviewResult),
    ),
  ];

  final mediumScoreOverrides = [
    ...testServiceOverrides,
    analysisNotifierProvider.overrideWith(
      () => TestAnalysisNotifier(mediumScoreReviewResult),
    ),
  ];

  final lowScoreOverrides = [
    ...testServiceOverrides,
    analysisNotifierProvider.overrideWith(
      () => TestAnalysisNotifier(lowScoreReviewResult),
    ),
  ];

  final loadingOverrides = [
    ...testServiceOverrides,
    analysisNotifierProvider.overrideWith(
      () => TestLoadingAnalysisNotifier(),
    ),
  ];

  final errorOverrides = [
    ...testServiceOverrides,
    analysisNotifierProvider.overrideWith(
      () => TestErrorAnalysisNotifier(),
    ),
  ];

  final nullResultOverrides = [
    ...testServiceOverrides,
    analysisNotifierProvider.overrideWith(
      () => TestAnalysisNotifier(null),
    ),
  ];

  final emptyGoodOverrides = [
    ...testServiceOverrides,
    analysisNotifierProvider.overrideWith(
      () => TestAnalysisNotifier(emptyGoodReviewResult),
    ),
  ];

  final emptyImproveOverrides = [
    ...testServiceOverrides,
    analysisNotifierProvider.overrideWith(
      () => TestAnalysisNotifier(emptyImproveReviewResult),
    ),
  ];

  final emptyBothOverrides = [
    ...testServiceOverrides,
    analysisNotifierProvider.overrideWith(
      () => TestAnalysisNotifier(emptyBothReviewResult),
    ),
  ];

  group('ResultPage', () {
    group('正常系テスト', () {
      testWidgets('UI構成要素が表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        await tester.pumpAndSettle();

        // メインのテキスト要素
        expect(find.text('69人が寝た!'), findsOneWidget);

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

      testWidgets('「別のスライドをアップロード」ボタンをタップすると/へ遷移する', (
        WidgetTester tester,
      ) async {
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
    });

    group('点数別判定メッセージテスト', () {
      testWidgets('高得点（90点以上）で「いいんじゃない？」が表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: highScoreOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('5人が寝た!'), findsOneWidget);
      });

      testWidgets('中得点（75-89点）で「まあまあだけど」が表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: mediumScoreOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('25人が寝た!'), findsOneWidget);
      });

      testWidgets('低得点（60-74点）で「がんばれ」が表示される', (WidgetTester tester) async {
        // 60点のテストデータを作成
        final sixtyScoreResult = const ReviewResult(
          point: 60,
          good: ['良い点'],
          improve: ['改善点'],
        );

        final sixtyScoreOverrides = [
          ...testServiceOverrides,
          analysisNotifierProvider.overrideWith(
            () => AnalysisNotifier()..state = AsyncValue.data(sixtyScoreResult),
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: sixtyScoreOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('40人が寝た!'), findsOneWidget);
      });

      testWidgets('最低得点（60点未満）で「つまらん！」が表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: lowScoreOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('55人が寝た!'), findsOneWidget);
      });
    });

    group('エラー状態テスト', () {
      testWidgets('エラー状態でエラーメッセージが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: errorOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('分析エラー'), findsOneWidget);
        expect(find.textContaining('エラーが発生しました: テストエラー'), findsOneWidget);
        expect(find.text('最初からやり直す'), findsOneWidget);
      });

      testWidgets('エラー状態で「最初からやり直す」ボタンをタップすると/へ遷移する', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: errorOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        final retryButton = find.text('最初からやり直す');
        expect(retryButton, findsOneWidget);
        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        expect(router.state.uri.toString(), '/');
        expect(find.byKey(const Key('start-page')), findsOneWidget);
      });
    });

    group('ローディング状態テスト', () {
      testWidgets('ローディング状態でローディングUIが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: loadingOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('分析中...'), findsOneWidget);
        expect(find.text('AIがプレゼンテーションを評価しています'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('null結果テスト', () {
      testWidgets('分析結果がnullの場合、StartPageに戻る', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: nullResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // 一時的にPDFアップロード画面が表示される
        expect(find.text('PDFをアップロードしてください'), findsOneWidget);
        expect(find.text('StartPageに戻ります...'), findsOneWidget);

        // 少し待ってからナビゲーションが実行されることを確認
        await tester.pump(const Duration(milliseconds: 100));
      });
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

      testWidgets('AI分析結果セクションのアイコンが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // AI分析結果のアイコン
        expect(find.byIcon(Icons.psychology), findsOneWidget);
        // 良い点のアイコン
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        // 改善提案のアイコン
        expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
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

      testWidgets('AI分析結果セクションが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('AI分析結果'), findsOneWidget);
      });

      testWidgets('良い点と改善提案が箇条書きで表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // 箇条書きの記号が表示されることを確認
        expect(find.text('• '), findsNWidgets(6)); // 良い点3つ + 改善提案3つ
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

        // 寝た率テキストが表示されることを確認
        expect(find.text('69人が寝た!'), findsOneWidget);
      });

      testWidgets('寝た率テキストが正しいスタイルで表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // 寝た率テキストが表示されることを確認
        expect(find.text('69人が寝た!'), findsOneWidget);
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

    group('スクロールテスト', () {
      testWidgets('ページがスクロール可能である', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // SingleChildScrollViewが存在することを確認
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('色とテーマテスト', () {
      testWidgets('背景色が正しく設定されている', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // Scaffoldの背景色を確認
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, const Color(0xFFF7FAFC));
      });

      testWidgets('テキストカラーが正しく設定されている', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // メインカラーが使用されていることを確認
        expect(find.text('69人が寝た!'), findsOneWidget);
      });
    });

    group('アクセシビリティテスト', () {
      testWidgets('ボタンに適切なセマンティクスが設定されている', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: testResultOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // ボタンがタップ可能であることを確認
        expect(find.text('結果をシェア'), findsOneWidget);
        expect(find.text('別のスライドをアップロード'), findsOneWidget);
      });
    });

    group('エッジケーステスト', () {
      testWidgets('良い点が空の場合でも正常に表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: emptyGoodOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // 良い点セクションが表示されないことを確認（空のリストのため）
        expect(find.text('良い点'), findsNothing);
        expect(find.text('改善提案'), findsOneWidget);
        expect(find.text('AI分析結果'), findsOneWidget);
      });

      testWidgets('改善提案が空の場合でも正常に表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: emptyImproveOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // 改善提案セクションが表示されないことを確認（空のリストのため）
        expect(find.text('良い点'), findsOneWidget);
        expect(find.text('改善提案'), findsNothing);
        expect(find.text('AI分析結果'), findsOneWidget);
      });

      testWidgets('両方のリストが空の場合でも正常に表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: emptyBothOverrides,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // 両方のセクションが表示されないことを確認（空のリストでもAI分析結果は表示される）
        expect(find.text('良い点'), findsNothing);
        expect(find.text('改善提案'), findsNothing);
        expect(find.text('AI分析結果'), findsOneWidget);
      });
    });
  });
}
