import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/features/result/presentation/page/result_page_controller.dart';
import 'package:presen_neta/shared/service/image_generator_service.dart';
import 'package:share_plus/share_plus.dart';
import 'result_page_controller_test.mocks.dart';

@GenerateMocks([ImageGeneratorService, SharePlus, Directory, File])
void main() {
  group('ResultPageController', () {
    late MockImageGeneratorService mockImageGenerator;
    late MockSharePlus mockShareService;
    late MockDirectory mockTempDir;

    setUp(() {
      mockImageGenerator = MockImageGeneratorService();
      mockShareService = MockSharePlus();
      mockTempDir = MockDirectory();
    });

    test('デフォルトコンストラクタで正常にインスタンス化される', () {
      final controller = ResultPageController();
      expect(controller, isA<ResultPageController>());
    });

    test('カスタムサービスでインスタンス化される', () {
      final controller = ResultPageController(
        imageGenerator: mockImageGenerator,
        shareService: mockShareService,
        getTempDir: () async => mockTempDir,
      );

      expect(controller, isA<ResultPageController>());
    });

    group('shareResult', () {
      const sleepPercentage = 60;
      const title = 'Test Presentation';
      const goodPoints = ['Good point 1', 'Good point 2'];
      const improvements = ['Improvement 1', 'Improvement 2'];

      test('画像生成が成功した場合に画像付きでシェアする', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        const tempDirPath = 'assets';

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(mockTempDir.path).thenReturn(tempDirPath);
        when(
          mockShareService.share(any),
        ).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

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

      test('画像生成が失敗した場合にテキストのみでシェアする', () async {
        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: anyNamed('sleepPercentage'),
            title: anyNamed('title'),
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).thenThrow(Exception('Image generation failed'));

        when(
          mockShareService.share(any),
        ).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

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

      test('空のリストを処理する', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        const tempDirPath = 'assets';

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: [],
            improvements: [],
          ),
        ).thenAnswer((_) async => imageBytes);

        when(mockTempDir.path).thenReturn(tempDirPath);
        when(
          mockShareService.share(any),
        ).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: [],
          improvements: [],
        );

        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: [],
            improvements: [],
          ),
        ).called(1);
      });

      test('睡眠パーセンテージが0の場合を処理する', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        const tempDirPath = 'assets';

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 0,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(mockTempDir.path).thenReturn(tempDirPath);
        when(
          mockShareService.share(any),
        ).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        await controller.shareResult(
          sleepPercentage: 0,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 0,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).called(1);
      });

      test('ディレクトリアクセスエラーを処理する', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () => throw Exception('Directory access failed'),
        );

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: anyNamed('sleepPercentage'),
            title: anyNamed('title'),
            goodPoints: anyNamed('goodPoints'),
            improvements: anyNamed('improvements'),
          ),
        ).thenAnswer((_) async => imageBytes);

        when(
          mockShareService.share(any),
        ).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(mockShareService.share(any)).called(1);
      });

      test('シェアサービスの失敗を適切に処理する', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        const tempDirPath = 'assets';

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(mockTempDir.path).thenReturn(tempDirPath);

        // Share サービスの呼び出しをカウントするためのカウンター
        var shareCallCount = 0;
        when(mockShareService.share(any)).thenAnswer((_) async {
          shareCallCount++;
          if (shareCallCount == 1) {
            throw Exception('Share failed');
          }
          return const ShareResult('', ShareResultStatus.success);
        });

        // 例外が発生しないことを確認
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        // Share サービスが2回呼ばれることを確認（1回目は失敗、2回目は成功）
        verify(mockShareService.share(any)).called(2);
      });

      test('睡眠パーセンテージが100の場合を処理する', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        const tempDirPath = 'assets';

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 100,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(mockTempDir.path).thenReturn(tempDirPath);
        when(
          mockShareService.share(any),
        ).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        await controller.shareResult(
          sleepPercentage: 100,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: 100,
            title: title,
            goodPoints: goodPoints,
            improvements: improvements,
          ),
        ).called(1);
      });

      test('長いタイトルとリストを処理する', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        const tempDirPath = 'assets';
        final longTitle = 'A' * 1000; // 非常に長いタイトル
        final longGoodPoints = List.generate(100, (i) => 'Good point $i');
        final longImprovements = List.generate(100, (i) => 'Improvement $i');

        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );

        when(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: longTitle,
            goodPoints: longGoodPoints,
            improvements: longImprovements,
          ),
        ).thenAnswer((_) async => imageBytes);

        when(mockTempDir.path).thenReturn(tempDirPath);
        when(
          mockShareService.share(any),
        ).thenAnswer(
          (_) async => const ShareResult('', ShareResultStatus.success),
        );

        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: longTitle,
          goodPoints: longGoodPoints,
          improvements: longImprovements,
        );

        verify(
          mockImageGenerator.generateResultImage(
            sleepPercentage: sleepPercentage,
            title: longTitle,
            goodPoints: longGoodPoints,
            improvements: longImprovements,
          ),
        ).called(1);
      });
    });
  });
}
