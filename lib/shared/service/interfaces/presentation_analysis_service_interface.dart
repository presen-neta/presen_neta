import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プレゼンテーション分析処理を担当するサービスのインターフェース。
///
/// テスト時にモックに置き換え可能にするための抽象化。
abstract class PresentationAnalysisServiceInterface {
  /// PDFファイルを選択し、分析を実行する。
  ///
  /// [context] はエラー表示に利用される。async gap 後の利用は mounted でガードする。
  /// [ref] Riverpodのref
  /// 分析成功時は true、失敗時は false を返す。
  Future<bool> analyzePdfFile(BuildContext context, WidgetRef ref);
}
