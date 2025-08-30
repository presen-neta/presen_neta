import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

/// ファイル選択機能のインターフェース。
///
/// テスト時にモックに置き換え可能にするための抽象化。
abstract class FilePickerServiceInterface {
  /// PDFファイルを選択する。
  ///
  /// 選択されたファイル情報を返す。キャンセルされた場合はnullを返す。
  Future<FilePickerResult?> pickFile();

  /// PDFファイルの内容を読み取る。
  ///
  /// [file] 読み取り対象のファイル
  /// ファイルの内容をバイトデータとして返す。読み取りに失敗した場合はnullを返す。
  Future<Uint8List?> readPdfFileContent(PlatformFile file);
}
