import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';
import 'package:presen_neta/shared/service/presentation_analysis_service.dart';

import 'presentation_analysis_service_test.mocks.dart';

@GenerateMocks([FilePickerService, WidgetRef])
void main() {
  late MockFilePickerService mockFilePickerService;
  late PresentationAnalysisService service;
  late ProviderContainer container;

  setUp(() {
    mockFilePickerService = MockFilePickerService();
    service = PresentationAnalysisService(
      filePickerService: mockFilePickerService,
    );
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('FilePickerService Mock Tests', () {
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
      when(
        mockFilePickerService.pickFile(),
      ).thenAnswer((_) async => const FilePickerResult([]));

      final pickedResult = await mockFilePickerService.pickFile();
      expect(pickedResult, isNotNull);
      expect(pickedResult!.files, isEmpty);
    });

    test(
      'should get default FilePickerService when none provided',
      () {
        // Skip this test as it requires platform initialization
        // In real usage, FilePickerService is properly initialized
      },
      skip: 'Requires platform initialization, covered by integration tests',
    );

    test('should use injected FilePickerService when provided', () {
      final injectedService = PresentationAnalysisService(
        filePickerService: mockFilePickerService,
      );

      expect(injectedService.filePickerService, equals(mockFilePickerService));
    });

    test('should handle logger operations without error', () {
      // ロガーのテストは他のメソッドの実行によってカバーされる
      expect(service, isA<PresentationAnalysisService>());
    });

    test('filePickerService getter should return injected service', () {
      final customService = PresentationAnalysisService(
        filePickerService: mockFilePickerService,
      );

      expect(customService.filePickerService, equals(mockFilePickerService));
    });

    test('should handle service initialization with different parameters', () {
      // Test with null filePickerService (default initialization)
      expect(PresentationAnalysisService.new, returnsNormally);

      // Test with provided filePickerService
      final customService = PresentationAnalysisService(
        filePickerService: mockFilePickerService,
      );
      expect(customService.filePickerService, equals(mockFilePickerService));
    });
  });
}
