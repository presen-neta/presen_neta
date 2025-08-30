import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';
import 'package:presen_neta/shared/service/presentation_analysis_service.dart';

import 'presentation_analysis_service_coverage_test.mocks.dart';

@GenerateMocks([FilePickerService])
void main() {
  group('PresentationAnalysisService Coverage Tests', () {
    late MockFilePickerService mockFilePickerService;
    late PresentationAnalysisService service;

    setUp(() {
      mockFilePickerService = MockFilePickerService();
      service = PresentationAnalysisService(
        filePickerService: mockFilePickerService,
      );
    });

    group('analyzePdfFile comprehensive coverage', () {
      testWidgets('should handle successful file selection and analysis', (
        tester,
      ) async {
        // Arrange
        final pdfFile = PlatformFile(
          name: 'test.pdf',
          size: 1000,
          bytes: Uint8List.fromList(List.generate(1000, (i) => i % 256)),
        );

        when(
          mockFilePickerService.pickFile(),
        ).thenAnswer((_) async => FilePickerResult([pdfFile]));
        when(
          mockFilePickerService.readPdfFileContent(any),
        ).thenAnswer((_) async => pdfFile.bytes);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () async {
                            final result = await service.analyzePdfFile(
                              context,
                              ref,
                            );
                            expect(
                              result,
                              false,
                            ); // PDF conversion will fail in test environment
                          },
                          child: const Text('Test'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        verify(mockFilePickerService.pickFile()).called(1);
        verify(mockFilePickerService.readPdfFileContent(any)).called(1);
      });

      testWidgets('should handle null file picker result', (tester) async {
        // Arrange
        when(mockFilePickerService.pickFile()).thenAnswer((_) async => null);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () async {
                            final result = await service.analyzePdfFile(
                              context,
                              ref,
                            );
                            expect(result, false);
                          },
                          child: const Text('Test Null'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test Null'));
        await tester.pumpAndSettle();

        verify(mockFilePickerService.pickFile()).called(1);
        verifyNever(mockFilePickerService.readPdfFileContent(any));
      });

      testWidgets('should handle empty file list', (tester) async {
        // Arrange
        when(
          mockFilePickerService.pickFile(),
        ).thenAnswer((_) async => const FilePickerResult([]));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () async {
                            final result = await service.analyzePdfFile(
                              context,
                              ref,
                            );
                            expect(result, false);
                          },
                          child: const Text('Test Empty'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test Empty'));
        await tester.pumpAndSettle();

        verify(mockFilePickerService.pickFile()).called(1);
        verifyNever(mockFilePickerService.readPdfFileContent(any));
      });

      testWidgets('should handle non-PDF file extension', (tester) async {
        // Arrange
        final txtFile = PlatformFile(name: 'test.txt', size: 100);
        when(
          mockFilePickerService.pickFile(),
        ).thenAnswer((_) async => FilePickerResult([txtFile]));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () async {
                            final result = await service.analyzePdfFile(
                              context,
                              ref,
                            );
                            expect(result, false);
                          },
                          child: const Text('Test TXT'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test TXT'));
        await tester.pumpAndSettle();

        verify(mockFilePickerService.pickFile()).called(1);
        verifyNever(mockFilePickerService.readPdfFileContent(any));
      });

      testWidgets('should handle PDF file read failure', (tester) async {
        // Arrange
        final pdfFile = PlatformFile(name: 'test.pdf', size: 1000);
        when(
          mockFilePickerService.pickFile(),
        ).thenAnswer((_) async => FilePickerResult([pdfFile]));
        when(
          mockFilePickerService.readPdfFileContent(any),
        ).thenAnswer((_) async => null);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () async {
                            final result = await service.analyzePdfFile(
                              context,
                              ref,
                            );
                            expect(result, false);
                          },
                          child: const Text('Test Read Failure'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test Read Failure'));
        await tester.pumpAndSettle();

        verify(mockFilePickerService.pickFile()).called(1);
        verify(mockFilePickerService.readPdfFileContent(any)).called(1);
      });
      testWidgets('should handle file read exception', (tester) async {
        // Arrange
        final pdfFile = PlatformFile(name: 'test.pdf', size: 1000);
        when(
          mockFilePickerService.pickFile(),
        ).thenAnswer((_) async => FilePickerResult([pdfFile]));
        when(
          mockFilePickerService.readPdfFileContent(any),
        ).thenThrow(Exception('File read error'));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () async {
                            final result = await service.analyzePdfFile(
                              context,
                              ref,
                            );
                            expect(result, false);
                          },
                          child: const Text('Test Read Exception'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test Read Exception'));
        await tester.pumpAndSettle();

        verify(mockFilePickerService.pickFile()).called(1);
        verify(mockFilePickerService.readPdfFileContent(any)).called(1);
      });
    });

    group('convertPdfToPngImages coverage', () {
      test('should handle empty PDF data', () async {
        final result = await service.convertPdfToPngImages(Uint8List(0));
        expect(result, isEmpty);
      });

      test('should handle invalid PDF data', () async {
        final invalidPdfData = Uint8List.fromList([1, 2, 3, 4, 5]);
        final result = await service.convertPdfToPngImages(invalidPdfData);
        expect(result, isEmpty);
      });

      test('should handle PDF processing exception', () async {
        final malformedPdfData = Uint8List.fromList(
          List.generate(1000, (i) => i % 256),
        );
        final result = await service.convertPdfToPngImages(malformedPdfData);
        expect(result, isEmpty);
      });

      test('should handle various PDF data sizes', () async {
        final testSizes = [1, 10, 100, 1000, 10000];

        for (final size in testSizes) {
          final pdfData = Uint8List.fromList(
            List.generate(size, (i) => i % 256),
          );
          final result = await service.convertPdfToPngImages(pdfData);
          expect(result, isEmpty); // Will be empty due to invalid PDF data
        }
      });
    });

    group('filePickerService getter coverage', () {
      test('should return injected service when provided', () {
        final service = PresentationAnalysisService(
          filePickerService: mockFilePickerService,
        );
        expect(service.filePickerService, same(mockFilePickerService));
      });
    });
  });
}
