import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/shared/models/review_result.dart';
import 'package:presen_neta/shared/service/gemini_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'result_provider.g.dart';

/// GeminiServiceのプロバイダー
@riverpod
GeminiService geminiService(Ref ref) {
  return GeminiService();
}

/// 分析結果の状態管理プロバイダー
@riverpod
class AnalysisNotifier extends _$AnalysisNotifier {
  @override
  Future<ReviewResult?> build() async {
    return null;
  }

  /// スライド画像を分析する
  ///
  /// [imageData] 分析対象の画像データ
  /// [imageMimeType] 画像のMIMEタイプ（デフォルト: 'image/png'）
  Future<void> analyzeSlideImage(
    Uint8List imageData, {
    String imageMimeType = 'image/png',
  }) async {
    state = const AsyncValue<ReviewResult?>.loading();
    try {
      final geminiService = ref.read(geminiServiceProvider);
      final result = await geminiService.analyzeSlideImage(
        imageData,
        imageMimeType: imageMimeType,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 分析結果をリセットする
  void reset() {
    state = const AsyncValue<ReviewResult?>.loading();
  }
}
