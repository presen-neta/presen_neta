import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プレゼンテーション分析処理を担当するサービスの抽象クラス。
///
/// テスト時にモックに置き換え可能にするための抽象化。
abstract class PresentationAnalysisServiceInterface {
  /// PDFファイルを選択し、分析を実行する。
  ///
  /// [context] はエラー表示に利用される。async gap 後の利用は mounted でガードする。
  /// [ref] Riverpodのref
  /// 分析成功時は true、失敗時は false を返す。
  Future<bool> analyzePdfFile(BuildContext context, WidgetRef ref);

  /// PDFデータを複数のPNG画像に変換する。
  ///
  /// [pdfData] 変換対象のPDFデータ
  /// 変換されたPNG画像のリストを返す。変換に失敗した場合は空のリストを返す。
  Future<List<Uint8List>> convertPdfToPngImages(Uint8List pdfData);
}
