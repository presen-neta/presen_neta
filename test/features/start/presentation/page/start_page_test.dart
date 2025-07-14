import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/features/start/presentation/page/start_page.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';

import 'start_page_test.mocks.dart';

@GenerateMocks([FilePickerService])
void main() {
  late MockFilePickerService mockService;
  late GoRouter router;

  setUp(() {
    mockService = MockFilePickerService();
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) =>
                  StartPage(service: mockService as FilePickerService?),
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
    expect(find.text('100人中何人が寝るかな？'), findsOneWidget);
    expect(find.text('目的ははっきりしている？'), findsOneWidget);
    expect(find.text('文字ばっかりのスライド？'), findsOneWidget);
    expect(find.text('視聴者目線になっている？'), findsOneWidget);
    expect(find.text('スライドをアップロード'), findsOneWidget);
  });

  testWidgets('ファイル選択時に /result へ遷移する', (WidgetTester tester) async {
    when(mockService.pickFile()).thenAnswer(
      (_) async => FilePickerResult([
        PlatformFile(name: 'dummy.pdf', size: 1),
      ]),
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('スライドをアップロード'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/result');
    expect(find.byKey(const Key('result-page')), findsOneWidget);
  });

  testWidgets('ファイル未選択時は遷移しない', (WidgetTester tester) async {
    when(mockService.pickFile()).thenAnswer((_) async => null);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('スライドをアップロード'));
    await tester.pumpAndSettle();
    // ルートは変わらない
    expect(router.state.uri.toString(), '/');
    expect(find.byType(StartPage), findsOneWidget);
  });
}
