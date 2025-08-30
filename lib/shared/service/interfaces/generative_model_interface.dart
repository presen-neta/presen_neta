import 'package:google_generative_ai/google_generative_ai.dart';

/// テストを可能にするためのGenerateContentResponseのインターフェース
abstract class GenerateContentResponseInterface {
  /// 生成されたテキストコンテンツ
  String? get text;

  /// 生成候補のリスト
  List<Candidate> get candidates;

  /// プロンプトフィードバック情報
  PromptFeedback? get promptFeedback;

  /// 使用量メタデータ
  UsageMetadata? get usageMetadata;

  /// 関数呼び出しの情報
  Iterable<FunctionCall> get functionCalls;
}

/// テストを可能にするためのCountTokensResponseのインターフェース
abstract class CountTokensResponseInterface {
  /// 総トークン数
  int get totalTokens;
}

/// テストを可能にするためのGenerativeModelのインターフェース
abstract class GenerativeModelInterface {
  /// コンテンツを生成する
  ///
  /// [prompt] 生成に使用するプロンプトのリスト
  /// 戻り値: 生成されたコンテンツのレスポンス
  Future<GenerateContentResponseInterface> generateContent(
    List<Content> prompt,
  );

  /// プロンプトのトークン数をカウントする
  ///
  /// [prompt] カウント対象のプロンプトのリスト
  /// 戻り値: トークン数のレスポンス
  Future<CountTokensResponseInterface> countTokens(List<Content> prompt);
}

/// GenerateContentResponseのラッパー実装
class GenerateContentResponseWrapper
    implements GenerateContentResponseInterface {
  /// コンストラクタ
  ///
  /// [_response] ラップするGenerateContentResponse
  GenerateContentResponseWrapper(this._response);
  final GenerateContentResponse _response;

  @override
  /// 生成されたテキストコンテンツ
  String? get text => _response.text;

  @override
  /// 生成候補のリスト
  List<Candidate> get candidates => _response.candidates;

  @override
  /// プロンプトフィードバック情報
  PromptFeedback? get promptFeedback => _response.promptFeedback;

  @override
  /// 使用量メタデータ
  UsageMetadata? get usageMetadata => _response.usageMetadata;

  @override
  /// 関数呼び出しの情報
  Iterable<FunctionCall> get functionCalls => _response.functionCalls;
}

/// CountTokensResponseのラッパー実装
class CountTokensResponseWrapper implements CountTokensResponseInterface {
  /// コンストラクタ
  ///
  /// [_response] ラップするCountTokensResponse
  CountTokensResponseWrapper(this._response);
  final CountTokensResponse _response;

  @override
  /// 総トークン数
  int get totalTokens => _response.totalTokens;
}

/// 実際のGenerativeModelのラッパー実装
class GenerativeModelWrapper implements GenerativeModelInterface {
  /// コンストラクタ
  ///
  /// [_model] ラップするGenerativeModel
  GenerativeModelWrapper(this._model);
  final GenerativeModel _model;

  @override
  /// コンテンツを生成する
  ///
  /// [prompt] 生成に使用するプロンプトのリスト
  /// 戻り値: 生成されたコンテンツのレスポンス
  Future<GenerateContentResponseInterface> generateContent(
    List<Content> prompt,
  ) async {
    final response = await _model.generateContent(prompt);
    return GenerateContentResponseWrapper(response);
  }

  @override
  /// プロンプトのトークン数をカウントする
  ///
  /// [prompt] カウント対象のプロンプトのリスト
  /// 戻り値: トークン数のレスポンス
  Future<CountTokensResponseInterface> countTokens(List<Content> prompt) async {
    final response = await _model.countTokens(prompt);
    return CountTokensResponseWrapper(response);
  }
}
