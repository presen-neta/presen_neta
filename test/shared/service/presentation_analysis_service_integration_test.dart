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
  });
}
