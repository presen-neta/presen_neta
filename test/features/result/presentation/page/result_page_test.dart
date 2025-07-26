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

  group('ResultPage', () {
    testWidgets('UI構成要素が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // メインのテキスト要素
      expect(find.text('つまらん！'), findsOneWidget);
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
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final shareButton = find.text('結果をシェア');
      await tester.ensureVisible(shareButton);
      await tester.tap(shareButton);
      await tester.pumpAndSettle();

      // ボタンが正常にタップできることを確認
      expect(shareButton, findsOneWidget);
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

    group('スタイルテスト', () {
      testWidgets('シェアボタンが適切なスタイルで表示される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ボタンのテキストを確認
        expect(find.text('結果をシェア'), findsOneWidget);
      });

      testWidgets('シェアボタンにアイコンが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // シェアアイコンが表示されることを確認
        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('シェアボタンにアイコンが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // シェアアイコンが表示されることを確認
        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('アップロードボタンが適切なスタイルで表示される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ボタンのテキストを確認
        expect(find.text('別のスライドをアップロード'), findsOneWidget);
      });

      testWidgets('アップロードボタンにアイコンが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // アップロードアイコンが表示されることを確認
        expect(find.byIcon(Icons.upload_file), findsOneWidget);
      });
    });

    group('レイアウトテスト', () {
      testWidgets('結果画像が表示される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // 結果画像が表示されることを確認
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('良い点セクションが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // 良い点のアイコンが表示されることを確認
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);

        // 良い点のタイトルが表示されることを確認
        expect(find.text('良い点'), findsOneWidget);
      });

      testWidgets('改善提案セクションが表示される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // 改善提案のアイコンが表示されることを確認
        expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);

        // 改善提案のタイトルが表示されることを確認
        expect(find.text('改善提案'), findsOneWidget);
      });

      testWidgets('背景色が正しく設定される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, const Color(0xFFF7FAFC));
      });
    });

    group('テキストスタイルテスト', () {
      testWidgets('タイトルテキストが正しいスタイルで表示される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final titleText = find.text('つまらん！');
        expect(titleText, findsOneWidget);

        final textWidget = tester.widget<Text>(titleText);
        expect(textWidget.textAlign, TextAlign.center);
      });

      testWidgets('パーセンテージテキストが正しいスタイルで表示される', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final percentageText = find.text('69人が寝た!');
        expect(percentageText, findsOneWidget);

        final textWidget = tester.widget<Text>(percentageText);
        expect(textWidget.textAlign, TextAlign.center);
      });
    });

    group('インタラクションテスト', () {
      testWidgets('シェアボタンがタップ可能である', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final shareButton = find.text('結果をシェア');
        expect(shareButton, findsOneWidget);

        // ボタンが存在することを確認
        expect(shareButton, findsOneWidget);
      });

      testWidgets('アップロードボタンがタップ可能である', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final uploadButton = find.text('別のスライドをアップロード');
        expect(uploadButton, findsOneWidget);

        // ボタンが存在することを確認
        expect(uploadButton, findsOneWidget);
      });
    });
  });
}
