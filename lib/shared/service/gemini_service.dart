import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';
import 'package:presen_neta/shared/config/env_config.dart';
import 'package:presen_neta/shared/models/review_result.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';

/// Google Generative AIを使用してプレゼンテーションを分析するサービス
class GeminiService implements GeminiServiceInterface {
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
    );
  }

  /// 三輪開人さんの『共感プレゼン』に基づく評価用プロンプト
  static const String _empathyPresentationPrompt = '''
次のスライド資料を、三輪開人さんの『共感プレゼン』の考え方に基づいてレビューしてください。
特に以下の2点を中心に評価してください：
1. ゴールと聞き手の明確化（誰に、何を、なぜ伝えたいのかが明確か）
2. スライドの構成と視覚表現（共感を呼ぶストーリー性、余白、言葉の選び方）
レビューの結果、点数（100点満点で非常に厳しくつける）、100文字以内で良い点3つ、100文字以内で改善点3つを考えてください。
必ず次の形式でJSONとして返答してください：
{
  "point": 整数,
  "good": ["良い点1", "良い点2", "良い点3"],
  "improve": ["改善点1", "改善点2", "改善点3"]
}
JSON以外の説明は不要です。必ず有効なJSON形式で返答してください。
''';

  late final GenerativeModel _model;
  final Logger _logger = Logger();

  /// 複数のスライド画像を分析して構造化された評価結果を取得する
  ///
  /// [imageDataList] 分析対象の画像データのリスト（Uint8List）
  /// [imageMimeType] 画像のMIMEタイプ（デフォルト: 'image/png'）
  /// 構造化された評価結果を返す
  @override
  Future<ReviewResult?> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  }) async {
    try {
      _logger
        ..i('複数スライド画像分析開始')
        ..d('画像数: ${imageDataList.length}枚');

      final contentParts = <Part>[
        TextPart(_empathyPresentationPrompt),
      ];

      // 各画像をDataPartとして追加
      for (final imageData in imageDataList) {
        contentParts.add(DataPart(imageMimeType, imageData));
      }

      final response = await _model.generateContent([
        Content.multi(contentParts),
      ]);

      final responseText = response.text;
      _logger.d('Geminiレスポンス: $responseText');

      if (responseText == null || responseText.isEmpty) {
        _logger.w('レスポンステキストが空です');
        return null;
      }

      // JSONを抽出して解析
      final jsonResult = _extractJsonFromResponse(responseText);
      if (jsonResult == null) {
        _logger.w('JSONの抽出に失敗しました');
        return null;
      }

      final point = jsonResult['point'] as int?;
      final goodList =
          (jsonResult['good'] as List<dynamic>?)?.whereType<String>().toList();
      final improveList =
          (jsonResult['improve'] as List<dynamic>?)
              ?.whereType<String>()
              .toList();

      if (point == null || point < 0 || point > 100) {
        _logger.w('無効な点数: $point');
        return null;
      }

      final result = ReviewResult(
        point: point,
        good: goodList ?? [],
        improve: improveList ?? [],
      );

      _logger
        ..i('複数スライド画像分析完了: ${result.point}点')
        ..d('良い点: ${result.good.length}個, 改善点: ${result.improve.length}個');

      return result;
    } on Exception catch (e) {
      _logger.e('複数スライド画像分析エラー: $e');
      return null;
    }
  }

  /// レスポンステキストからJSONを抽出する
  ///
  /// [responseText] Geminiからのレスポンステキスト
  /// 抽出されたJSONオブジェクトを返す。抽出に失敗した場合はnullを返す
  Map<String, dynamic>? _extractJsonFromResponse(String responseText) {
    try {
      // レスポンステキストをクリーンアップ
      final cleanedText = responseText.trim();

      // JSONブロックを探す（```json で囲まれている場合）
      final jsonBlockPattern = RegExp(
        r'```(?:json)?\s*(\{.*?\})\s*```',
        dotAll: true,
      );
      final jsonBlockMatch = jsonBlockPattern.firstMatch(cleanedText);

      if (jsonBlockMatch != null) {
        final jsonString = jsonBlockMatch.group(1);
        if (jsonString != null) {
          return json.decode(jsonString) as Map<String, dynamic>;
        }
      }

      // JSONブロックが見つからない場合、テキスト全体をJSONとして解析
      final jsonPattern = RegExp(r'\{.*\}', dotAll: true);
      final jsonMatch = jsonPattern.firstMatch(cleanedText);

      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0);
        if (jsonString != null) {
          return json.decode(jsonString) as Map<String, dynamic>;
        }
      }

      _logger.w('JSONパターンが見つかりませんでした');
      return null;
    } on Exception catch (e) {
      _logger.e('JSON解析エラー: $e');
      return null;
    }
  }

  /// トークン数をカウントする
  ///
  /// [content] カウント対象のコンテンツ
  /// トークン数を返す
  @override
  Future<int> countTokens(String content) async {
    try {
      _logger.d('トークン数カウント開始: ${content.length}文字');

      final prompt = Content.text(content);
      final tokenCount = await _model.countTokens([prompt]);

      _logger.i('トークン数カウント完了: ${tokenCount.totalTokens}トークン');
      return tokenCount.totalTokens;
    } on Exception catch (e) {
      _logger.e('トークン数カウントエラー: $e');
      return 0;
    }
  }
}
