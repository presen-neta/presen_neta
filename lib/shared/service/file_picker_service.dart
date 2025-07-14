import 'package:file_picker/file_picker.dart';

/// ファイル選択処理をラップするサービス。
///
/// [pickFile] でファイル選択ダイアログを表示し、選択結果を返す。
class FilePickerService {
  /// ファイルピッカーを起動し、選択結果を返す。
  ///
  /// 選択された場合は [FilePickerResult]、キャンセル時は null を返す。
  Future<FilePickerResult?> pickFile() {
    return FilePicker.platform.pickFiles();
  }
}
