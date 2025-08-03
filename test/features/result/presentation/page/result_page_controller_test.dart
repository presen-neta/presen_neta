import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/features/result/presentation/page/result_page_controller.dart';
import 'package:presen_neta/shared/service/image_generator_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/platform_interface/share_plus_platform.dart';

import 'result_page_controller_test.mocks.dart';

@GenerateMocks([ImageGeneratorService, SharePlus, Directory])
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

    test('should create with custom services when provided', () {
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

      test('should share with image when image generation succeeds', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final tempDirPath = '/tmp/test';
        
        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );
        
        when(mockImageGenerator.generateResultImage(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        )).thenAnswer((_) async => imageBytes);
        
        when(mockTempDir.path).thenReturn(tempDirPath);
        when(mockShareService.share(any)).thenAnswer((_) async => ShareResult('', ShareResultStatus.success));

        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(mockImageGenerator.generateResultImage(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        )).called(1);

        verify(mockShareService.share(any)).called(1);
      });

      test('should share text only when image generation fails', () async {
        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );
        
        when(mockImageGenerator.generateResultImage(
          sleepPercentage: any,
          title: any,
          goodPoints: any,
          improvements: any,
        )).thenThrow(Exception('Image generation failed'));
        
        when(mockShareService.share(any)).thenAnswer((_) async => ShareResult('', ShareResultStatus.success));

        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(mockImageGenerator.generateResultImage(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        )).called(1);

        verify(mockShareService.share(any)).called(1);
      });

      test('should handle empty lists', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final tempDirPath = '/tmp/test';
        
        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );
        
        when(mockImageGenerator.generateResultImage(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: [],
          improvements: [],
        )).thenAnswer((_) async => imageBytes);
        
        when(mockTempDir.path).thenReturn(tempDirPath);
        when(mockShareService.share(any)).thenAnswer((_) async => ShareResult('', ShareResultStatus.success));

        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: [],
          improvements: [],
        );

        verify(mockImageGenerator.generateResultImage(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: [],
          improvements: [],
        )).called(1);
      });

      test('should handle zero sleep percentage', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final tempDirPath = '/tmp/test';
        
        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );
        
        when(mockImageGenerator.generateResultImage(
          sleepPercentage: 0,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        )).thenAnswer((_) async => imageBytes);
        
        when(mockTempDir.path).thenReturn(tempDirPath);
        when(mockShareService.share(any)).thenAnswer((_) async => ShareResult('', ShareResultStatus.success));

        await controller.shareResult(
          sleepPercentage: 0,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(mockImageGenerator.generateResultImage(
          sleepPercentage: 0,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        )).called(1);
      });

      test('should handle directory access error', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        
        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () => throw Exception('Directory access failed'),
        );
        
        when(mockImageGenerator.generateResultImage(
          sleepPercentage: any,
          title: any,
          goodPoints: any,
          improvements: any,
        )).thenAnswer((_) async => imageBytes);
        
        when(mockShareService.share(any)).thenAnswer((_) async => ShareResult('', ShareResultStatus.success));

        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(mockShareService.share(any)).called(1);
      });

      test('should handle share service failure gracefully', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final tempDirPath = '/tmp/test';
        
        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );
        
        when(mockImageGenerator.generateResultImage(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        )).thenAnswer((_) async => imageBytes);
        
        when(mockTempDir.path).thenReturn(tempDirPath);
        when(mockShareService.share(any)).thenThrow(Exception('Share failed'));

        // Should not throw exception
        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(mockShareService.share(any)).called(1);
      });

      test('should handle 100 sleep percentage', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final tempDirPath = '/tmp/test';
        
        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );
        
        when(mockImageGenerator.generateResultImage(
          sleepPercentage: 100,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        )).thenAnswer((_) async => imageBytes);
        
        when(mockTempDir.path).thenReturn(tempDirPath);
        when(mockShareService.share(any)).thenAnswer((_) async => ShareResult('', ShareResultStatus.success));

        await controller.shareResult(
          sleepPercentage: 100,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );

        verify(mockImageGenerator.generateResultImage(
          sleepPercentage: 100,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        )).called(1);
      });

      test('should handle long title and lists', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final tempDirPath = '/tmp/test';
        final longTitle = 'A' * 1000; // Very long title
        final longGoodPoints = List.generate(100, (i) => 'Good point $i');
        final longImprovements = List.generate(100, (i) => 'Improvement $i');
        
        final controller = ResultPageController(
          imageGenerator: mockImageGenerator,
          shareService: mockShareService,
          getTempDir: () async => mockTempDir,
        );
        
        when(mockImageGenerator.generateResultImage(
          sleepPercentage: sleepPercentage,
          title: longTitle,
          goodPoints: longGoodPoints,
          improvements: longImprovements,
        )).thenAnswer((_) async => imageBytes);
        
        when(mockTempDir.path).thenReturn(tempDirPath);
        when(mockShareService.share(any)).thenAnswer((_) async => ShareResult('', ShareResultStatus.success));

        await controller.shareResult(
          sleepPercentage: sleepPercentage,
          title: longTitle,
          goodPoints: longGoodPoints,
          improvements: longImprovements,
        );

        verify(mockImageGenerator.generateResultImage(
          sleepPercentage: sleepPercentage,
          title: longTitle,
          goodPoints: longGoodPoints,
          improvements: longImprovements,
        )).called(1);
      });
    });
  });
}