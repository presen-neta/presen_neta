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
        PlatformFile(name: 'test.txt', size: 1),
      ]);
      when(mockFilePicker.pickFiles()).thenAnswer((_) async => result);
      final picked = await service.pickFile();
      expect(picked, isNotNull);
      expect(picked!.files.first.name, 'test.txt');
    });

    test('ファイル選択がキャンセルされた場合、nullを返す', () async {
      when(mockFilePicker.pickFiles()).thenAnswer((_) async => null);
      final picked = await service.pickFile();
      expect(picked, isNull);
    });

    test('複数ファイルが選択された場合、最初のファイルを返す', () async {
      final result = FilePickerResult([
        PlatformFile(name: 'first.txt', size: 1),
        PlatformFile(name: 'second.txt', size: 2),
      ]);
      when(mockFilePicker.pickFiles()).thenAnswer((_) async => result);
      final picked = await service.pickFile();
      expect(picked, isNotNull);
      expect(picked!.files.first.name, 'first.txt');
    });

    test('空のファイルリストが返された場合、FilePickerResultを返す', () async {
      const result = FilePickerResult([]);
      when(mockFilePicker.pickFiles()).thenAnswer((_) async => result);
      final picked = await service.pickFile();
      expect(picked, isNotNull);
      expect(picked!.files, isEmpty);
    });

    test('pickFilesが例外を投げた場合、nullを返す', () async {
      when(mockFilePicker.pickFiles()).thenThrow(Exception('Test exception'));
      final picked = await service.pickFile();
      expect(picked, isNull);
    });
  });
}
