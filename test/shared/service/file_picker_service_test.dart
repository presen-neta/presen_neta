import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';

import 'file_picker_service_test.mocks.dart';

@GenerateMocks([FilePicker])
void main() {
  late FilePickerService service;
  late MockFilePicker mockFilePicker;

  setUp(() {
    mockFilePicker = MockFilePicker();
    service = FilePickerService(filePicker: mockFilePicker);
  });

  group('FilePickerService', () {
    test('ファイルが正常に選択された場合、FilePickerResultを返す', () async {
      final result = FilePickerResult([
        PlatformFile(name: 'test.pdf', size: 1),
      ]);
      when(
        mockFilePicker.pickFiles(
          dialogTitle: anyNamed('dialogTitle'),
          initialDirectory: anyNamed('initialDirectory'),
          type: anyNamed('type'),
          allowedExtensions: anyNamed('allowedExtensions'),
          onFileLoading: anyNamed('onFileLoading'),
          allowCompression: anyNamed('allowCompression'),
          compressionQuality: anyNamed('compressionQuality'),
          allowMultiple: anyNamed('allowMultiple'),
          withData: anyNamed('withData'),
          withReadStream: anyNamed('withReadStream'),
          lockParentWindow: anyNamed('lockParentWindow'),
          readSequential: anyNamed('readSequential'),
        ),
      ).thenAnswer((_) async => result);
      final picked = await service.pickFile();
      expect(picked, isNotNull);
      expect(picked!.files.first.name, 'test.pdf');
    });

    test('ファイル選択がキャンセルされた場合、nullを返す', () async {
      when(
        mockFilePicker.pickFiles(
          dialogTitle: anyNamed('dialogTitle'),
          initialDirectory: anyNamed('initialDirectory'),
          type: anyNamed('type'),
          allowedExtensions: anyNamed('allowedExtensions'),
          onFileLoading: anyNamed('onFileLoading'),
          allowCompression: anyNamed('allowCompression'),
          compressionQuality: anyNamed('compressionQuality'),
          allowMultiple: anyNamed('allowMultiple'),
          withData: anyNamed('withData'),
          withReadStream: anyNamed('withReadStream'),
          lockParentWindow: anyNamed('lockParentWindow'),
          readSequential: anyNamed('readSequential'),
        ),
      ).thenAnswer((_) async => null);
      final picked = await service.pickFile();
      expect(picked, isNull);
    });

    test('複数ファイルが選択された場合、最初のファイルを返す', () async {
      final result = FilePickerResult([
        PlatformFile(name: 'first.pdf', size: 1),
        PlatformFile(name: 'second.pdf', size: 2),
      ]);
      when(
        mockFilePicker.pickFiles(
          dialogTitle: anyNamed('dialogTitle'),
          initialDirectory: anyNamed('initialDirectory'),
          type: anyNamed('type'),
          allowedExtensions: anyNamed('allowedExtensions'),
          onFileLoading: anyNamed('onFileLoading'),
          allowCompression: anyNamed('allowCompression'),
          compressionQuality: anyNamed('compressionQuality'),
          allowMultiple: anyNamed('allowMultiple'),
          withData: anyNamed('withData'),
          withReadStream: anyNamed('withReadStream'),
          lockParentWindow: anyNamed('lockParentWindow'),
          readSequential: anyNamed('readSequential'),
        ),
      ).thenAnswer((_) async => result);
      final picked = await service.pickFile();
      expect(picked, isNotNull);
      expect(picked!.files.first.name, 'first.pdf');
    });

    test('空のファイルリストが返された場合、FilePickerResultを返す', () async {
      const result = FilePickerResult([]);
      when(
        mockFilePicker.pickFiles(
          dialogTitle: anyNamed('dialogTitle'),
          initialDirectory: anyNamed('initialDirectory'),
          type: anyNamed('type'),
          allowedExtensions: anyNamed('allowedExtensions'),
          onFileLoading: anyNamed('onFileLoading'),
          allowCompression: anyNamed('allowCompression'),
          compressionQuality: anyNamed('compressionQuality'),
          allowMultiple: anyNamed('allowMultiple'),
          withData: anyNamed('withData'),
          withReadStream: anyNamed('withReadStream'),
          lockParentWindow: anyNamed('lockParentWindow'),
          readSequential: anyNamed('readSequential'),
        ),
      ).thenAnswer((_) async => result);
      final picked = await service.pickFile();
      expect(picked, isNotNull);
      expect(picked!.files, isEmpty);
    });

    test('pickFilesが例外を投げた場合、例外が伝播する', () async {
      when(
        mockFilePicker.pickFiles(
          dialogTitle: anyNamed('dialogTitle'),
          initialDirectory: anyNamed('initialDirectory'),
          type: anyNamed('type'),
          allowedExtensions: anyNamed('allowedExtensions'),
          onFileLoading: anyNamed('onFileLoading'),
          allowCompression: anyNamed('allowCompression'),
          compressionQuality: anyNamed('compressionQuality'),
          allowMultiple: anyNamed('allowMultiple'),
          withData: anyNamed('withData'),
          withReadStream: anyNamed('withReadStream'),
          lockParentWindow: anyNamed('lockParentWindow'),
          readSequential: anyNamed('readSequential'),
        ),
      ).thenThrow(Exception('Test exception'));
      expect(
        () => service.pickFile(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('FilePickerService - readPdfFileContent', () {
    test('should return bytes when file has bytes', () async {
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final file = PlatformFile(
        name: 'test.pdf',
        size: testBytes.length,
        bytes: testBytes,
      );
      
      final result = await service.readPdfFileContent(file);
      
      expect(result, equals(testBytes));
    });

    test('should return null when file has no path and no bytes', () async {
      final file = PlatformFile(name: 'test.pdf', size: 100);
      
      final result = await service.readPdfFileContent(file);
      
      expect(result, isNull);
    });

    test('should return null when file path is empty', () async {
      final file = PlatformFile(name: 'test.pdf', size: 100, path: '');
      
      final result = await service.readPdfFileContent(file);
      
      expect(result, isNull);
    });

    test('should return null when file path does not exist', () async {
      final file = PlatformFile(
        name: 'test.pdf',
        size: 100,
        path: '/non/existent/path/test.pdf',
      );
      
      final result = await service.readPdfFileContent(file);
      
      expect(result, isNull);
    });

    test('should prioritize bytes over path', () async {
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final file = PlatformFile(
        name: 'test.pdf',
        size: testBytes.length,
        path: '/some/path/test.pdf',
        bytes: testBytes,
      );
      
      final result = await service.readPdfFileContent(file);
      
      expect(result, equals(testBytes));
    });

    test('should handle empty bytes', () async {
      final file = PlatformFile(
        name: 'test.pdf',
        size: 0,
        bytes: Uint8List(0),
      );
      
      final result = await service.readPdfFileContent(file);
      
      expect(result, isNotNull);
      expect(result, hasLength(0));
    });

    test('should handle large files', () async {
      final largeBytes = Uint8List.fromList(List.generate(10000, (i) => i % 256));
      final file = PlatformFile(
        name: 'large.pdf',
        size: largeBytes.length,
        bytes: largeBytes,
      );
      
      final result = await service.readPdfFileContent(file);
      
      expect(result, equals(largeBytes));
      expect(result?.length, 10000);
    });

    test('should handle special characters in file names', () async {
      final testBytes = Uint8List.fromList([1, 2, 3]);
      final file = PlatformFile(
        name: 'テスト資料_2024-01-01.pdf',
        size: testBytes.length,
        bytes: testBytes,
      );
      
      final result = await service.readPdfFileContent(file);
      
      expect(result, equals(testBytes));
    });
  });

  group('FilePickerService - constructor', () {
    test('should create with default FilePicker when none provided', () {
      final defaultService = FilePickerService();
      
      expect(defaultService, isA<FilePickerService>());
    });

    test('should use injected FilePicker when provided', () {
      final injectedService = FilePickerService(filePicker: mockFilePicker);
      
      expect(injectedService, isA<FilePickerService>());
    });
  });
}
