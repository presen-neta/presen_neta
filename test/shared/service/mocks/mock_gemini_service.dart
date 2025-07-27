import 'dart:typed_data';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/shared/models/review_result.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';

/// GeminiServiceのモッククラス。
///
/// テスト時に実際のAI分析処理をシミュレートする。
class MockGeminiService extends Mock implements GeminiServiceInterface {
  /// モック用の分析結果。
  static final ReviewResult mockReviewResult = ReviewResult(
    point: 75,
    good: [
      '目的が明確に示されている',
      '視覚的な構成が良い',
      '文字サイズが適切',
    ],
    improve: [
      '余白をより活用する',
      '色使いを統一する',
      '図表を追加する',
    ],
  );

  @override
  Future<ReviewResult?> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  }) async {
    // 画像データが空の場合はnullを返す
    if (imageDataList.isEmpty) {
      return null;
    }

    // モックの分析結果を返す
    return mockReviewResult;
  }

  @override
  Future<int> countTokens(String content) async {
    // 簡単なトークン数計算（実際のAIとは異なる）
    return content.length ~/ 4; // 概算
  }
}
