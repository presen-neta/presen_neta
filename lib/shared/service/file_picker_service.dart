import 'package:file_picker/file_picker.dart';

/// ファイル選択処理をラップするサービス。
///
/// [pickFile] でファイル選択ダイアログを表示し、選択結果を返す。
class FilePickerService {
  /// [FilePicker] を注入できるコンストラクタ。
  ///
  /// 通常利用時は [FilePicker.platform] を利用する。
  FilePickerService({FilePicker? filePicker})
    : _filePicker = filePicker ?? FilePicker.platform;

  /// 内部で利用する [FilePicker] インスタンス。
  final FilePicker _filePicker;

  /// ファイルピッカーを起動し、選択結果を返す。
  ///
  /// 選択された場合は [FilePickerResult]、キャンセル時は null を返す。
  Future<FilePickerResult?> pickFile() {
    return _filePicker.pickFiles();
  }
}
