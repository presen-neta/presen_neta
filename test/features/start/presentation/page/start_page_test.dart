import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/features/start/presentation/page/start_page.dart';
import 'package:presen_neta/shared/service/presentation_analysis_service.dart';

import 'start_page_test.mocks.dart';

@GenerateMocks([PresentationAnalysisService])
void main() {
  late MockPresentationAnalysisService mockService;
  late GoRouter router;

  setUp(() {
    mockService = MockPresentationAnalysisService();
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) => StartPage(
                service: mockService as PresentationAnalysisService?,
              ),
        ),
        GoRoute(
          path: '/result',
          builder: (context, state) => const SizedBox(key: Key('result-page')),
        ),
      ],
    );
  });

  testWidgets('UI 構成要素が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('PDFプレゼンテーションを分析'), findsOneWidget);
    expect(find.text('目的ははっきりしている？'), findsOneWidget);
    expect(find.text('文字ばっかりのスライド？'), findsOneWidget);
    expect(find.text('視聴者目線になっている？'), findsOneWidget);
    expect(find.text('PDFファイルを選択'), findsOneWidget);
  });

  testWidgets('ファイル選択時に /result へ遷移する', (WidgetTester tester) async {
    when(mockService.analyzePdfFile(any, any)).thenAnswer((_) async => true);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    final uploadButton = find.text('PDFファイルを選択');
    await tester.ensureVisible(uploadButton);
    await tester.tap(uploadButton);
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/result');
    expect(find.byKey(const Key('result-page')), findsOneWidget);
  });

  testWidgets('ファイル未選択時は遷移しない', (WidgetTester tester) async {
    when(mockService.analyzePdfFile(any, any)).thenAnswer((_) async => false);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    final uploadButton = find.text('PDFファイルを選択');
    await tester.ensureVisible(uploadButton);
    await tester.tap(uploadButton);
    await tester.pumpAndSettle();
    // ルートは変わらない
    expect(router.state.uri.toString(), '/');
    expect(find.byType(StartPage), findsOneWidget);
  });
}
