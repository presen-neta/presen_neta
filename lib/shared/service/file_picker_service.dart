import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:presen_neta/shared/service/interfaces/file_picker_service_interface.dart';

/// ファイル選択処理をラップするサービス。
///
/// [pickFile] でファイル選択ダイアログを表示し、選択結果を返す。
class FilePickerService implements FilePickerServiceInterface {
  /// [FilePicker] を注入できるコンストラクタ。
  ///
  /// 通常利用時は [FilePicker.platform] を利用する。
  FilePickerService({FilePicker? filePicker})
    : _filePicker = filePicker ?? FilePicker.platform;

  /// 内部で利用する [FilePicker] インスタンス。
  final FilePicker _filePicker;

  /// ピッカーが現在起動中かどうかを示すフラグ。
  bool _isPicking = false;

  /// PDFファイルピッカーを起動し、選択結果を返す。
  ///
  /// 選択された場合は [FilePickerResult]、キャンセル時は null を返す。
  /// 2重起動を防止する。
  @override
  Future<FilePickerResult?> pickFile() async {
    if (_isPicking) {
      // すでに起動中の場合は null を返す。
      return null;
    }
    _isPicking = true;
    try {
      return await _filePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    } finally {
      _isPicking = false;
    }
  }

  /// ファイルの内容を読み取る
  ///
  /// [file] 読み取るファイル
  /// ファイルの内容を文字列で返す
  Future<String?> readFileContent(PlatformFile file) async {
    try {
      if (file.extension == 'txt' && file.path != null) {
        final fileContent = File(file.path!);
        return await fileContent.readAsString();
      }
      // PDFやPPTの場合は別途ライブラリが必要
      // 現在はテキストファイルのみ対応
      return null;
    } on Exception {
      return null;
    }
  }

  /// PDFファイルの内容をバイトデータとして読み取る
  ///
  /// [file] 読み取るファイル
  /// ファイルの内容をバイトデータで返す
  @override
  Future<Uint8List?> readPdfFileContent(PlatformFile file) async {
    try {
      // Prioritize bytes property if available (useful for testing and when withData: true)
      if (file.bytes != null) {
        return file.bytes!;
      }
      
      // Fall back to reading from file path
      if (file.extension == 'pdf' && file.path != null) {
        final fileContent = File(file.path!);
        return await fileContent.readAsBytes();
      }
      
      return null;
    } on Exception {
      return null;
    }
  }
}
