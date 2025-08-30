import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';
import 'package:presen_neta/shared/models/review_result.dart';
import 'package:presen_neta/shared/providers/service_providers.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';
import 'package:presen_neta/shared/service/image_generator_service.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';
import 'package:presen_neta/shared/service/presentation_analysis_service.dart';

import 'service_integration_test.mocks.dart';

/// Mock implementation of GeminiService for integration testing
class MockGeminiServiceForIntegration implements GeminiServiceInterface {
  bool shouldReturnResult = true;
  ReviewResult? mockResult;
  Exception? mockException;

  @override
  Future<ReviewResult?> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  }) async {
    if (mockException != null) {
      throw mockException!;
    }

    if (!shouldReturnResult) {
      return null;
    }

    return mockResult ??
        const ReviewResult(
          point: 85,
          good: ['Good integration test'],
          improve: ['Improve integration test'],
        );
  }

  @override
  Future<int> countTokens(String content) async {
    if (mockException != null) {
      throw mockException!;
    }
    return content.length ~/ 4;
  }
}

@GenerateMocks([FilePickerService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Service Integration Tests', () {
    late MockFilePickerService mockFilePickerService;
    late MockGeminiServiceForIntegration mockGeminiService;
    late PresentationAnalysisService presentationService;
    late ImageGeneratorService imageService;

    setUp(() {
      mockFilePickerService = MockFilePickerService();
      mockGeminiService = MockGeminiServiceForIntegration();
      presentationService = PresentationAnalysisService(
        filePickerService: mockFilePickerService,
      );
      imageService = const ImageGeneratorService();
    });
    group('Image Generation Integration', () {
      test('should generate result image with actual analysis data', () async {
        const analysisResult = ReviewResult(
          point: 78,
          good: [
            'Clear presentation structure',
            'Good use of visuals',
            'Engaging storytelling approach',
          ],
          improve: [
            'Reduce text density on slides',
            'Increase font size for readability',
            'Add more interactive elements',
          ],
        );

        final imageData = await imageService.generateResultImage(
          sleepPercentage: 100 - analysisResult.point,
          title: 'Business Quarterly Review 2024',
          goodPoints: analysisResult.good,
          improvements: analysisResult.improve,
        );

        expect(imageData, isA<Uint8List>());
        expect(imageData.isNotEmpty, true);
        expect(imageData.length, greaterThan(1000));

        // Verify PNG signature
        expect(imageData.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
      });

      test(
        'should handle extreme analysis results in image generation',
        () async {
          final extremeResults = [
            const ReviewResult(
              point: 0,
              good: [],
              improve: ['Everything needs work'],
            ),
            const ReviewResult(
              point: 100,
              good: ['Perfect presentation'],
              improve: [],
            ),
            ReviewResult(
              point: 50,
              good: List.generate(50, (i) => 'Good point ${i + 1}'),
              improve: List.generate(50, (i) => 'Improvement ${i + 1}'),
            ),
          ];

          for (final result in extremeResults) {
            final imageData = await imageService.generateResultImage(
              sleepPercentage: 100 - result.point,
              title: 'Extreme Test Case - ${result.point} points',
              goodPoints: result.good,
              improvements: result.improve,
            );

            expect(imageData, isA<Uint8List>());
            expect(imageData.isNotEmpty, true);
          }
        },
      );
    });

    group('Provider Integration', () {
      testWidgets('should handle provider error states', (tester) async {
        mockGeminiService.mockException = Exception('Provider error test');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              geminiServiceProvider.overrideWithValue(mockGeminiService),
            ],
            child: MaterialApp(
              home: Consumer(
                builder: (context, ref, _) {
                  final analysisState = ref.watch(analysisNotifierProvider);

                  return Scaffold(
                    body: Column(
                      children: [
                        Text('State: ${analysisState.runtimeType}'),
                        if (analysisState.hasError)
                          Text('Error: ${analysisState.error}'),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(analysisNotifierProvider.notifier)
                                .analyzeMultipleSlideImages([
                                  Uint8List.fromList([1, 2, 3, 4]),
                                ]);
                          },
                          child: const Text('Trigger Error'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Trigger Error'));
        await tester.pumpAndSettle();

        // Should show error state
        expect(find.text('State: AsyncError<ReviewResult?>'), findsOneWidget);
        expect(find.textContaining('Error:'), findsOneWidget);
      });
    });

    group('Service Interaction Edge Cases', () {
      test('should handle multiple concurrent analysis requests', () async {
        final testData = List.generate(
          5,
          (i) => Uint8List.fromList([i + 1, i + 2, i + 3, i + 4]),
        );

        final futures =
            testData
                .map(
                  (data) =>
                      mockGeminiService.analyzeMultipleSlideImages([data]),
                )
                .toList();

        final results = await Future.wait(futures);

        for (final result in results) {
          expect(result, isA<ReviewResult>());
          expect(result!.point, 85);
        }
      });

      test('should handle service with different configurations', () async {
        final configurations = [
          MockGeminiServiceForIntegration()..shouldReturnResult = true,
          MockGeminiServiceForIntegration()..shouldReturnResult = false,
          MockGeminiServiceForIntegration()
            ..mockException = Exception('Config error'),
        ];

        final testData = Uint8List.fromList([1, 2, 3, 4]);

        for (var i = 0; i < configurations.length; i++) {
          final service = configurations[i];

          if (service.mockException != null) {
            expect(
              () => service.analyzeMultipleSlideImages([testData]),
              throwsA(isA<Exception>()),
            );
          } else if (service.shouldReturnResult) {
            final result = await service.analyzeMultipleSlideImages([testData]);
            expect(result, isA<ReviewResult>());
          } else {
            final result = await service.analyzeMultipleSlideImages([testData]);
            expect(result, isNull);
          }
        }
      });

      test('should maintain service isolation', () async {
        final service1 =
            MockGeminiServiceForIntegration()
              ..mockResult = const ReviewResult(
                point: 90,
                good: ['Service 1'],
                improve: ['Test 1'],
              );

        final service2 =
            MockGeminiServiceForIntegration()
              ..mockResult = const ReviewResult(
                point: 60,
                good: ['Service 2'],
                improve: ['Test 2'],
              );

        final testData = Uint8List.fromList([1, 2, 3, 4]);

        final result1 = await service1.analyzeMultipleSlideImages([testData]);
        final result2 = await service2.analyzeMultipleSlideImages([testData]);

        expect(result1!.point, 90);
        expect(result1.good, contains('Service 1'));

        expect(result2!.point, 60);
        expect(result2.good, contains('Service 2'));
      });
    });

    group('Performance and Memory Tests', () {
      test('should handle large data processing efficiently', () async {
        final startTime = DateTime.now();

        // Process large amount of data
        final largeDataSets = List.generate(
          10,
          (i) => Uint8List.fromList(List.generate(10000, (j) => (i + j) % 256)),
        );

        final futures =
            largeDataSets
                .map(
                  (data) =>
                      mockGeminiService.analyzeMultipleSlideImages([data]),
                )
                .toList();

        final results = await Future.wait(futures);

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Should complete within reasonable time
        expect(duration.inSeconds, lessThan(5));

        // All results should be valid
        for (final result in results) {
          expect(result, isA<ReviewResult>());
        }
      });

      test('should handle memory-intensive image generation', () async {
        final largeTexts = List.generate(
          10,
          (i) => 'Very long text that simulates large content $i ' * 100,
        );

        final futures =
            largeTexts
                .map(
                  (text) => imageService.generateResultImage(
                    sleepPercentage: 50,
                    title: text,
                    goodPoints: [text],
                    improvements: [text],
                  ),
                )
                .toList();

        final results = await Future.wait(futures);

        for (final result in results) {
          expect(result, isA<Uint8List>());
          expect(result.isNotEmpty, true);
        }
      });
    });
  });
}
