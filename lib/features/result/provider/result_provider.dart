import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/shared/service/gemini_service.dart';

/// GeminiServiceのプロバイダー
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

/// 分析結果の状態管理プロバイダー
final analysisResultProvider =
    StateNotifierProvider<AnalysisNotifier, AsyncValue<String>>((ref) {
      return AnalysisNotifier(ref.read(geminiServiceProvider));
    });

/// 分析結果を管理するStateNotifier
class AnalysisNotifier extends StateNotifier<AsyncValue<String>> {
  final GeminiService _geminiService;

  /// AnalysisNotifierのコンストラクタ
  AnalysisNotifier(this._geminiService) : super(const AsyncValue.loading());

  /// コンテンツを分析する
  ///
  /// [content] 分析対象のコンテンツ
  Future<void> analyzeContent(String content) async {
    state = const AsyncValue.loading();
    try {
      final result = await _geminiService.analyzePresentation(content);
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
      await _geminiService.analyzePresentationStream(content, onData);
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
