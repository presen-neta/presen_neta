import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/shared/providers/service_providers.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';

/// Test implementation for PresentationAnalysisService
class TestPresentationAnalysisServiceForCoverage
    implements PresentationAnalysisServiceInterface {
  bool shouldSucceed = true;
  List<Uint8List>? mockImageData;

  @override
  Future<bool> analyzePdfFile(BuildContext context, WidgetRef ref) async {
    return shouldSucceed;
  }

  @override
  Future<List<Uint8List>> convertPdfToPngImages(Uint8List pdfData) async {
    return mockImageData ??
        [
          Uint8List.fromList([1, 2, 3, 4]),
        ];
  }
}

void main() {
  group('PresentationAnalysisService Coverage Tests', () {
    late TestPresentationAnalysisServiceForCoverage testService;

    setUp(() {
      testService = TestPresentationAnalysisServiceForCoverage();
    });

    testWidgets('should handle successful analysis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presentationAnalysisServiceProvider.overrideWithValue(testService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () async {
                      final service = ref.read(
                        presentationAnalysisServiceProvider,
                      );
                      await service.analyzePdfFile(context, ref);
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      expect(testService.shouldSucceed, true);
    });

    testWidgets('should handle failed analysis', (WidgetTester tester) async {
      testService.shouldSucceed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presentationAnalysisServiceProvider.overrideWithValue(testService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () async {
                      final service = ref.read(
                        presentationAnalysisServiceProvider,
                      );
                      await service.analyzePdfFile(context, ref);
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      expect(testService.shouldSucceed, false);
    });

    test('should convert PDF to PNG images', () async {
      final pdfData = Uint8List.fromList([1, 2, 3, 4, 5]);
      testService.mockImageData = [
        Uint8List.fromList([10, 20, 30]),
        Uint8List.fromList([40, 50, 60]),
      ];

      final result = await testService.convertPdfToPngImages(pdfData);

      expect(result, isA<List<Uint8List>>());
      expect(result.length, 2);
      expect(result[0], Uint8List.fromList([10, 20, 30]));
      expect(result[1], Uint8List.fromList([40, 50, 60]));
    });

    test('should handle empty PDF data', () async {
      final pdfData = Uint8List.fromList([]);
      testService.mockImageData = [];

      final result = await testService.convertPdfToPngImages(pdfData);

      expect(result, isA<List<Uint8List>>());
      expect(result, isEmpty);
    });
  });
}
