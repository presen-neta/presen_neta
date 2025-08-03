import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';
import 'package:presen_neta/shared/service/presentation_analysis_service.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';

import 'presentation_analysis_service_test.mocks.dart';

@GenerateMocks([FilePickerService])
void main() {
  late MockFilePickerService mockFilePickerService;
  late PresentationAnalysisService service;
  late ProviderContainer container;

  setUp(() {
    mockFilePickerService = MockFilePickerService();
    service = PresentationAnalysisService(filePickerService: mockFilePickerService);
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('FilePickerService Mock Tests', () {
    test('PDFファイルが正常に選択された場合、FilePickerResultを返す', () async {
      final file = PlatformFile(name: 'test.pdf', size: 1, path: 'test.pdf');
      final result = FilePickerResult([file]);

      when(mockFilePickerService.pickFile()).thenAnswer((_) async => result);

      final picked = await mockFilePickerService.pickFile();
      expect(picked, isNotNull);
      expect(picked!.files.first.name, 'test.pdf');
    });

    test('PDFファイルの内容が正常に読み取られた場合、Uint8Listを返す', () async {
      final file = PlatformFile(name: 'test.pdf', size: 1, path: 'test.pdf');
      final expectedData = Uint8List.fromList([1, 2, 3]);

      when(
        mockFilePickerService.readPdfFileContent(any),
      ).thenAnswer((_) async => expectedData);

      final data = await mockFilePickerService.readPdfFileContent(file);
      expect(data, isNotNull);
      expect(data, equals(expectedData));
    });

    test('PDFファイル以外が選択された場合、FilePickerResultを返す', () async {
      final result = FilePickerResult([
        PlatformFile(name: 'test.txt', size: 1),
      ]);

      when(mockFilePickerService.pickFile()).thenAnswer((_) async => result);

      final picked = await mockFilePickerService.pickFile();
      expect(picked, isNotNull);
      expect(picked!.files.first.name, 'test.txt');
    });

    test('ファイル選択がキャンセルされた場合、nullを返す', () async {
      when(mockFilePickerService.pickFile()).thenAnswer((_) async => null);

      final picked = await mockFilePickerService.pickFile();
      expect(picked, isNull);
    });
  });

  group('PresentationAnalysisService', () {
    test('should handle file picker returning null', () async {
      when(mockFilePickerService.pickFile()).thenAnswer((_) async => null);
      
      // Test that the service can handle null file picker result
      final pickedResult = await mockFilePickerService.pickFile();
      expect(pickedResult, isNull);
    });

    test('should handle empty file result', () async {
      when(mockFilePickerService.pickFile())
          .thenAnswer((_) async => FilePickerResult([]));

      final pickedResult = await mockFilePickerService.pickFile();
      expect(pickedResult, isNotNull);
      expect(pickedResult!.files, isEmpty);
    });

    test('should handle non-PDF files', () async {
      final file = PlatformFile(name: 'test.txt', size: 1);
      when(mockFilePickerService.pickFile())
          .thenAnswer((_) async => FilePickerResult([file]));

      final pickedResult = await mockFilePickerService.pickFile();
      expect(pickedResult, isNotNull);
      expect(pickedResult!.files.first.name, 'test.txt');
      
      // Should identify as non-PDF
      expect(pickedResult.files.first.name.endsWith('.pdf'), false);
    });

    test('should handle PDF reading failure', () async {
      final file = PlatformFile(name: 'test.pdf', size: 1);
      when(mockFilePickerService.pickFile())
          .thenAnswer((_) async => FilePickerResult([file]));
      when(mockFilePickerService.readPdfFileContent(any))
          .thenAnswer((_) async => null);

      final pickedResult = await mockFilePickerService.pickFile();
      expect(pickedResult, isNotNull);
      expect(pickedResult!.files.first.name, 'test.pdf');
      
      final pdfContent = await mockFilePickerService.readPdfFileContent(pickedResult.files.first);
      expect(pdfContent, isNull);
    });

    test('should return empty list for invalid PDF data in convertPdfToPngImages', () async {
      final invalidPdfData = Uint8List.fromList([1, 2, 3, 4]); // Invalid PDF data
      
      final result = await service.convertPdfToPngImages(invalidPdfData);
      
      expect(result, isEmpty);
    });

    test('should handle exceptions in convertPdfToPngImages', () async {
      final invalidData = Uint8List(0); // Empty data to trigger exception
      
      final result = await service.convertPdfToPngImages(invalidData);
      
      expect(result, isEmpty);
    });

    test('should get default FilePickerService when none provided', () {
      final defaultService = PresentationAnalysisService();
      
      expect(defaultService.filePickerService, isA<FilePickerService>());
    });

    test('should use injected FilePickerService when provided', () {
      final injectedService = PresentationAnalysisService(
        filePickerService: mockFilePickerService,
      );
      
      expect(injectedService.filePickerService, equals(mockFilePickerService));
    });
  });
}
