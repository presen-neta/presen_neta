import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_result.freezed.dart';
part 'review_result.g.dart';

/// プレゼンテーション評価結果を表すモデルクラス
@freezed
abstract class ReviewResult with _$ReviewResult {
  /// ReviewResultのコンストラクタ
  const factory ReviewResult({
    /// プレゼンテーションの点数（0-100）
    required int point,

    /// 良い点のリスト
    required List<String> good,

    /// 改善点のリスト
    required List<String> improve,
  }) = _ReviewResult;

  /// JSONからReviewResultを作成するファクトリメソッド
  factory ReviewResult.fromJson(Map<String, dynamic> json) =>
      _$ReviewResultFromJson(json);
}

/// ReviewResultの拡張メソッド
extension ReviewResultExtension on ReviewResult {
  /// 寝た率を計算する
  ///
  /// 100点から点数を引いた値を返す
  int get sleepRate => 100 - point;
}
