import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';
import 'package:presen_neta/shared/models/review_result.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';
import 'package:presen_neta/shared/providers/service_providers.dart';

/// Test implementation of GeminiService for result provider testing
class TestGeminiServiceForProvider implements GeminiServiceInterface {
  ReviewResult? mockResult;
  bool shouldThrow = false;

  @override
  Future<ReviewResult> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  }) async {
    if (shouldThrow) {
      throw Exception('Test error');
    }
    return mockResult ?? const ReviewResult(point: 80, good: ['Test'], improve: ['Test']);
  }

  @override
  Future<int> countTokens(String content) async {
    return content.length ~/ 4;
  }
}

void main() {
  group('AnalysisNotifier', () {
    late ProviderContainer container;
    late TestGeminiServiceForProvider mockGeminiService;

    setUp(() {
      mockGeminiService = TestGeminiServiceForProvider();
      container = ProviderContainer(
        overrides: [
          geminiServiceProvider.overrideWithValue(mockGeminiService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should build with null initial state', () async {
      final notifier = container.read(analysisNotifierProvider.notifier);
      final state = await container.read(analysisNotifierProvider.future);
      
      expect(state, isNull);
    });

    test('should analyze multiple slide images successfully', () async {
      mockGeminiService.mockResult = const ReviewResult(
        point: 85,
        good: ['Great presentation'],
        improve: ['Add more examples'],
      );

      final notifier = container.read(analysisNotifierProvider.notifier);
      final imageDataList = [
        Uint8List.fromList([1, 2, 3, 4]),
        Uint8List.fromList([5, 6, 7, 8]),
      ];

      await notifier.analyzeMultipleSlideImages(imageDataList);
      
      final state = container.read(analysisNotifierProvider);
      expect(state.hasValue, true);
      expect(state.value?.point, 85);
      expect(state.value?.good, contains('Great presentation'));
      expect(state.value?.improve, contains('Add more examples'));
    });

    test('should handle analysis error', () async {
      mockGeminiService.shouldThrow = true;

      final notifier = container.read(analysisNotifierProvider.notifier);
      final imageDataList = [Uint8List.fromList([1, 2, 3, 4])];

      await notifier.analyzeMultipleSlideImages(imageDataList);
      
      final state = container.read(analysisNotifierProvider);
      expect(state.hasError, true);
      expect(state.error, isA<Exception>());
    });

    test('should reset state to null', () async {
      // First set some data
      mockGeminiService.mockResult = const ReviewResult(
        point: 75,
        good: ['Test good'],
        improve: ['Test improve'],
      );

      final notifier = container.read(analysisNotifierProvider.notifier);
      await notifier.analyzeMultipleSlideImages([Uint8List.fromList([1, 2, 3])]);
      
      // Verify data is set
      var state = container.read(analysisNotifierProvider);
      expect(state.hasValue, true);
      expect(state.value?.point, 75);

      // Reset and verify
      notifier.reset();
      state = container.read(analysisNotifierProvider);
      expect(state.hasValue, true);
      expect(state.value, isNull);
    });

    test('should use custom MIME type', () async {
      mockGeminiService.mockResult = const ReviewResult(
        point: 90,
        good: ['Excellent'],
        improve: [],
      );

      final notifier = container.read(analysisNotifierProvider.notifier);
      final imageDataList = [Uint8List.fromList([1, 2, 3, 4])];

      await notifier.analyzeMultipleSlideImages(
        imageDataList,
        imageMimeType: 'image/jpeg',
      );
      
      final state = container.read(analysisNotifierProvider);
      expect(state.hasValue, true);
      expect(state.value?.point, 90);
    });

    test('should handle empty image data list', () async {
      // For empty list, mock service returns default result
      mockGeminiService.mockResult = const ReviewResult(
        point: 50,
        good: [],
        improve: ['Add slide content'],
      );

      final notifier = container.read(analysisNotifierProvider.notifier);
      final imageDataList = <Uint8List>[];

      await notifier.analyzeMultipleSlideImages(imageDataList);
      
      final state = container.read(analysisNotifierProvider);
      expect(state.hasValue, true);
      expect(state.value?.point, 50);
    });
  });
}