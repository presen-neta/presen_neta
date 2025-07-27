import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';
import 'package:presen_neta/shared/service/presentation_analysis_service.dart';

import 'presentation_analysis_service_test.mocks.dart';

@GenerateMocks([FilePickerService])
void main() {
  late PresentationAnalysisService service;
  late MockFilePickerService mockFilePickerService;

  setUp(() {
    mockFilePickerService = MockFilePickerService();
    service = PresentationAnalysisService(
      filePickerService: mockFilePickerService,
    );
  });

  group('PresentationAnalysisService', () {
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
}
