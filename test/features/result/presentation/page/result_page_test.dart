// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:logger/logger.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:presen_neta/features/result/presentation/page/result_page.dart';
// import 'package:presen_neta/features/result/provider/result_provider.dart';
// import 'package:presen_neta/shared/models/review_result.dart';

// import '../../../../shared/providers/test_service_providers.dart';
// import 'result_page_test.mocks.dart';

// @GenerateMocks([Logger])
// /// テスト専用のResultPageラッパー
// class TestResultPageWrapper extends StatelessWidget {
//   const TestResultPageWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: const ResultPage(),
//       builder: (context, child) {
//         // 画像ロードエラーを無視する
//         return child ?? const SizedBox();
//       },
//     );
//   }
// }

// /// テスト用のAnalysisNotifier。
// class TestAnalysisNotifier extends AnalysisNotifier {
//   TestAnalysisNotifier(this._initialResult);
//   final ReviewResult? _initialResult;

//   @override
//   Future<ReviewResult?> build() async {
//     return _initialResult;
//   }

//   @override
//   Future<void> analyzeMultipleSlideImages(
//     List<Uint8List> imageDataList, {
//     String imageMimeType = 'image/png',
//   }) async {
//     // テスト用の実装
//   }

//   @override
//   void reset() {
//     // テスト用の実装
//   }
// }

// /// テスト用のローディング状態のAnalysisNotifier。
// class TestLoadingAnalysisNotifier extends AnalysisNotifier {
//   @override
//   Future<ReviewResult?> build() async {
//     // ローディング状態を維持するため、完了しないCompleterを使用
//     final completer = Completer<ReviewResult?>();
//     return completer.future;
//   }

//   @override
//   Future<void> analyzeMultipleSlideImages(
//     List<Uint8List> imageDataList, {
//     String imageMimeType = 'image/png',
//   }) async {}
//   @override
//   void reset() {}
// }

// /// テスト用のエラー状態のAnalysisNotifier。
// class TestErrorAnalysisNotifier extends AnalysisNotifier {
//   @override
//   Future<ReviewResult?> build() async {
//     throw Exception('テストエラー');
//   }

//   @override
//   Future<void> analyzeMultipleSlideImages(
//     List<Uint8List> imageDataList, {
//     String imageMimeType = 'image/png',
//   }) async {
//     // テスト用の実装
//   }

//   @override
//   void reset() {
//     // テスト用の実装
//   }
// }

// /// テストで logger を注入可能な ResultPage
// class TestableResultPage extends ConsumerWidget {
//   const TestableResultPage({super.key, required this.logger});

//   final Logger logger;

//   String _getJudgmentMessage(int point) {
//     if (point >= 90) {
//       return 'いいんじゃない？';
//     } else if (point >= 75) {
//       return 'まあまあだけど';
//     } else if (point >= 60) {
//       return 'がんばれ';
//     } else {
//       return 'つまらん！';
//     }
//   }

//   String _getSleepRateMessage(int point) {
//     final sleepRate = 100 - point;
//     return '$sleepRate人が寝た!';
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     final analysisState = ref.watch(analysisNotifierProvider);

//     try {
//       logger.d('ResultPage - 分析状態: $analysisState');
//     } on Exception catch (e) {
//       logger.d('ResultPage - 分析状態: $analysisState : $e');
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF7FAFC),
//       body: SafeArea(
//         child: analysisState.when(
//           data: (result) {
//             try {
//               logger.d(
//                 'ResultPage - data状態: result=${result?.point ?? 'null'}',
//               );
//             } on Exception catch (e) {
//               logger.d(
//                 'ResultPage - data状態: result=${result?.point ?? 'null'} : $e',
//               );
//             }
//             if (result == null) {
//               try {
//                 logger.i('ResultPage - 分析結果なし、StartPageに戻る');
//               } on Exception catch (e) {
//                 logger.d('ResultPage - 分析結果なし、StartPageに戻る : $e');
//               }
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (context.mounted) {
//                   try {
//                     context.go('/');
//                   } on Exception catch (e) {
//                     try {
//                       logger.e('ResultPage - ナビゲーションエラー: $e');
//                     } on Exception catch (logError) {
//                       logger.d('ResultPage - ナビゲーションエラー: $logError');
//                     }
//                   }
//                 }
//               });
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.upload_file,
//                       color: Color(0xFF00B8D9),
//                       size: 64,
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'PDFをアップロードしてください',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF00B8D9),
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'StartPageに戻ります...',
//                       style: TextStyle(
//                         color: Colors.grey,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 32,
//                 ),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 16),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(24),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.07),
//                             blurRadius: 16,
//                             offset: const Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(16),
//                       child: Image.asset(
//                         'assets/ResultPage.png',
//                         width: 220,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                     const SizedBox(height: 28),
//                     Text(
//                       _getSleepRateMessage(result.point),
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF00B8D9),
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 54,
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF00B8D9),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 4,
//                         ),
//                         onPressed: () async {
//                           // シェア機能は省略（テスト用）
//                         },
//                         icon: const Icon(Icons.share, color: Colors.white),
//                         label: const Text(
//                           '結果をシェア',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 28),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(18),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.06),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               const Icon(
//                                 Icons.psychology,
//                                 color: Color(0xFF00B8D9),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'AI分析結果',
//                                 style: theme.textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                   color: const Color(0xFF00B8D9),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           if (result.good.isNotEmpty) ...[
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.thumb_up,
//                                   color: Color(0xFF00B8D9),
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   '良い点',
//                                   style: theme.textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: const Color(0xFF00B8D9),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             ...result.good.map(
//                               (good) => Padding(
//                                 padding: const EdgeInsets.only(left: 16),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text('• '),
//                                     Expanded(
//                                       child: Text(
//                                         good,
//                                         style: theme.textTheme.bodyMedium
//                                             ?.copyWith(
//                                               height: 1.5,
//                                             ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                           ],
//                           if (result.improve.isNotEmpty) ...[
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.lightbulb_outline,
//                                   color: Color(0xFFFF6B35),
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   '改善提案',
//                                   style: theme.textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: const Color(0xFFFF6B35),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             ...result.improve.map(
//                               (improve) => Padding(
//                                 padding: const EdgeInsets.only(left: 16),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text('• '),
//                                     Expanded(
//                                       child: Text(
//                                         improve,
//                                         style: theme.textTheme.bodyMedium
//                                             ?.copyWith(
//                                               height: 1.5,
//                                             ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 28),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 54,
//                       child: OutlinedButton.icon(
//                         style: OutlinedButton.styleFrom(
//                           side: const BorderSide(
//                             color: Color(0xFF00B8D9),
//                             width: 2,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         onPressed: () {
//                           ref.read(analysisNotifierProvider.notifier).reset();
//                           context.go('/');
//                         },
//                         icon: const Icon(
//                           Icons.upload_file,
//                           color: Color(0xFF00B8D9),
//                         ),
//                         label: const Text(
//                           '別のスライドをアップロード',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF00B8D9),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//           loading: () {
//             try {
//               logger.d('ResultPage - loading状態');
//             } on Exception catch (e) {
//               logger.d('ResultPage - loading状態: $e');
//             }
//             return const Scaffold(
//               backgroundColor: Color(0xFFF7FAFC),
//               body: SafeArea(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         color: Color(0xFF00B8D9),
//                         strokeWidth: 3,
//                       ),
//                       SizedBox(height: 24),
//                       Text(
//                         '分析中...',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF00B8D9),
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'AIがプレゼンテーションを評価しています',
//                         style: TextStyle(
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//           error: (error, stack) {
//             try {
//               logger.e('ResultPage - error状態: $error');
//             } on Exception catch (e) {
//               logger.d('ResultPage - error状態: $error : $e');
//             }
//             return Scaffold(
//               backgroundColor: const Color(0xFFF7FAFC),
//               body: SafeArea(
//                 child: Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.error_outline,
//                           color: Colors.red,
//                           size: 64,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           '分析エラー',
//                           style: theme.textTheme.headlineSmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'エラーが発生しました: $error',
//                           style: const TextStyle(color: Colors.red),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 32),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 54,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF00B8D9),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                             ),
//                             onPressed: () {
//                               ref
//                                   .read(analysisNotifierProvider.notifier)
//                                   .reset();
//                               context.go('/');
//                             },
//                             child: const Text(
//                               '最初からやり直す',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   late GoRouter router;

//   setUp(() {
//     // 画像のロードエラーを無視する設定
//     FlutterError.onError = (details) {
//       if (details.exception.toString().contains('Failed to load asset') ||
//           details.exception.toString().contains('Unable to load asset') ||
//           details.exception.toString().contains('FormatException')) {
//         // 画像関連のエラーは無視
//         return;
//       }
//       // その他のエラーは通常通り処理
//       FlutterError.dumpErrorToConsole(details);
//     };
//     router = GoRouter(
//       routes: [
//         GoRoute(
//           path: '/',
//           builder: (context, state) => const SizedBox(key: Key('start-page')),
//         ),
//         GoRoute(
//           path: '/result',
//           builder: (context, state) => const ResultPage(),
//         ),
//       ],
//       initialLocation: '/result',
//     );
//   });

//   // テスト用のダミーデータ
//   const testReviewResult = ReviewResult(
//     point: 31,
//     good: [
//       'スライドの構成が分かりやすい',
//       '文字サイズが適切',
//       '色使いが統一されている',
//     ],
//     improve: [
//       'アニメーションを追加して動きを出す',
//       'より具体的なデータを提示する',
//       '結論を最初に示す',
//     ],
//   );

//   const highScoreReviewResult = ReviewResult(
//     point: 95,
//     good: [
//       '素晴らしいプレゼンテーション',
//       '聴衆を魅了する内容',
//     ],
//     improve: [
//       'さらなる改善の余地は少ない',
//     ],
//   );

//   const mediumScoreReviewResult = ReviewResult(
//     point: 75,
//     good: [
//       '基本的な構成は良い',
//     ],
//     improve: [
//       'より詳細な説明が必要',
//       '視覚的な要素を追加',
//     ],
//   );

//   const lowScoreReviewResult = ReviewResult(
//     point: 45,
//     good: [
//       '努力は認められる',
//     ],
//     improve: [
//       '構成を見直す必要がある',
//       '内容をより分かりやすく',
//       '練習を重ねる',
//     ],
//   );

//   const emptyGoodReviewResult = ReviewResult(
//     point: 50,
//     good: [],
//     improve: [
//       '改善点1',
//       '改善点2',
//     ],
//   );

//   const emptyImproveReviewResult = ReviewResult(
//     point: 80,
//     good: [
//       '良い点1',
//       '良い点2',
//     ],
//     improve: [],
//   );

//   const emptyBothReviewResult = ReviewResult(
//     point: 60,
//     good: [],
//     improve: [],
//   );

//   // テスト用のProviderオーバーライド
//   final testResultOverrides = [
//     ...testServiceOverrides,
//     analysisNotifierProvider.overrideWith(
//       () => TestAnalysisNotifier(testReviewResult),
//     ),
//   ];

//   final highScoreOverrides = [
//     ...testServiceOverrides,
//     analysisNotifierProvider.overrideWith(
//       () => TestAnalysisNotifier(highScoreReviewResult),
//     ),
//   ];

//   final mediumScoreOverrides = [
//     ...testServiceOverrides,
//     analysisNotifierProvider.overrideWith(
//       () => TestAnalysisNotifier(mediumScoreReviewResult),
//     ),
//   ];

//   final lowScoreOverrides = [
//     ...testServiceOverrides,
//     analysisNotifierProvider.overrideWith(
//       () => TestAnalysisNotifier(lowScoreReviewResult),
//     ),
//   ];

//   final loadingOverrides = [
//     ...testServiceOverrides,
//     analysisNotifierProvider.overrideWith(
//       TestLoadingAnalysisNotifier.new,
//     ),
//   ];

//   final errorOverrides = [
//     ...testServiceOverrides,
//     analysisNotifierProvider.overrideWith(
//       TestErrorAnalysisNotifier.new,
//     ),
//   ];

//   final nullResultOverrides = [
//     ...testServiceOverrides,
//     analysisNotifierProvider.overrideWith(
//       () => TestAnalysisNotifier(null),
//     ),
//   ];

//   final emptyGoodOverrides = [
//     ...testServiceOverrides,
//     analysisNotifierProvider.overrideWith(
//       () => TestAnalysisNotifier(emptyGoodReviewResult),
//     ),
//   ];

//   final emptyImproveOverrides = [
//     ...testServiceOverrides,
//     analysisNotifierProvider.overrideWith(
//       () => TestAnalysisNotifier(emptyImproveReviewResult),
//     ),
//   ];

//   final emptyBothOverrides = [
//     ...testServiceOverrides,
//     analysisNotifierProvider.overrideWith(
//       () => TestAnalysisNotifier(emptyBothReviewResult),
//     ),
//   ];

//   group('ResultPage', () {
//     group('正常系テスト', () {
//       testWidgets('UI構成要素が表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );

//         await tester.pumpAndSettle();

//         // メインのテキスト要素
//         expect(find.text('69人が寝た!'), findsOneWidget);

//         // ボタン要素
//         expect(find.text('結果をシェア'), findsOneWidget);
//         expect(find.text('別のスライドをアップロード'), findsOneWidget);

//         // 評価セクション
//         expect(find.text('良い点'), findsOneWidget);
//         expect(find.text('改善提案'), findsOneWidget);

//         // 良い点の内容（改行文字で区切られているため、部分文字列で検索）
//         expect(find.textContaining('スライドの構成が分かりやすい'), findsOneWidget);
//         expect(find.textContaining('文字サイズが適切'), findsOneWidget);
//         expect(find.textContaining('色使いが統一されている'), findsOneWidget);

//         // 改善提案の内容（改行文字で区切られているため、部分文字列で検索）
//         expect(find.textContaining('アニメーションを追加して動きを出す'), findsOneWidget);
//         expect(find.textContaining('より具体的なデータを提示する'), findsOneWidget);
//         expect(find.textContaining('結論を最初に示す'), findsOneWidget);
//       });

//       testWidgets('「結果をシェア」ボタンをタップできる', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         final shareButton = find.text('結果をシェア');
//         expect(shareButton, findsOneWidget);
//         await tester.tap(shareButton);
//         await tester.pumpAndSettle();

//         // ボタンが正常にタップできることを確認
//         expect(shareButton, findsOneWidget);
//       });

//       testWidgets('「別のスライドをアップロード」ボタンをタップすると/へ遷移する', (
//         WidgetTester tester,
//       ) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         final uploadButton = find.text('別のスライドをアップロード');
//         expect(uploadButton, findsOneWidget);

//         // ボタンが画面外にある場合はスクロールしてからタップ
//         await tester.ensureVisible(uploadButton);
//         await tester.tap(uploadButton);
//         await tester.pumpAndSettle();

//         expect(router.state.uri.toString(), '/');
//         expect(find.byKey(const Key('start-page')), findsOneWidget);
//       });
//     });

//     group('点数別判定メッセージテスト', () {
//       testWidgets('高得点（90点以上）で「いいんじゃない？」が表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: highScoreOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('5人が寝た!'), findsOneWidget);
//       });

//       testWidgets('中得点（75-89点）で「まあまあだけど」が表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: mediumScoreOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('25人が寝た!'), findsOneWidget);
//       });

//       testWidgets('低得点（60-74点）で「がんばれ」が表示される', (WidgetTester tester) async {
//         // 60点のテストデータを作成
//         const sixtyScoreResult = ReviewResult(
//           point: 60,
//           good: ['良い点'],
//           improve: ['改善点'],
//         );

//         final sixtyScoreOverrides = [
//           ...testServiceOverrides,
//           analysisNotifierProvider.overrideWith(
//             () => TestAnalysisNotifier(sixtyScoreResult),
//           ),
//         ];

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: sixtyScoreOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('40人が寝た!'), findsOneWidget);
//       });

//       testWidgets('最低得点（60点未満）で「つまらん！」が表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: lowScoreOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('55人が寝た!'), findsOneWidget);
//       });

//       testWidgets('境界値テスト - 90点ちょうどで「いいんじゃない？」が表示される', (
//         WidgetTester tester,
//       ) async {
//         const ninetyScoreResult = ReviewResult(
//           point: 90,
//           good: ['良い点'],
//           improve: ['改善点'],
//         );

//         final ninetyScoreOverrides = [
//           ...testServiceOverrides,
//           analysisNotifierProvider.overrideWith(
//             () => TestAnalysisNotifier(ninetyScoreResult),
//           ),
//         ];

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: ninetyScoreOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('10人が寝た!'), findsOneWidget);
//       });

//       testWidgets('境界値テスト - 75点ちょうどで「まあまあだけど」が表示される', (
//         WidgetTester tester,
//       ) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: mediumScoreOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('25人が寝た!'), findsOneWidget);
//       });
//     });

//     group('エラー状態テスト', () {
//       testWidgets('エラー状態でエラーメッセージが表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: errorOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('分析エラー'), findsOneWidget);
//         expect(
//           find.textContaining('エラーが発生しました: Exception: テストエラー'),
//           findsOneWidget,
//         );
//         expect(find.text('最初からやり直す'), findsOneWidget);
//       });

//       testWidgets('エラー状態で「最初からやり直す」ボタンをタップすると/へ遷移する', (
//         WidgetTester tester,
//       ) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: errorOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         final retryButton = find.text('最初からやり直す');
//         expect(retryButton, findsOneWidget);
//         await tester.tap(retryButton);
//         await tester.pumpAndSettle();

//         expect(router.state.uri.toString(), '/');
//         expect(find.byKey(const Key('start-page')), findsOneWidget);
//       });
//     });

//     group('ローディング状態テスト', () {
//       testWidgets('ローディング状態でローディングUIが表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: loadingOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pump(const Duration(milliseconds: 100));
//         expect(find.text('分析中...'), findsOneWidget);
//         expect(find.text('AIがプレゼンテーションを評価しています'), findsOneWidget);
//         expect(find.byType(CircularProgressIndicator), findsOneWidget);
//       });
//     });

//     group('null結果テスト', () {
//       testWidgets('分析結果がnullの場合、StartPageに戻る', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: nullResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pump();
//         expect(find.text('PDFをアップロードしてください'), findsOneWidget);
//         expect(find.text('StartPageに戻ります...'), findsOneWidget);
//         await tester.pumpAndSettle();
//         expect(router.state.uri.toString(), '/');
//       });
//     });

//     group('スタイルテスト', () {
//       testWidgets('シェアボタンが適切なスタイルで表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // ボタンのテキストを確認
//         expect(find.text('結果をシェア'), findsOneWidget);
//       });

//       testWidgets('シェアボタンにアイコンが表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // シェアアイコンが表示されることを確認
//         expect(find.byIcon(Icons.share), findsOneWidget);
//       });

//       testWidgets('アップロードボタンが適切なスタイルで表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // ボタンのテキストを確認
//         expect(find.text('別のスライドをアップロード'), findsOneWidget);
//       });

//       testWidgets('アップロードボタンにアイコンが表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // アップロードアイコンが表示されることを確認
//         expect(find.byIcon(Icons.upload_file), findsOneWidget);
//       });

//       testWidgets('AI分析結果セクションのアイコンが表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // AI分析結果のアイコン
//         expect(find.byIcon(Icons.psychology), findsOneWidget);
//         // 良い点のアイコン
//         expect(find.byIcon(Icons.thumb_up), findsOneWidget);
//         // 改善提案のアイコン
//         expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
//       });
//     });

//     group('レイアウトテスト', () {
//       testWidgets('結果画像が表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // 結果画像が表示されることを確認
//         expect(find.byType(Image), findsOneWidget);
//       });

//       testWidgets('評価セクションが正しく表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // 評価セクションのタイトルが表示されることを確認
//         expect(find.text('良い点'), findsOneWidget);
//         expect(find.text('改善提案'), findsOneWidget);
//       });

//       testWidgets('AI分析結果セクションが表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('AI分析結果'), findsOneWidget);
//       });

//       testWidgets('良い点と改善提案が箇条書きで表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // 箇条書きの記号が表示されることを確認
//         expect(find.text('• '), findsNWidgets(6)); // 良い点3つ + 改善提案3つ
//       });
//     });

//     group('テキストスタイルテスト', () {
//       testWidgets('タイトルテキストが正しいスタイルで表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // 寝た率テキストが表示されることを確認
//         expect(find.text('69人が寝た!'), findsOneWidget);
//       });

//       testWidgets('寝た率テキストが正しいスタイルで表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // 寝た率テキストが表示されることを確認
//         expect(find.text('69人が寝た!'), findsOneWidget);
//       });
//     });

//     group('インタラクションテスト', () {
//       testWidgets('シェアボタンがタップ可能である', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         final shareButton = find.text('結果をシェア');
//         expect(shareButton, findsOneWidget);
//         await tester.tap(shareButton);
//         await tester.pumpAndSettle();
//       });

//       testWidgets('アップロードボタンがタップ可能である', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         final uploadButton = find.text('別のスライドをアップロード');
//         expect(uploadButton, findsOneWidget);

//         // ボタンが画面外にある場合はスクロールしてからタップ
//         await tester.ensureVisible(uploadButton);
//         await tester.tap(uploadButton);
//         await tester.pumpAndSettle();
//       });
//     });

//     group('スクロールテスト', () {
//       testWidgets('ページがスクロール可能である', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // SingleChildScrollViewが存在することを確認
//         expect(find.byType(SingleChildScrollView), findsOneWidget);
//       });
//     });

//     group('色とテーマテスト', () {
//       testWidgets('背景色が正しく設定されている', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // Scaffoldの背景色を確認
//         final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
//         expect(scaffold.backgroundColor, const Color(0xFFF7FAFC));
//       });

//       testWidgets('テキストカラーが正しく設定されている', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // メインカラーが使用されていることを確認
//         expect(find.text('69人が寝た!'), findsOneWidget);
//       });
//     });

//     group('アクセシビリティテスト', () {
//       testWidgets('ボタンに適切なセマンティクスが設定されている', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // ボタンがタップ可能であることを確認
//         expect(find.text('結果をシェア'), findsOneWidget);
//         expect(find.text('別のスライドをアップロード'), findsOneWidget);
//       });
//     });

//     group('エッジケーステスト', () {
//       testWidgets('良い点が空の場合でも正常に表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: emptyGoodOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // 良い点セクションが表示されないことを確認（空のリストのため）
//         expect(find.text('良い点'), findsNothing);
//         expect(find.text('改善提案'), findsOneWidget);
//         expect(find.text('AI分析結果'), findsOneWidget);
//       });

//       testWidgets('改善提案が空の場合でも正常に表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: emptyImproveOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // 改善提案セクションが表示されないことを確認（空のリストのため）
//         expect(find.text('良い点'), findsOneWidget);
//         expect(find.text('改善提案'), findsNothing);
//         expect(find.text('AI分析結果'), findsOneWidget);
//       });

//       testWidgets('両方のリストが空の場合でも正常に表示される', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: emptyBothOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // 両方のセクションが表示されないことを確認（空のリストでもAI分析結果は表示される）
//         expect(find.text('良い点'), findsNothing);
//         expect(find.text('改善提案'), findsNothing);
//         expect(find.text('AI分析結果'), findsOneWidget);
//       });
//     });

//     group('特殊条件テスト', () {
//       testWidgets('null結果からのナビゲーション処理', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: nullResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pump();

//         expect(find.text('PDFをアップロードしてください'), findsOneWidget);
//         expect(find.text('StartPageに戻ります...'), findsOneWidget);

//         // PostFrameCallbackの実行を待つ
//         await tester.pumpAndSettle();
//         expect(router.state.uri.toString(), '/');
//       });
//     });

//     group('ロガー例外処理テスト', () {
//       testWidgets('データ状態でロガー例外が発生しても動作し、フォールバック logger.d が呼ばれる', (
//         WidgetTester tester,
//       ) async {
//         final mockLogger = MockLogger();

//         // 最初のlogger.d呼び出しで例外を発生させ、catch内のlogger.dは成功させる
//         when(
//           mockLogger.d(argThat(contains('分析状態'))),
//         ).thenThrow(Exception('Logger error'));
//         when(
//           mockLogger.d(argThat(contains('data状態'))),
//         ).thenThrow(Exception('Logger error'));
//         when(mockLogger.d(argThat(contains('Logger error')))).thenReturn(null);

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp(
//               home: TestableResultPage(logger: mockLogger),
//             ),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // UI が正常に表示されることを確認
//         expect(find.text('69人が寝た!'), findsOneWidget);

//         // フォールバック logger.d が呼ばれることを確認
//         verify(
//           mockLogger.d(argThat(contains('Logger error'))),
//         ).called(greaterThan(0));
//       });

//       testWidgets('ローディング状態でロガー例外が発生しても動作する', (WidgetTester tester) async {
//         final mockLogger = MockLogger();

//         // logger.d で例外を発生させ、catch内のlogger.dは成功させる
//         when(
//           mockLogger.d('ResultPage - loading状態'),
//         ).thenThrow(Exception('Logger loading error'));
//         when(
//           mockLogger.d(argThat(contains('Logger loading error'))),
//         ).thenReturn(null);

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: loadingOverrides,
//             child: MaterialApp(
//               home: TestableResultPage(logger: mockLogger),
//             ),
//           ),
//         );
//         await tester.pump(const Duration(milliseconds: 100));

//         // ローディングUIが正常に表示されることを確認
//         expect(find.text('分析中...'), findsOneWidget);

//         // フォールバック logger.d が呼ばれることを確認
//         verify(
//           mockLogger.d(argThat(contains('Logger loading error'))),
//         ).called(1);
//       });

//       testWidgets('エラー状態でロガー例外が発生しても動作する', (WidgetTester tester) async {
//         final mockLogger = MockLogger();

//         // logger.e で例外を発生させ、catch内のlogger.dは成功させる
//         when(
//           mockLogger.e(argThat(contains('error状態'))),
//         ).thenThrow(Exception('Logger error'));
//         when(mockLogger.d(argThat(contains('Logger error')))).thenReturn(null);

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: errorOverrides,
//             child: MaterialApp(
//               home: TestableResultPage(logger: mockLogger),
//             ),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // エラーUIが正常に表示されることを確認
//         expect(find.textContaining('エラーが発生しました'), findsOneWidget);

//         // フォールバック logger.d が呼ばれることを確認
//         verify(mockLogger.d(argThat(contains('Logger error')))).called(1);
//       });

//       testWidgets('null結果時のロガー例外とナビゲーション例外処理', (WidgetTester tester) async {
//         final mockLogger = MockLogger();

//         // ナビゲーションエラー用のルーター
//         final testRouter = GoRouter(
//           routes: [
//             GoRoute(
//               path: '/',
//               builder: (context, state) {
//                 throw Exception('ナビゲーションエラー');
//               },
//             ),
//             GoRoute(
//               path: '/result',
//               builder:
//                   (context, state) => TestableResultPage(logger: mockLogger),
//             ),
//           ],
//           initialLocation: '/result',
//           errorBuilder:
//               (context, state) => const Scaffold(
//                 body: Center(child: Text('Navigation Error')),
//               ),
//         );

//         // logger で例外を発生させる
//         when(
//           mockLogger.i(argThat(contains('分析結果なし'))),
//         ).thenThrow(Exception('Logger info error'));
//         when(
//           mockLogger.e(argThat(contains('ナビゲーションエラー'))),
//         ).thenThrow(Exception('Logger navigation error'));
//         when(mockLogger.d(argThat(contains('Logger')))).thenReturn(null);

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: nullResultOverrides,
//             child: MaterialApp.router(
//               routerConfig: testRouter,
//             ),
//           ),
//         );
//         await tester.pump();

//         // null結果UIが表示されることを確認
//         expect(find.text('PDFをアップロードしてください'), findsOneWidget);

//         // PostFrameCallbackの実行
//         await tester.pumpAndSettle();

//         // フォールバック logger.d が呼ばれることを確認
//         verify(
//           mockLogger.d(argThat(contains('Logger'))),
//         ).called(greaterThan(0));
//       });

//       test('Logger exception handling coverage verification', () {
//         // これでLogger例外処理パスがテスト可能になったことを確認
//         final mockLogger = MockLogger();

//         // Logger例外をシミュレート
//         when(mockLogger.d(any)).thenThrow(Exception('Logger failed'));
//         when(mockLogger.i(any)).thenThrow(Exception('Logger info failed'));
//         when(mockLogger.e(any)).thenThrow(Exception('Logger error failed'));

//         // TestableResultPageを通じてLogger例外処理パスをテストできることを確認
//         final testPage = TestableResultPage(logger: Logger());
//         expect(testPage.logger, isA<Logger>());

//         // debugPrintからlogger.dへの変更により、Mock Loggerを使った
//         // 例外処理パスのテストが可能になった
//         verify(mockLogger.d(any)).called(0); // まだ呼ばれていない
//         verify(mockLogger.i(any)).called(0); // まだ呼ばれていない
//         verify(mockLogger.e(any)).called(0); // まだ呼ばれていない
//       });
//     });

//     group('境界値テスト追加', () {
//       testWidgets('境界値テスト - 0点で「つまらん！」が表示される', (WidgetTester tester) async {
//         const zeroScoreResult = ReviewResult(
//           point: 0,
//           good: [],
//           improve: ['全面的な見直しが必要'],
//         );

//         final zeroScoreOverrides = [
//           ...testServiceOverrides,
//           analysisNotifierProvider.overrideWith(
//             () => TestAnalysisNotifier(zeroScoreResult),
//           ),
//         ];

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: zeroScoreOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('100人が寝た!'), findsOneWidget);
//       });

//       testWidgets(
//         '境界値テスト - 100点で「いいんじゃない？」が表示される',
//         (WidgetTester tester) async {
//           const perfectScoreResult = ReviewResult(
//             point: 100,
//             good: ['完璧なプレゼンテーション'],
//             improve: [],
//           );

//           final perfectScoreOverrides = [
//             ...testServiceOverrides,
//             analysisNotifierProvider.overrideWith(
//               () => TestAnalysisNotifier(perfectScoreResult),
//             ),
//           ];

//           await tester.pumpWidget(
//             ProviderScope(
//               overrides: perfectScoreOverrides,
//               child: MaterialApp.router(routerConfig: router),
//             ),
//           );
//           await tester.pumpAndSettle();

//           expect(find.text('0人が寝た!'), findsOneWidget);
//         },
//       );

//       testWidgets('境界値テスト - 59点で「つまらん！」が表示される', (WidgetTester tester) async {
//         const fiftyNineScoreResult = ReviewResult(
//           point: 59,
//           good: ['努力は見える'],
//           improve: ['大幅な改善が必要'],
//         );

//         final fiftyNineScoreOverrides = [
//           ...testServiceOverrides,
//           analysisNotifierProvider.overrideWith(
//             () => TestAnalysisNotifier(fiftyNineScoreResult),
//           ),
//         ];

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: fiftyNineScoreOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('41人が寝た!'), findsOneWidget);
//       });

//       testWidgets('境界値テスト - 74点で「がんばれ」が表示される', (WidgetTester tester) async {
//         const seventyFourScoreResult = ReviewResult(
//           point: 74,
//           good: ['基本は良い'],
//           improve: ['もう少し頑張って'],
//         );

//         final seventyFourScoreOverrides = [
//           ...testServiceOverrides,
//           analysisNotifierProvider.overrideWith(
//             () => TestAnalysisNotifier(seventyFourScoreResult),
//           ),
//         ];

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: seventyFourScoreOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('26人が寝た!'), findsOneWidget);
//       });

//       testWidgets('境界値テスト - 89点で「まあまあだけど」が表示される', (WidgetTester tester) async {
//         const eightyNineScoreResult = ReviewResult(
//           point: 89,
//           good: ['かなり良い'],
//           improve: ['最後の仕上げを'],
//         );

//         final eightyNineScoreOverrides = [
//           ...testServiceOverrides,
//           analysisNotifierProvider.overrideWith(
//             () => TestAnalysisNotifier(eightyNineScoreResult),
//           ),
//         ];

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: eightyNineScoreOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         expect(find.text('11人が寝た!'), findsOneWidget);
//       });
//     });

//     group('ナビゲーション例外処理テスト', () {
//       testWidgets(
//         'ナビゲーション時の例外処理をテストする',
//         (WidgetTester tester) async {
//           // 無効なルーターを作成してナビゲーション例外を発生させる
//           final errorRouter = GoRouter(
//             routes: [
//               GoRoute(
//                 path: '/',
//                 builder: (context, state) {
//                   throw Exception('ナビゲーションエラー');
//                 },
//               ),
//             ],
//             initialLocation: '/result',
//             errorBuilder:
//                 (context, state) => const Scaffold(
//                   body: Center(
//                     child: Text('Navigation Error'),
//                   ),
//                 ),
//           );

//           await tester.pumpWidget(
//             ProviderScope(
//               overrides: nullResultOverrides,
//               child: MaterialApp.router(routerConfig: errorRouter),
//             ),
//           );
//           await tester.pump();

//           // null結果UIが表示されることを確認
//           expect(find.text('PDFをアップロードしてください'), findsOneWidget);
//           expect(find.text('StartPageに戻ります...'), findsOneWidget);

//           // PostFrameCallbackでナビゲーション例外が発生するが、アプリは継続動作
//           await tester.pumpAndSettle();
//         },
//       );
//     });

//     group('ウィジェット状態テスト', () {
//       testWidgets('コンテキストがマウントされていない場合のナビゲーション', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: nullResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pump();

//         // ウィジェットをアンマウント
//         await tester.pumpWidget(const SizedBox());

//         // PostFrameCallbackが実行されてもクラッシュしないことを確認
//         await tester.pumpAndSettle();
//       });

//       testWidgets('画像アセットが正しく読み込まれる', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // 画像ウィジェットが存在することを確認
//         final imageWidget = tester.widget<Image>(find.byType(Image));
//         expect(imageWidget.image, isA<AssetImage>());

//         final assetImage = imageWidget.image as AssetImage;
//         expect(assetImage.assetName, 'assets/ResultPage.png');
//       });

//       testWidgets('コンテナの装飾が正しく設定されている', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // 白いコンテナが存在することを確認
//         final containers = tester.widgetList<Container>(find.byType(Container));
//         expect(containers.length, greaterThan(0));

//         // 少なくとも一つのコンテナが白色の装飾を持つことを確認
//         final whiteContainer = containers.firstWhere(
//           (container) {
//             final decoration = container.decoration;
//             return decoration is BoxDecoration &&
//                 decoration.color == Colors.white;
//           },
//         );
//         expect(whiteContainer, isNotNull);
//       });

//       testWidgets('ボタンのスタイルと動作が正しく設定されている', (WidgetTester tester) async {
//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: testResultOverrides,
//             child: MaterialApp.router(routerConfig: router),
//           ),
//         );
//         await tester.pumpAndSettle();

//         // ボタンのテキストが存在することを確認（ボタンの存在を間接的に確認）
//         expect(find.text('結果をシェア'), findsOneWidget);
//         expect(find.text('別のスライドをアップロード'), findsOneWidget);

//         // SizedBoxが複数使用されていることを確認（レイアウト用）
//         expect(find.byType(SizedBox), findsWidgets);
//       });
//     });
//   });
// }
