import 'package:hooks_riverpod/hooks_riverpod.dart';
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

  /// 分析結果をリセットする
  void reset() {
    state = const AsyncValue.loading();
  }
}
