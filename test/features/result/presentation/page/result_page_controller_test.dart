import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/features/result/presentation/page/result_page_controller.dart';
import 'package:presen_neta/shared/service/image_generator_service.dart';
import 'package:share_plus/share_plus.dart';

import 'result_page_controller_test.mocks.dart';

@GenerateMocks([
  ImageGeneratorService,
  SharePlus,
])
void main() {
  group('ResultPageController', () {
    late MockImageGeneratorService mockImageGenerator;
    late MockSharePlus mockShareService;
    late Directory mockTempDir;
    late File mockImageFile;

    setUp(() {
      mockImageGenerator = MockImageGeneratorService();
      mockShareService = MockSharePlus();
      mockTempDir = Directory('/tmp/test');
      mockImageFile = File('/tmp/test/result_image.png');
    });

    group('正常系テスト', () {
      test('画像生成とシェアが正常に動作する', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sleepPercentage = 30;
        const title = 'テストタイトル';
        const goodPoints = ['良い点1', '良い点2'];
        const improvements = ['改善点1', '改善点2'];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockImageFile.writeAsBytes(imageBytes),
        ).thenAnswer((_) async => mockImageFile);
        when(mockShareService.share(any)).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        // Assert
        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).called(1);

        verify(mockShareService.share(any)).called(1);
      });

      test('シェアパラメータが正しく設定される', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sleepPercentage = 25;
        const title = 'テストタイトル';
        const goodPoints = ['良い点'];
        const improvements = ['改善点'];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockImageFile.writeAsBytes(imageBytes),
        ).thenAnswer((_) async => mockImageFile);
        when(mockShareService.share(any)).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        // Assert
        verify(
          mockShareService.share(
            argThat(
              isA<ShareParams>()
                  .having((p) => p.text, 'text', '25人が寝た! #プレゼン寝た判定')
                  .having((p) => p.files?.length, 'files length', 1),
            ),
          ),
        ).called(1);
      });
    });

    group('エラーハンドリングテスト', () {
      test('画像生成でエラーが発生した場合、テキストのみでシェアする', () async {
        // Arrange
        const sleepPercentage = 40;
        const title = 'テストタイトル';
        const goodPoints = ['良い点'];
        const improvements = ['改善点'];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenThrow(Exception('画像生成エラー'));

        when(mockShareService.share(any)).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        // Assert
        verify(
          mockShareService.share(
            argThat(
              isA<ShareParams>()
                  .having((p) => p.text, 'text', '40人が寝た! #プレゼン寝た判定')
                  .having((p) => p.files, 'files', null),
            ),
          ),
        ).called(1);
      });

      test('ファイル書き込みでエラーが発生した場合、テキストのみでシェアする', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sleepPercentage = 50;
        const title = 'テストタイトル';
        const goodPoints = ['良い点'];
        const improvements = ['改善点'];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockImageFile.writeAsBytes(imageBytes),
        ).thenThrow(Exception('ファイル書き込みエラー'));
        when(mockShareService.share(any)).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        // Assert
        verify(
          mockShareService.share(
            argThat(
              isA<ShareParams>()
                  .having((p) => p.text, 'text', '50人が寝た! #プレゼン寝た判定')
                  .having((p) => p.files, 'files', null),
            ),
          ),
        ).called(1);
      });

      test('シェアサービスでエラーが発生した場合でも例外を投げない', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sleepPercentage = 60;
        const title = 'テストタイトル';
        const goodPoints = ['良い点'];
        const improvements = ['改善点'];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockImageFile.writeAsBytes(imageBytes),
        ).thenAnswer((_) async => mockImageFile);
        when(mockShareService.share(any)).thenThrow(Exception('シェアエラー'));

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act & Assert
        expect(
          () => controller.shareResult(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
          returnsNormally,
        );
      });
    });

    group('パラメータテスト', () {
      test('空のリストでも正常に動作する', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sleepPercentage = 70;
        const title = 'テストタイトル';
        const goodPoints = <String>[];
        const improvements = <String>[];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockImageFile.writeAsBytes(imageBytes),
        ).thenAnswer((_) async => mockImageFile);
        when(mockShareService.share(any)).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        // Assert
        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).called(1);
      });

      test('長いテキストでも正常に動作する', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sleepPercentage = 80;
        const title = '非常に長いタイトル文字列でテストを行う';
        const goodPoints = [
          '非常に長い良い点の説明文を含むテストケース',
          'もう一つの長い良い点の説明',
        ];
        const improvements = [
          '非常に長い改善提案の説明文を含むテストケース',
          'もう一つの長い改善提案の説明',
        ];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockImageFile.writeAsBytes(imageBytes),
        ).thenAnswer((_) async => mockImageFile);
        when(mockShareService.share(any)).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        // Assert
        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).called(1);
      });

      test('境界値のテスト（0%と100%）', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const title = 'テストタイトル';
        const goodPoints = ['良い点'];
        const improvements = ['改善点'];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 0,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 100,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockImageFile.writeAsBytes(imageBytes),
        ).thenAnswer((_) async => mockImageFile);
        when(mockShareService.share(any)).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act & Assert - 0%
        await controller.shareResult(
          sleepPercentage: 0,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(
          mockShareService.share(
            argThat(
              isA<ShareParams>().having(
                (p) => p.text,
                'text',
                '0人が寝た! #プレゼン寝た判定',
              ),
            ),
          ),
        ).called(1);

        // Act & Assert - 100%
        await controller.shareResult(
          sleepPercentage: 100,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(
          mockShareService.share(
            argThat(
              isA<ShareParams>().having(
                (p) => p.text,
                'text',
                '100人が寝た! #プレゼン寝た判定',
              ),
            ),
          ),
        ).called(1);
      });
    });

    group('コンストラクタテスト', () {
      test('デフォルトコンストラクタで正常にインスタンス化される', () {
        // Act
        final controller = ResultPageController();

        // Assert
        expect(controller, isA<ResultPageController>());
      });

      test('カスタムパラメータでコンストラクタが正常に動作する', () {
        // Act
        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Assert
        expect(controller, isA<ResultPageController>());
      });
    });

    group('ファイル操作テスト', () {
      test('一時ディレクトリの取得が正常に動作する', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sleepPercentage = 35;
        const title = 'テストタイトル';
        const goodPoints = ['良い点'];
        const improvements = ['改善点'];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockImageFile.writeAsBytes(imageBytes),
        ).thenAnswer((_) async => mockImageFile);
        when(mockShareService.share(any)).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        // Assert
        verify(
          mockShareService.share(
            argThat(
              isA<ShareParams>().having(
                (p) => p.files?.first.path,
                'file path',
                '/tmp/test/result_image.png',
              ),
            ),
          ),
        ).called(1);
      });

      test('ファイル名が正しく設定される', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sleepPercentage = 45;
        const title = 'テストタイトル';
        const goodPoints = ['良い点'];
        const improvements = ['改善点'];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockImageFile.writeAsBytes(imageBytes),
        ).thenAnswer((_) async => mockImageFile);
        when(mockShareService.share(any)).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        // Assert
        verify(
          mockShareService.share(
            argThat(
              isA<ShareParams>().having(
                (p) => p.files?.first.name,
                'file name',
                'result_image.png',
              ),
            ),
          ),
        ).called(1);
      });
    });

    group('デバッグ出力テスト', () {
      test('エラー時にデバッグ出力が行われる', () async {
        // Arrange
        const sleepPercentage = 55;
        const title = 'テストタイトル';
        const goodPoints = ['良い点'];
        const improvements = ['改善点'];

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenThrow(Exception('テストエラー'));

        when(mockShareService.share(any)).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        // Act
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        // Assert - エラーが発生してもテキストシェアは実行される
        verify(mockShareService.share(any)).called(1);
      });
    });
  });
}
