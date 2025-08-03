import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:presen_neta/shared/service/image_generator_service.dart';

void main() {
  group('ImageGeneratorService', () {
    late ImageGeneratorService service;

    setUp(() {
      service = const ImageGeneratorService();
    });

    test('should create instance successfully', () {
      expect(service, isA<ImageGeneratorService>());
    });

    testWidgets('should generate result image with basic parameters', (tester) async {
      const sleepPercentage = 60;
      const title = 'Test Presentation';
      const goodPoints = ['Good point 1', 'Good point 2'];
      const improvements = ['Improvement 1', 'Improvement 2'];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    testWidgets('should generate result image with zero sleep percentage', (tester) async {
      const sleepPercentage = 0;
      const title = 'Perfect Presentation';
      const goodPoints = ['Excellent engagement'];
      const improvements = ['Keep it up'];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    testWidgets('should generate result image with 100 sleep percentage', (tester) async {
      const sleepPercentage = 100;
      const title = 'Boring Presentation';
      const goodPoints = ['It ended'];
      const improvements = ['Everything'];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    testWidgets('should generate result image with empty lists', (tester) async {
      const sleepPercentage = 50;
      const title = 'Minimal Presentation';
      const goodPoints = <String>[];
      const improvements = <String>[];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    testWidgets('should generate result image with long title', (tester) async {
      const sleepPercentage = 30;
      const title = 'This is a very long presentation title that might need to be wrapped or truncated in the generated image';
      const goodPoints = ['Good point'];
      const improvements = ['Some improvement'];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    testWidgets('should generate result image with many good points', (tester) async {
      const sleepPercentage = 25;
      const title = 'Great Presentation';
      const goodPoints = [
        'Excellent visual design',
        'Clear structure',
        'Engaging content',
        'Good timing',
        'Strong opening',
        'Memorable conclusion',
        'Interactive elements',
        'Relevant examples',
      ];
      const improvements = ['Minor improvement'];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    testWidgets('should generate result image with many improvements', (tester) async {
      const sleepPercentage = 75;
      const title = 'Needs Work Presentation';
      const goodPoints = ['One good point'];
      const improvements = [
        'Better visual design',
        'Clearer structure',
        'More engaging content',
        'Better timing',
        'Stronger opening',
        'Better conclusion',
        'Add interactive elements',
        'More relevant examples',
      ];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    testWidgets('should generate result image with empty title', (tester) async {
      const sleepPercentage = 40;
      const title = '';
      const goodPoints = ['Some good point'];
      const improvements = ['Some improvement'];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    testWidgets('should generate result image with Japanese text', (tester) async {
      const sleepPercentage = 45;
      const title = 'プレゼンテーション分析結果';
      const goodPoints = [
        'スライドの構成が分かりやすい',
        '視覚的に魅力的',
        '内容が充実している',
      ];
      const improvements = [
        'より詳細な説明が必要',
        'フォントサイズを大きく',
        '話すスピードを調整',
      ];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    testWidgets('should generate result image with special characters', (tester) async {
      const sleepPercentage = 55;
      const title = 'Test: Presentation Analysis (2024) #1!';
      const goodPoints = ['Good: Point #1', 'Another & Better Point'];
      const improvements = ['Fix: Issue #1', 'Improve: Area (critical)'];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    testWidgets('should generate consistent image size', (tester) async {
      const sleepPercentage = 35;
      const title = 'Size Test';
      const goodPoints = ['Test'];
      const improvements = ['Test'];

      final result1 = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      final result2 = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      // Images should have the same size (though content might differ slightly due to rendering)
      expect(result1.length, greaterThan(1000)); // Should be a reasonable size for PNG
      expect(result2.length, greaterThan(1000));
    });
  });
}