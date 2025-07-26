import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presen_neta/features/result/presentation/page/result_page_controller.dart';
import 'package:presen_neta/shared/service/image_generator_service.dart';
import 'package:share_plus/share_plus.dart';

import 'result_page_controller_test.mocks.dart';

@GenerateMocks([
  ImageGeneratorService,
  SharePlus,
  Directory,
  File,
])
void main() {
  late ResultPageController controller;
  late MockImageGeneratorService mockImageGenerator;
  late MockSharePlus mockSharePlus;
  late MockDirectory mockDirectory;
  late MockFile mockFile;

  setUp(() {
    mockImageGenerator = MockImageGeneratorService();
    mockSharePlus = MockSharePlus();
    mockDirectory = MockDirectory();
    mockFile = MockFile();

    controller = ResultPageController(
      imageGenerator: mockImageGenerator,
      shareService: mockSharePlus,
      getTempDir: () async => mockDirectory,
    );
  });

  group('ResultPageController', () {
    group('shareResult', () {
      test('正常に画像生成とシェアが実行される', () async {
        // モックの設定
        final testImageBytes = Uint8List.fromList([1, 2, 3, 4]);
        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 69,
            title: 'つまらん！',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).thenAnswer((_) async => testImageBytes);

        when(mockDirectory.path).thenReturn('/tmp');
        when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);

        when(mockSharePlus.share(any)).thenAnswer(
          (_) async => const ShareResult(
            '',
            ShareResultStatus.success,
          ),
        );

        // テスト実行
        await controller.shareResult(
          sleepPercentage: 69,
          title: 'つまらん！',
          goodPoints: [
            'スライドの構成が分かりやすい',
            '文字サイズが適切',
            '色使いが統一されている',
          ],
          improvements: [
            'アニメーションを追加して動きを出す',
            'より具体的なデータを提示する',
            '結論を最初に示す',
          ],
        );

        // モックが呼ばれたことを確認
        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 69,
            title: 'つまらん！',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).called(1);

        verify(mockSharePlus.share(any)).called(1);
      });

      test('画像生成が失敗した場合、テキストのみでシェアする', () async {
        // モックの設定 - 例外を投げる
        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 69,
            title: 'つまらん！',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).thenThrow(Exception('Test exception'));

        when(mockSharePlus.share(any)).thenAnswer(
          (_) async => const ShareResult(
            '',
            ShareResultStatus.success,
          ),
        );

        // テスト実行
        await controller.shareResult(
          sleepPercentage: 69,
          title: 'つまらん！',
          goodPoints: [
            'スライドの構成が分かりやすい',
            '文字サイズが適切',
            '色使いが統一されている',
          ],
          improvements: [
            'アニメーションを追加して動きを出す',
            'より具体的なデータを提示する',
            '結論を最初に示す',
          ],
        );

        // エラー時のシェアが呼ばれたことを確認
        verify(mockSharePlus.share(any)).called(1);
      });

      test('異なるパラメータで正常に動作する', () async {
        // モックの設定
        final testImageBytes = Uint8List.fromList([1, 2, 3, 4]);
        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 50,
            title: 'まあまあ',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).thenAnswer((_) async => testImageBytes);

        when(mockDirectory.path).thenReturn('/tmp');
        when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);
        when(mockSharePlus.share(any)).thenAnswer(
          (_) async => const ShareResult(
            '',
            ShareResultStatus.success,
          ),
        );

        // テスト実行
        await controller.shareResult(
          sleepPercentage: 50,
          title: 'まあまあ',
          goodPoints: ['良い点1'],
          improvements: ['改善点1'],
        );

        // モックが呼ばれたことを確認
        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 50,
            title: 'まあまあ',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).called(1);
      });

      test('空のリストでも正常に動作する', () async {
        // モックの設定
        final testImageBytes = Uint8List.fromList([1, 2, 3, 4]);
        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 0,
            title: '素晴らしい！',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).thenAnswer((_) async => testImageBytes);

        when(mockDirectory.path).thenReturn('/tmp');
        when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);
        when(mockSharePlus.share(any)).thenAnswer(
          (_) async => const ShareResult(
            '',
            ShareResultStatus.success,
          ),
        );

        // テスト実行
        await controller.shareResult(
          sleepPercentage: 0,
          title: '素晴らしい！',
          goodPoints: [],
          improvements: [],
        );

        // モックが呼ばれたことを確認
        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 0,
            title: '素晴らしい！',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).called(1);
      });

      test('極端な値でも正常に動作する', () async {
        // モックの設定
        final testImageBytes = Uint8List.fromList([1, 2, 3, 4]);
        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 100,
            title: '最悪！',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).thenAnswer((_) async => testImageBytes);

        when(mockDirectory.path).thenReturn('/tmp');
        when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);
        when(mockSharePlus.share(any)).thenAnswer(
          (_) async => const ShareResult(
            '',
            ShareResultStatus.success,
          ),
        );

        // テスト実行
        await controller.shareResult(
          sleepPercentage: 100,
          title: '最悪！',
          goodPoints: ['良い点1', '良い点2', '良い点3'],
          improvements: ['改善点1', '改善点2', '改善点3'],
        );

        // モックが呼ばれたことを確認
        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 100,
            title: '最悪！',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).called(1);
      });

      test('長いテキストでも正常に動作する', () async {
        // モックの設定
        final testImageBytes = Uint8List.fromList([1, 2, 3, 4]);
        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 75,
            title: '非常に長いタイトルでテストしてみる',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).thenAnswer((_) async => testImageBytes);

        when(mockDirectory.path).thenReturn('/tmp');
        when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);
        when(mockSharePlus.share(any)).thenAnswer(
          (_) async => const ShareResult(
            '',
            ShareResultStatus.success,
          ),
        );

        // テスト実行
        await controller.shareResult(
          sleepPercentage: 75,
          title: '非常に長いタイトルでテストしてみる',
          goodPoints: [
            '非常に長い良い点のテキストをテストしてみる',
            'もう一つの長い良い点のテキスト',
            '三つ目の長い良い点のテキスト',
          ],
          improvements: [
            '非常に長い改善提案のテキストをテストしてみる',
            'もう一つの長い改善提案のテキスト',
            '三つ目の長い改善提案のテキスト',
          ],
        );

        // モックが呼ばれたことを確認
        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 75,
            title: '非常に長いタイトルでテストしてみる',
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).called(1);
      });
    });
  });
}
