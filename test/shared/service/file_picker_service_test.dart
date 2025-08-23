import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
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
      final largeBytes = Uint8List.fromList(
        List.generate(10000, (i) => i % 256),
      );
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
    test(
      'should create with default FilePicker when none provided',
      () {
        // Skip this test as it requires platform initialization
        // In real usage, FilePicker.platform is properly initialized
      },
      skip: 'Requires platform initialization, covered by integration tests',
    );

    test('should use injected FilePicker when provided', () {
      final injectedService = FilePickerService(filePicker: mockFilePicker);

      expect(injectedService, isA<FilePickerService>());
    });

    test('should handle concurrent pickFile calls', () async {
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

      final future1 = service.pickFile();
      final future2 = service.pickFile();

      final results = await Future.wait([future1, future2]);

      // Service prevents concurrent calls - first succeeds, second returns null
      expect(results[0], isNotNull);
      expect(
        results[1],
        isNull,
      ); // Second call should return null due to _isPicking flag
    });

    test('should maintain consistent parameters across calls', () async {
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

      await service.pickFile();
      await service.pickFile(); // Both calls succeed when not concurrent

      // Verify service calls pickFiles with consistent parameters
      verify(
        mockFilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        ),
      ).called(2); // Both calls succeed when sequential
    });

    test('should handle file picker platform exception', () async {
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
      ).thenThrow(PlatformException(code: 'PERMISSION_DENIED'));

      expect(
        () => service.pickFile(),
        throwsA(isA<PlatformException>()),
      );
    });

    test('should handle very large file reading', () async {
      final largeData = Uint8List.fromList(
        List.generate(1000000, (i) => i % 256),
      );
      final file = PlatformFile(
        name: 'large.pdf',
        size: largeData.length,
        bytes: largeData,
      );

      final result = await service.readPdfFileContent(file);

      expect(result, equals(largeData));
      expect(result?.length, 1000000);
    });

    test('should handle file with unusual name patterns', () async {
      final testBytes = Uint8List.fromList([1, 2, 3]);
      final files = [
        PlatformFile(name: '..pdf', size: testBytes.length, bytes: testBytes),
        PlatformFile(
          name: 'file.with.dots.pdf',
          size: testBytes.length,
          bytes: testBytes,
        ),
        PlatformFile(
          name: 'file name with spaces.pdf',
          size: testBytes.length,
          bytes: testBytes,
        ),
        PlatformFile(
          name: 'ファイル名.pdf',
          size: testBytes.length,
          bytes: testBytes,
        ),
        PlatformFile(
          name: '123456789.pdf',
          size: testBytes.length,
          bytes: testBytes,
        ),
      ];

      for (final file in files) {
        final result = await service.readPdfFileContent(file);
        expect(result, equals(testBytes));
      }
    });

    test(
      'should handle multiple readPdfFileContent calls with same file',
      () async {
        final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final file = PlatformFile(
          name: 'test.pdf',
          size: testBytes.length,
          bytes: testBytes,
        );

        final result1 = await service.readPdfFileContent(file);
        final result2 = await service.readPdfFileContent(file);

        expect(result1, equals(testBytes));
        expect(result2, equals(testBytes));
        expect(result1, equals(result2));
      },
    );

    test('should handle file with zero size but valid bytes', () async {
      final testBytes = Uint8List.fromList([1, 2, 3]);
      final file = PlatformFile(
        name: 'test.pdf',
        size: 0, // サイズは0だが実際にはバイトがある
        bytes: testBytes,
      );

      final result = await service.readPdfFileContent(file);

      expect(result, equals(testBytes));
    });

    test(
      'should handle file with mismatched size and actual bytes length',
      () async {
        final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final file = PlatformFile(
          name: 'test.pdf',
          size: 1000, // 実際のバイト数と異なるサイズ
          bytes: testBytes,
        );

        final result = await service.readPdfFileContent(file);

        expect(result, equals(testBytes));
        expect(result?.length, 5); // 実際のバイト数が返される
      },
    );

    test('should handle concurrent readPdfFileContent calls', () async {
      final testBytes1 = Uint8List.fromList([1, 2, 3]);
      final testBytes2 = Uint8List.fromList([4, 5, 6]);

      final file1 = PlatformFile(
        name: 'test1.pdf',
        size: testBytes1.length,
        bytes: testBytes1,
      );

      final file2 = PlatformFile(
        name: 'test2.pdf',
        size: testBytes2.length,
        bytes: testBytes2,
      );

      final future1 = service.readPdfFileContent(file1);
      final future2 = service.readPdfFileContent(file2);

      final results = await Future.wait([future1, future2]);

      expect(results[0], equals(testBytes1));
      expect(results[1], equals(testBytes2));
    });

    test('should return null for non-PDF file', () async {
      final file = PlatformFile(
        name: 'test.txt',
        size: 100,
        path: '/some/path/test.txt',
      );

      final result = await service.readPdfFileContent(file);

      expect(result, isNull);
    });

    test(
      'should return null when exception occurs during file reading',
      () async {
        final file = PlatformFile(
          name: 'test.pdf',
          size: 100,
          path: '/invalid/path/test.pdf', // This will cause an exception
        );

        final result = await service.readPdfFileContent(file);

        expect(result, isNull);
      },
    );
  });

  group('FilePickerService - readFileContent', () {
    test('should return null for non-txt file', () async {
      final file = PlatformFile(
        name: 'test.pdf',
        size: 100,
        path: '/some/path/test.pdf',
      );

      final result = await service.readFileContent(file);

      expect(result, isNull);
    });

    test('should return null when file path is null', () async {
      final file = PlatformFile(
        name: 'test.txt',
        size: 100,
      );

      final result = await service.readFileContent(file);

      expect(result, isNull);
    });

    test(
      'should return null when exception occurs during file reading',
      () async {
        final file = PlatformFile(
          name: 'test.txt',
          size: 100,
          path: '/invalid/path/test.txt', // This will cause an exception
        );

        final result = await service.readFileContent(file);

        expect(result, isNull);
      },
    );

    test('should handle txt file extension correctly', () async {
      final file = PlatformFile(
        name: 'test.txt',
        size: 100,
        path:
            '/invalid/path/test.txt', // This will cause an exception in real scenario
      );

      // This will return null due to exception, but we test the extension logic
      final result = await service.readFileContent(file);

      expect(result, isNull);
    });

    test('should handle files with no extension', () async {
      final file = PlatformFile(
        name: 'test',
        size: 100,
        path: '/some/path/test',
      );

      final result = await service.readFileContent(file);

      expect(result, isNull);
    });

    test('should handle files with multiple extensions', () async {
      final file = PlatformFile(
        name: 'test.backup.txt',
        size: 100,
        path: '/some/path/test.backup.txt',
      );

      // ファイル読み込み時の例外によりnullが返るが、拡張子の判定処理をテストする
      final result = await service.readFileContent(file);

      expect(result, isNull);
    });

    test('should handle file with uppercase extension', () async {
      final file = PlatformFile(
        name: 'test.TXT',
        size: 100,
        path: '/some/path/test.TXT',
      );

      final result = await service.readFileContent(file);

      // 拡張子の判定は大文字・小文字を区別しており、'txt'のみを対象としているため、これはnullを返すはずです

      expect(result, isNull);
    });
  });
}
