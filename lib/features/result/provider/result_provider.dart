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
    // 初期状態はnull（分析結果なし）
    return null;
  }

  /// 複数のスライド画像を分析する
  ///
  /// [imageDataList] 分析対象の画像データのリスト
  /// [imageMimeType] 画像のMIMEタイプ（デフォルト: 'image/png'）
  Future<void> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  }) async {
    state = const AsyncValue<ReviewResult?>.loading();
    try {
      final geminiService = ref.read(geminiServiceProvider);
      final result = await geminiService.analyzeMultipleSlideImages(
        imageDataList,
        imageMimeType: imageMimeType,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 分析結果をリセットする
  void reset() {
    // 初期状態（null）に戻す
    state = const AsyncValue<ReviewResult?>.data(null);
  }
}
