import 'dart:typed_data';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/shared/providers/service_providers.dart';
import 'package:presen_neta/shared/service/interfaces/file_picker_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';
import 'package:presen_neta/shared/models/review_result.dart';
import '../service/mocks/mock_file_picker_service.dart';
import '../service/mocks/mock_gemini_service.dart';
import '../service/mocks/mock_presentation_analysis_service.dart';

/// テスト用のFilePickerServiceプロバイダー。
///
/// モックインスタンスを返すようにオーバーライドする。
final testFilePickerServiceProvider = Provider<FilePickerServiceInterface>((
  ref,
) {
  return MockFilePickerService();
});

/// テスト用のGeminiServiceプロバイダー。
///
/// モックインスタンスを返すようにオーバーライドする。
final testGeminiServiceProvider = Provider<GeminiServiceInterface>((ref) {
  return MockGeminiService();
});

/// テスト用のPresentationAnalysisServiceプロバイダー。
///
/// モックインスタンスを返すようにオーバーライドする。
final testPresentationAnalysisServiceProvider =
    Provider<PresentationAnalysisServiceInterface>((ref) {
      return MockPresentationAnalysisService();
    });

/// テスト用のプロバイダーオーバーライドリスト。
///
/// テスト時に実際のサービスをモックに置き換える。
final List<Override> testServiceOverrides = [
  filePickerServiceProvider.overrideWith((ref) => MockFilePickerService()),
  geminiServiceProvider.overrideWith((ref) => MockGeminiService()),
  presentationAnalysisServiceProvider.overrideWith(
    (ref) => MockPresentationAnalysisService(),
  ),
  // 分析結果プロバイダーもリセット状態でオーバーライド
  analysisNotifierProvider.overrideWith(() => TestAnalysisNotifier()),
];

/// テスト用のAnalysisNotifier
class TestAnalysisNotifier extends AnalysisNotifier {
  ReviewResult? _mockResult;
  bool _shouldThrowError = false;

  @override
  Future<ReviewResult?> build() async {
    return null;
  }

  @override
  void reset() {
    state = const AsyncValue<ReviewResult?>.data(null);
  }

  void setLoading() {
    state = const AsyncValue<ReviewResult?>.loading();
  }

  void setData(ReviewResult? result) {
    _mockResult = result;
    state = AsyncValue<ReviewResult?>.data(result);
  }

  void setError(Object error, StackTrace stackTrace) {
    _shouldThrowError = true;
    state = AsyncValue<ReviewResult?>.error(error, stackTrace);
  }

  @override
  Future<void> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  }) async {
    state = const AsyncValue<ReviewResult?>.loading();

    // テスト用の遅延をシミュレート
    await Future<void>.delayed(const Duration(milliseconds: 10));

    if (_shouldThrowError) {
      state = AsyncValue<ReviewResult?>.error(
        Exception('Test error'),
        StackTrace.current,
      );
      return;
    }

    // モック結果がない場合は、デフォルトの結果を返す
    final result =
        _mockResult ??
        const ReviewResult(
          point: 75,
          good: ['テスト用の良い点'],
          improve: ['テスト用の改善点'],
        );

    state = AsyncValue<ReviewResult?>.data(result);
  }
}
