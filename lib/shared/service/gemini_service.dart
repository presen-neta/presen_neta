import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';
import 'package:presen_neta/shared/config/env_config.dart';

/// Google Generative AIを使用してプレゼンテーションを分析するサービス
class GeminiService {
  late final GenerativeModel _model;
  final Logger _logger = Logger();

  /// GeminiServiceのコンストラクタ
  ///
  /// APIキーは環境変数から取得するか、直接渡すことができます
  GeminiService({String? apiKey}) {
    // 環境変数からAPIキーを取得
    final key = apiKey ?? EnvConfig.geminiApiKey;

    // デバッグ用：APIキーが設定されているかチェック
    if (key.isEmpty || key == 'your_gemini_api_key_here') {
      final errorMessage = 'API key not valid. Please pass a valid API key.';
      _logger.e('GeminiService初期化エラー: $errorMessage');
      throw Exception(errorMessage);
    }

    _logger.i('GeminiService初期化完了');
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
      _logger.i('プレゼンテーション分析開始');
      _logger.d('分析対象コンテンツ: ${content.length}文字');

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
      final result = response.text ?? '分析に失敗しました';

      _logger.i('プレゼンテーション分析完了');
      _logger.d('分析結果: ${result.length}文字');

      return result;
    } catch (e) {
      final errorMessage = 'エラーが発生しました: $e';
      _logger.e('プレゼンテーション分析エラー: $e');
      return errorMessage;
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
      _logger.i('ストリーミング分析開始');
      _logger.d('分析対象コンテンツ: ${content.length}文字');

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
          _logger.d('ストリーミングデータ受信: ${text.length}文字');
          onData(text);
        }
      }

      _logger.i('ストリーミング分析完了');
    } catch (e) {
      final errorMessage = 'エラーが発生しました: $e';
      _logger.e('ストリーミング分析エラー: $e');
      onData(errorMessage);
    }
  }

  /// トークン数をカウントする
  ///
  /// [content] カウント対象のコンテンツ
  /// トークン数を返す
  Future<int> countTokens(String content) async {
    try {
      _logger.d('トークン数カウント開始: ${content.length}文字');

      final prompt = Content.text(content);
      final tokenCount = await _model.countTokens([prompt]);

      _logger.i('トークン数カウント完了: ${tokenCount.totalTokens}トークン');
      return tokenCount.totalTokens;
    } catch (e) {
      _logger.e('トークン数カウントエラー: $e');
      return 0;
    }
  }
}
