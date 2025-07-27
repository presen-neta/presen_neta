import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';
import 'package:presen_neta/shared/config/env_config.dart';
import 'package:presen_neta/shared/models/review_result.dart';

/// Google Generative AIを使用してプレゼンテーションを分析するサービス
class GeminiService {
  /// GeminiServiceのコンストラクタ
  ///
  /// APIキーは環境変数から取得するか、直接渡すことができます
  GeminiService({String? apiKey}) {
    // 環境変数からAPIキーを取得
    final key = apiKey ?? EnvConfig.geminiApiKey;

    // デバッグ用：APIキーが設定されているかチェック
    if (key.isEmpty || key == 'your_gemini_api_key_here') {
      const errorMessage = 'API key not valid. Please pass a valid API key.';
      _logger.e('GeminiService初期化エラー: $errorMessage');
      throw Exception(errorMessage);
    }

    _logger.i('GeminiService初期化完了');
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: key,
      generationConfig: GenerationConfig(temperature: 0.4),
      tools: [
        Tool(
          functionDeclarations: [
            FunctionDeclaration(
              'setReview',
              'スライドの良い点、改善点、点数をまとめて返す',
              Schema(
                SchemaType.object,
                properties: {
                  'point': Schema(
                    SchemaType.integer,
                    description: 'プレゼンの点数（0〜100）',
                  ),
                  'good': Schema(
                    SchemaType.array,
                    items: Schema(SchemaType.string),
                    description: '良い点（3つまで）',
                  ),
                  'improve': Schema(
                    SchemaType.array,
                    items: Schema(SchemaType.string),
                    description: '改善点（3つまで）',
                  ),
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// プレゼンテーション分析用のプロンプトテンプレート
  static const String _presentationAnalysisPrompt = '''
以下のプレゼンテーション内容を分析し、以下の観点で評価してください：

1. 内容の明確性（0-100点）
2. 視聴者の興味を引く度合い（0-100点）
3. 構造の論理性（0-100点）
4. 視覚的な分かりやすさ（0-100点）
5. 推定される「寝た率」（0-100%）

改善提案も含めて回答してください。

プレゼンテーション内容：
{content}
''';

  /// 三輪開人さんの『共感プレゼン』に基づく評価用プロンプト
  static const String _empathyPresentationPrompt = '''
次のスライド資料を、三輪開人さんの『共感プレゼン』の考え方に基づいてレビューしてください。
特に以下の2点を中心に評価してください：
1. ゴールと聞き手の明確化（誰に、何を、なぜ伝えたいのかが明確か）
2. スライドの構成と視覚表現（共感を呼ぶストーリー性、余白、言葉の選び方、手書き風要素など）
レビューの結果、点数（100点満点）、良い点3つ、改善点3つを考えてください。
必ず次の形式でJSONとして返答してください：
{
  "point": 整数,
  "good": ["良い点1", "良い点2", "良い点3"],
  "improve": ["改善点1", "改善点2", "改善点3"]
}
''';

  late final GenerativeModel _model;
  final Logger _logger = Logger();

  /// スライド画像を分析して構造化された評価結果を取得する
  ///
  /// [imageData] 分析対象の画像データ（Uint8List）
  /// [imageMimeType] 画像のMIMEタイプ（デフォルト: 'image/png'）
  /// 構造化された評価結果を返す
  Future<ReviewResult?> analyzeSlideImage(
    Uint8List imageData, {
    String imageMimeType = 'image/png',
  }) async {
    try {
      _logger.i('スライド画像分析開始');
      _logger.d('画像サイズ: ${imageData.length}バイト');

      final response = await _model.generateContent([
        Content.multi([
          TextPart(_empathyPresentationPrompt),
          DataPart(imageMimeType, imageData),
        ]),
      ]);

      final functionCalls = response.functionCalls;
      if (functionCalls != null && functionCalls.isNotEmpty) {
        final call = functionCalls.firstWhere(
          (call) => call.name == 'setReview',
          orElse: () => functionCalls.first,
        );

        final args = call.args;
        final point = args['point'] as int?;
        final goodList =
            (args['good'] as List<dynamic>?)?.whereType<String>().toList();
        final improveList =
            (args['improve'] as List<dynamic>?)?.whereType<String>().toList();

        if (point != null) {
          final result = ReviewResult(
            point: point,
            good: goodList ?? [],
            improve: improveList ?? [],
          );

          _logger.i('スライド画像分析完了: ${result.point}点');
          _logger.d(
            '良い点: ${result.good.length}個, 改善点: ${result.improve.length}個',
          );

          return result;
        }
      }

      _logger.w('Function Callが見つからないか、無効なレスポンス');
      return null;
    } catch (e) {
      _logger.e('スライド画像分析エラー: $e');
      return null;
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
