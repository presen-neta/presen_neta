import 'package:google_generative_ai/google_generative_ai.dart';

/// Google Generative AIを使用してプレゼンテーションを分析するサービス
class GeminiService {
  late final GenerativeModel _model;

  /// GeminiServiceのコンストラクタ
  ///
  /// APIキーは環境変数から取得するか、直接渡すことができます
  GeminiService({String? apiKey}) {
    // 実際の実装では、環境変数や設定ファイルからAPIキーを取得
    final key = apiKey ?? 'your_api_key_here';
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: key,
    );
  }

  /// プレゼンテーション内容を分析する
  ///
  /// [content] 分析対象のプレゼンテーション内容
  /// 分析結果の文字列を返す
  Future<String> analyzePresentation(String content) async {
    try {
      final prompt = Content.text('''
以下のプレゼンテーション内容を分析し、以下の観点で評価してください：

1. 内容の明確性（0-100点）
2. 視聴者の興味を引く度合い（0-100点）
3. 構造の論理性（0-100点）
4. 視覚的な分かりやすさ（0-100点）
5. 推定される「寝た率」（0-100%）

改善提案も含めて回答してください。

プレゼンテーション内容：
$content
''');

      final response = await _model.generateContent([prompt]);
      return response.text ?? '分析に失敗しました';
    } catch (e) {
      return 'エラーが発生しました: $e';
    }
  }

  /// ストリーミングでプレゼンテーションを分析する
  ///
  /// [content] 分析対象のプレゼンテーション内容
  /// [onData] データを受信した時のコールバック
  Future<void> analyzePresentationStream(
    String content,
    void Function(String) onData,
  ) async {
    try {
      final prompt = Content.text('''
以下のプレゼンテーション内容を分析し、以下の観点で評価してください：

1. 内容の明確性（0-100点）
2. 視聴者の興味を引く度合い（0-100点）
3. 構造の論理性（0-100点）
4. 視覚的な分かりやすさ（0-100点）
5. 推定される「寝た率」（0-100%）

改善提案も含めて回答してください。

プレゼンテーション内容：
$content
''');

      final response = _model.generateContentStream([prompt]);

      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null) {
          onData(text);
        }
      }
    } catch (e) {
      onData('エラーが発生しました: $e');
    }
  }

  /// トークン数をカウントする
  ///
  /// [content] カウント対象のコンテンツ
  /// トークン数を返す
  Future<int> countTokens(String content) async {
    try {
      final prompt = Content.text(content);
      final tokenCount = await _model.countTokens([prompt]);
      return tokenCount.totalTokens;
    } catch (e) {
      return 0;
    }
  }
}
