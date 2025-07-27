import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/shared/service/interfaces/file_picker_service_interface.dart';

/// FilePickerServiceのモッククラス。
///
/// テスト時に実際のファイル選択処理をシミュレートする。
class MockFilePickerService extends Mock implements FilePickerServiceInterface {
  /// モック用のPDFファイルデータ。
  static const List<int> mockPdfData = [0x25, 0x50, 0x44, 0x46]; // %PDF

  @override
  Future<FilePickerResult?> pickFile() async {
    // モックのPDFファイルを作成
    final mockFile = PlatformFile(
      name: 'test_presentation.pdf',
      size: mockPdfData.length,
      bytes: Uint8List.fromList(mockPdfData),
    );

    return FilePickerResult([mockFile]);
  }

  @override
  Future<Uint8List?> readPdfFileContent(PlatformFile file) async {
    if (file.extension == 'pdf') {
      return Uint8List.fromList(mockPdfData);
    }
    return null;
  }
}
