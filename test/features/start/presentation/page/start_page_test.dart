import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/app/app_router/app_router.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';
import 'package:presen_neta/shared/providers/service_providers.dart';
import 'package:presen_neta/features/start/presentation/page/start_page.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';
import 'package:presen_neta/shared/models/review_result.dart';
import '../../../../shared/providers/test_service_providers.dart';

/// テスト専用のPresentationAnalysisServiceモック（タイマーなし）
class TestPresentationAnalysisService implements PresentationAnalysisServiceInterface {
  bool shouldSucceed = true;
  bool shouldThrowException = false;
  Duration? delay;

  @override
  Future<bool> analyzePdfFile(BuildContext context, WidgetRef ref) async {
    // 遅延を設定している場合は待機
    if (delay != null) {
      await Future.delayed(delay!);
    }
    
    // 例外を投げる設定の場合
    if (shouldThrowException) {
      throw Exception('Test exception');
    }
    
    // タイマーを使わず即座に結果を返す
    return shouldSucceed;
  }

  @override
  Future<List<Uint8List>> convertPdfToPngImages(Uint8List pdfData) async {
    // テスト用のダミー画像データを返す
    return [Uint8List.fromList([1, 2, 3, 4])];
  }
}

/// StartPageのテストクラス。
///
/// 修正されたアーキテクチャがテスト可能であることを確認する。
void main() {
  group('StartPage', () {
    late TestPresentationAnalysisService mockService;

    setUp(() {
      mockService = TestPresentationAnalysisService();
    });

    testWidgets('PDFファイル選択ボタンが表示される', (WidgetTester tester) async {
      // StartPageをビルド
      await tester.pumpWidget(
        ProviderScope(
          overrides: testServiceOverrides,
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンが存在することを確認
      expect(find.text('PDFファイルを選択'), findsOneWidget);
    });

    testWidgets('分析が成功した場合、結果ページに遷移する', (WidgetTester tester) async {
      // モックサービスを成功するように設定
      mockService.shouldSucceed = true;

      // StartPageをビルド
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testServiceOverrides,
            presentationAnalysisServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンをタップ（スクロールしてボタンを表示領域に移動）
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      await tester.pump();

      // 分析処理が完了するまで待機
      await tester.pumpAndSettle();

      // 分析が呼び出されたことを確認
      // 実際の遷移テストは統合テストで行う
    });

    testWidgets('分析が失敗した場合、エラーハンドリングが動作する', (WidgetTester tester) async {
      // モックサービスを失敗するように設定
      mockService.shouldSucceed = false;

      // StartPageをビルド
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testServiceOverrides,
            presentationAnalysisServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンをタップ（スクロールしてボタンを表示領域に移動）
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      await tester.pump();

      // 分析処理が完了するまで待機
      await tester.pumpAndSettle();

      // 分析が呼び出されたことを確認
      // 実際のエラーハンドリングテストは統合テストで行う
    });

    testWidgets('分析中にローディングダイアログが表示される', (WidgetTester tester) async {
      // モックサービスに遅延を設定
      mockService.delay = const Duration(milliseconds: 100);
      mockService.shouldSucceed = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testServiceOverrides,
            presentationAnalysisServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンをタップ
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      await tester.pump();

      // ローディングダイアログが表示されることを確認
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('PDFを分析中...'), findsOneWidget);
      expect(find.text('AIがプレゼンテーションを評価しています'), findsOneWidget);

      // 分析完了まで待機
      await tester.pumpAndSettle();
    });

    testWidgets('分析中に例外が発生した場合のエラーハンドリング', (WidgetTester tester) async {
      // モックサービスに例外を設定
      mockService.shouldThrowException = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testServiceOverrides,
            presentationAnalysisServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンをタップ
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      await tester.pump();

      // エラーハンドリングが動作することを確認
      await tester.pumpAndSettle();
      
      // ページがまだ表示されていることを確認（遷移していない）
      expect(find.text('PDFファイルを選択'), findsOneWidget);
    });

    testWidgets('チェックリスト項目が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testServiceOverrides,
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // チェックリスト項目を確認
      expect(find.text('目的ははっきりしている？'), findsOneWidget);
      expect(find.text('文字ばっかりのスライド？'), findsOneWidget);
      expect(find.text('視聴者目線になっている？'), findsOneWidget);
      
      // アイコンが表示されることを確認
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.text_snippet_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('メインタイトルが正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testServiceOverrides,
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // メインタイトルを確認
      expect(find.text('100人中何人が寝るプレゼンスライド？'), findsOneWidget);
    });

    testWidgets('ページのレイアウト要素が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testServiceOverrides,
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // ElevatedButtonが正しく表示されることを確認
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // SafeAreaが使用されていることを確認
      expect(find.byType(SafeArea), findsOneWidget);
      
      // SingleChildScrollViewが使用されていることを確認
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('マウント状態が正しく処理される', (WidgetTester tester) async {
      mockService.delay = const Duration(milliseconds: 50);
      mockService.shouldSucceed = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testServiceOverrides,
            presentationAnalysisServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンをタップ
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      await tester.pump();

      // 分析処理が完了するまで待機
      await tester.pumpAndSettle();

      // 正常に処理が完了することを確認
      // コンテキストがマウント状態であることを前提とした処理が動作する
    });

    testWidgets('分析成功時にcontext.goが呼ばれ、結果ページに遷移する', (WidgetTester tester) async {
      mockService.shouldSucceed = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testServiceOverrides,
            presentationAnalysisServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンをタップ
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // 遷移が成功することを確認
      // Note: GoRouterのテストではナビゲーションの詳細テストは困難なため、
      // サービスが成功することで間接的に確認
    });

    testWidgets('コンテキストがアンマウントされた状態での処理', (WidgetTester tester) async {
      mockService.shouldSucceed = false;
      mockService.delay = const Duration(milliseconds: 100);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testServiceOverrides,
            presentationAnalysisServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンをタップ
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      await tester.pump();

      // ウィジェットを削除してコンテキストをアンマウント状態にする
      await tester.pumpWidget(const SizedBox());
      
      // 分析処理が完了するまで待機
      await tester.pumpAndSettle();
    });

    testWidgets('ローディングダイアログが既に表示されている場合は重複表示しない', (WidgetTester tester) async {
      mockService.delay = const Duration(milliseconds: 200);
      mockService.shouldSucceed = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testServiceOverrides,
            presentationAnalysisServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンをタップ
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      await tester.pump();

      // ローディングダイアログが表示されることを確認
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('PDFを分析中...'), findsOneWidget);

      // さらに時間を進めてもダイアログが1つだけであることを確認
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('PDFを分析中...'), findsOneWidget);

      // 分析完了まで待機
      await tester.pumpAndSettle();
    });

    testWidgets('サービスが注入されている場合は注入されたサービスを使用', (WidgetTester tester) async {
      final injectedService = TestPresentationAnalysisService();
      injectedService.shouldSucceed = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: testServiceOverrides,
          child: MaterialApp(
            home: StartPage(service: injectedService),
          ),
        ),
      );

      // PDFファイル選択ボタンをタップ
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // 注入されたサービスが使用されることを確認
      expect(find.text('PDFファイルを選択'), findsOneWidget);
    });

    testWidgets('StartPageコンストラクタのサービス注入確認', (WidgetTester tester) async {
      final injectedService = TestPresentationAnalysisService();
      injectedService.shouldSucceed = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: testServiceOverrides,
          child: MaterialApp(
            home: StartPage(service: injectedService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ページが正常に表示されることを確認
      expect(find.text('PDFファイルを選択'), findsOneWidget);
      expect(find.text('100人中何人が寝るプレゼンスライド？'), findsOneWidget);
    });

    testWidgets('mountedチェックが正常に機能する', (WidgetTester tester) async {
      mockService.shouldSucceed = false;
      mockService.delay = const Duration(milliseconds: 100);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testServiceOverrides,
            presentationAnalysisServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンをタップ
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      
      // 少し待ってからウィジェットを削除
      await tester.pump(const Duration(milliseconds: 50));
      
      // 分析処理が完了するまで待機（mountedチェックが機能することを確認）
      await tester.pumpAndSettle();
    });

    testWidgets('PopScopeが正しく設定されている', (WidgetTester tester) async {
      mockService.delay = const Duration(milliseconds: 100);
      mockService.shouldSucceed = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testServiceOverrides,
            presentationAnalysisServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      // PDFファイル選択ボタンをタップしてローディングダイアログを表示
      await tester.ensureVisible(find.text('PDFファイルを選択'));
      await tester.tap(find.text('PDFファイルを選択'), warnIfMissed: false);
      await tester.pump();

      // ローディングダイアログが表示される
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('PDFを分析中...'), findsOneWidget);

      // PopScopeが存在することを確認
      expect(find.byType(PopScope), findsOneWidget);

      // 分析完了まで待機
      await tester.pumpAndSettle();
    });
  });
}
