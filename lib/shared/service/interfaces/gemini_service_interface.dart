import 'dart:typed_data';
import 'package:presen_neta/shared/models/review_result.dart';

/// Gemini AI を使用したプレゼンテーション分析機能のインターフェース。
///
/// テスト時にモックに置き換え可能にするための抽象化。
abstract class GeminiServiceInterface {
  /// 複数のスライド画像を分析して構造化された評価結果を取得する。
  ///
  /// [imageDataList] 分析対象の画像データのリスト（Uint8List）
  /// [imageMimeType] 画像のMIMEタイプ（デフォルト: 'image/png'）
  /// 構造化された評価結果を返す
  Future<ReviewResult?> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  });

  /// トークン数をカウントする。
  ///
  /// [content] カウント対象のコンテンツ
  /// トークン数を返す
  Future<int> countTokens(String content);
}
