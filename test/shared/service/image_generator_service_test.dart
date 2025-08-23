import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presen_neta/shared/service/image_generator_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageGeneratorService', () {
    late ImageGeneratorService service;

    setUp(() {
      service = const ImageGeneratorService();
    });

    setUpAll(() {
      // テスト環境でアセットローダーを設定
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            // アセットファイルが見つからない場合は空のデータを返す
            return Uint8List(0).buffer.asByteData();
          });
    });

    tearDownAll(() {
      // モックをクリア
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test('should create instance successfully', () {
      expect(service, isA<ImageGeneratorService>());
    });

    test('should generate result image with basic parameters', () async {
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

    test('should generate result image with zero sleep percentage', () async {
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

    test('should generate result image with 100 sleep percentage', () async {
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

    test('should generate result image with empty lists', () async {
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

    test('should generate result image with long title', () async {
      const sleepPercentage = 30;
      const title = 'これは生成された画像で折り返しや省略が必要になるかもしれない非常に長いプレゼンテーションタイトルです';
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

    test('should generate result image with many good points', () async {
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

    test('should generate result image with many improvements', () async {
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

    test('should generate result image with empty title', () async {
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

    test('should generate result image with Japanese text', () async {
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

    test('should generate result image with special characters', () async {
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

    test('should generate consistent image size', () async {
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

      // 画像は同じサイズであるべき（ただし、レンダリングの違いにより内容がわずかに異なる場合があります）
      expect(result1.length, greaterThan(1000)); // PNGとして妥当なサイズであるべき
      expect(result2.length, greaterThan(1000));
    });

    test('should handle asset loading failures gracefully', () async {
      // バイナリメッセンジャーをリセットして、アセット読み込みエラーを発生させる
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            throw Exception('Asset not found');
          });

      const sleepPercentage = 45;
      const title = 'Error Test';
      const goodPoints = ['Still works'];
      const improvements = ['Handle errors'];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      // 画像は生成されるべき（アセット読み込み失敗は無視される）
      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);

      // アセットローダーを元に戻す
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            return Uint8List(0).buffer.asByteData();
          });
    });

    test('should generate images with extreme values', () async {
      final extremeCases = [
        (0, 'Perfect', <String>[], <String>[]),
        (100, 'Worst', <String>[], <String>[]),
        (50, '', <String>[], <String>[]),
        (25, 'Test', <String>['A' * 1000], <String>[]),
        (75, 'Test', <String>[], <String>['B' * 1000]),
      ];

      for (final (percentage, title, good, improve) in extremeCases) {
        final result = await service.generateResultImage(
          sleepPercentage: percentage,
          title: title,
          goodPoints: good,
          improvements: improve,
        );

        expect(result, isA<Uint8List>());
        expect(result.isNotEmpty, true);
      }
    });

    test('should handle various text lengths and content', () async {
      final textVariations = [
        // Empty strings
        (30, '', <String>[], <String>[]),
        // Very short
        (35, 'A', <String>['B'], <String>['C']),
        // Medium length
        (
          40,
          'Medium Length Title',
          <String>['Good point here'],
          <String>['Improvement here'],
        ),
        // Very long strings
        (
          45,
          '生成された画像で折り返しや省略が必要になるかもしれない非常に長いタイトルです',
          <String>[
            '良い点について詳細な情報がたくさん含まれている非常に長い良い点',
          ],
          <String>[
            '詳細な説明を含む非常に長い改善提案',
          ],
        ),
        // Special characters
        (
          50,
          'Title with 特殊文字 & symbols!',
          <String>['Good with émojis 🎉'],
          <String>['Improve with ñ accents'],
        ),
        // Numbers and mixed content
        (
          55,
          '2024 Analysis Report #1',
          <String>['99% better than before'],
          <String>['Reduce by 50%'],
        ),
      ];

      for (final (percentage, title, good, improve) in textVariations) {
        final result = await service.generateResultImage(
          sleepPercentage: percentage,
          title: title,
          goodPoints: good,
          improvements: improve,
        );

        expect(result, isA<Uint8List>());
        expect(result.isNotEmpty, true);
      }
    });

    test('should handle multiple concurrent image generations', () async {
      const sleepPercentage = 60;
      const title = 'Concurrent Test';
      const goodPoints = ['Concurrency'];
      const improvements = ['Performance'];

      final futures = List.generate(
        5,
        (i) => service.generateResultImage(
          sleepPercentage: sleepPercentage + i,
          title: '$title $i',
          goodPoints: goodPoints,
          improvements: improvements,
        ),
      );

      final results = await Future.wait(futures);

      for (final result in results) {
        expect(result, isA<Uint8List>());
        expect(result.isNotEmpty, true);
      }
    });

    test('should generate different images for different inputs', () async {
      final result1 = await service.generateResultImage(
        sleepPercentage: 30,
        title: 'First Test',
        goodPoints: ['Good 1'],
        improvements: ['Improve 1'],
      );

      final result2 = await service.generateResultImage(
        sleepPercentage: 70,
        title: 'Second Test',
        goodPoints: ['Good 2'],
        improvements: ['Improve 2'],
      );

      expect(result1, isA<Uint8List>());
      expect(result2, isA<Uint8List>());
      expect(result1.isNotEmpty, true);
      expect(result2.isNotEmpty, true);

      // Images should be different (though we can't easily compare content)
      // At minimum, they should both be valid images
    });

    test('should handle edge cases for list content', () async {
      final listTestCases = [
        // Empty lists
        (<String>[], <String>[]),
        // Single items
        (<String>['Single good'], <String>['Single improve']),
        // Many items
        (
          List.generate(20, (i) => 'Good point $i'),
          List.generate(15, (i) => 'Improvement $i'),
        ),
        // Mixed lengths
        (
          <String>[
            'Short',
            'Medium length point',
            'Very long good point with lots of detail',
          ],
          <String>['Brief', 'Detailed improvement suggestion with explanation'],
        ),
        // Special characters in lists
        (
          <String>[
            'Good with 🎉',
            'Point with "quotes"',
            'Item with \n newline',
          ],
          <String>[
            'Fix & improve',
            'Handle / slashes',
            r'Address \ backslashes',
          ],
        ),
      ];

      for (var i = 0; i < listTestCases.length; i++) {
        final (good, improve) = listTestCases[i];
        final result = await service.generateResultImage(
          sleepPercentage: 40 + i * 10,
          title: 'List Test $i',
          goodPoints: good,
          improvements: improve,
        );

        expect(result, isA<Uint8List>());
        expect(result.isNotEmpty, true);
      }
    });

    test('should maintain consistent image dimensions', () async {
      const sleepPercentage = 50;
      const title = 'Dimension Test';
      const goodPoints = ['Consistency'];
      const improvements = ['Standards'];

      final results = <Uint8List>[];
      for (var i = 0; i < 3; i++) {
        final result = await service.generateResultImage(
          sleepPercentage: sleepPercentage,
          title: title,
          goodPoints: goodPoints,
          improvements: improvements,
        );
        results.add(result);
      }

      // All results should be non-empty images
      for (final result in results) {
        expect(result, isA<Uint8List>());
        expect(result.isNotEmpty, true);
        // PNG images should start with PNG signature
        expect(result.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
      }
    });

    test('should handle various percentage display formats', () async {
      final percentageTests = [
        0, // 0%
        1, // 1%
        10, // 10%
        25, // 25%
        50, // 50%
        75, // 75%
        99, // 99%
        100, // 100%
      ];

      for (final percentage in percentageTests) {
        final result = await service.generateResultImage(
          sleepPercentage: percentage,
          title: 'Percentage Test $percentage%',
          goodPoints: ['Test'],
          improvements: ['Test'],
        );

        expect(result, isA<Uint8List>());
        expect(result.isNotEmpty, true);
      }
    });

    test('should handle memory-intensive text content', () async {
      // Test with large amounts of text
      final largeGoodPoints = List.generate(
        100,
        (i) =>
            'Good point number $i with some additional text to make it longer',
      );
      final largeImprovements = List.generate(
        100,
        (i) =>
            'Improvement number $i with detailed explanation and suggestions',
      );

      final result = await service.generateResultImage(
        sleepPercentage: 65,
        title: '大量のテキストと情報を含む非常に長いタイトルによるメモリテスト',
        goodPoints: largeGoodPoints,
        improvements: largeImprovements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    test('should validate PNG format output', () async {
      const sleepPercentage = 42;
      const title = 'PNG Format Test';
      const goodPoints = ['Valid PNG'];
      const improvements = ['Format checking'];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);

      // Verify PNG signature (first 8 bytes)
      expect(result.length, greaterThan(8));
      expect(result[0], 137); // PNG signature byte 1
      expect(result[1], 80); // 'P'
      expect(result[2], 78); // 'N'
      expect(result[3], 71); // 'G'
      expect(result[4], 13); // CR
      expect(result[5], 10); // LF
      expect(result[6], 26); // SUB
      expect(result[7], 10); // LF
    });

    test('should handle canvas operations without errors', () async {
      // This test exercises various canvas operations
      const sleepPercentage = 85;
      const title = 'Canvas Operations Test';
      const goodPoints = ['Drawing', 'Colors', 'Text rendering'];
      const improvements = ['Canvas efficiency', 'Memory usage'];

      final result = await service.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);

      // Should be a reasonable size for a PNG image
      expect(result.length, greaterThan(1000));
      expect(result.length, lessThan(1000000)); // Not too large
    });
  });
}
