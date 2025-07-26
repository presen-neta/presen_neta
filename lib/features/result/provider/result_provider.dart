import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:presen_neta/shared/service/gemini_service.dart';

part 'result_provider.g.dart';

/// GeminiServiceのプロバイダー
@riverpod
GeminiService geminiService(GeminiServiceRef ref) {
  return GeminiService();
}

/// 分析結果の状態管理プロバイダー
@riverpod
class AnalysisNotifier extends _$AnalysisNotifier {
  @override
  Future<String> build() async {
    return '';
  }

  /// コンテンツを分析する
  ///
  /// [content] 分析対象のコンテンツ
  Future<void> analyzeContent(String content) async {
    state = const AsyncValue.loading();
    try {
      final geminiService = ref.read(geminiServiceProvider);
      final result = await geminiService.analyzePresentation(content);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// ストリーミングでコンテンツを分析する
  ///
  /// [content] 分析対象のコンテンツ
  /// [onData] データを受信した時のコールバック
  Future<void> analyzeContentStream(
    String content,
    void Function(String) onData,
  ) async {
    state = const AsyncValue.loading();
    try {
      final geminiService = ref.read(geminiServiceProvider);
      await geminiService.analyzePresentationStream(content, onData);
      // ストリーミング完了後、最終的な状態を更新
      state = const AsyncValue.data('分析完了');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 分析結果をリセットする
  void reset() {
    state = const AsyncValue.loading();
  }
}
