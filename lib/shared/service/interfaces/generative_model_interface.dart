import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Interface for GenerateContentResponse to enable testing
abstract class GenerateContentResponseInterface {
  String? get text;
  List<Candidate> get candidates;
  PromptFeedback? get promptFeedback;
  UsageMetadata? get usageMetadata;
  Iterable<FunctionCall> get functionCalls;
}

/// Interface for CountTokensResponse to enable testing
abstract class CountTokensResponseInterface {
  int get totalTokens;
}

/// Interface for GenerativeModel to enable testing
abstract class GenerativeModelInterface {
  Future<GenerateContentResponseInterface> generateContent(List<Content> prompt);
  Future<CountTokensResponseInterface> countTokens(List<Content> prompt);
}

/// Wrapper implementation for GenerateContentResponse
class GenerateContentResponseWrapper implements GenerateContentResponseInterface {
  final GenerateContentResponse _response;

  GenerateContentResponseWrapper(this._response);

  @override
  String? get text => _response.text;

  @override
  List<Candidate> get candidates => _response.candidates;

  @override
  PromptFeedback? get promptFeedback => _response.promptFeedback;

  @override
  UsageMetadata? get usageMetadata => _response.usageMetadata;

  @override
  Iterable<FunctionCall> get functionCalls => _response.functionCalls;
}

/// Wrapper implementation for CountTokensResponse
class CountTokensResponseWrapper implements CountTokensResponseInterface {
  final CountTokensResponse _response;

  CountTokensResponseWrapper(this._response);

  @override
  int get totalTokens => _response.totalTokens;
}

/// Wrapper implementation for the real GenerativeModel
class GenerativeModelWrapper implements GenerativeModelInterface {
  final GenerativeModel _model;

  GenerativeModelWrapper(this._model);

  @override
  Future<GenerateContentResponseInterface> generateContent(List<Content> prompt) async {
    final response = await _model.generateContent(prompt);
    return GenerateContentResponseWrapper(response);
  }

  @override
  Future<CountTokensResponseInterface> countTokens(List<Content> prompt) async {
    final response = await _model.countTokens(prompt);
    return CountTokensResponseWrapper(response);
  }
}