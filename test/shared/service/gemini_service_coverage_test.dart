import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:presen_neta/shared/service/gemini_service.dart';
import 'package:presen_neta/shared/service/interfaces/generative_model_interface.dart';
import 'package:presen_neta/shared/models/review_result.dart';

import 'gemini_service_coverage_test.mocks.dart';

@GenerateMocks([GenerativeModelInterface])

/// Mock implementation of GenerateContentResponseInterface
class MockGenerateContentResponse implements GenerateContentResponseInterface {
  final String? _text;
  
  MockGenerateContentResponse({String? text}) : _text = text;
  
  @override
  String? get text => _text;
  
  @override
  List<Candidate> get candidates => [];
  
  @override
  PromptFeedback? get promptFeedback => null;
  
  @override
  UsageMetadata? get usageMetadata => null;
  
  @override
  Iterable<FunctionCall> get functionCalls => [];
}

/// Mock implementation of CountTokensResponseInterface
class MockCountTokensResponse implements CountTokensResponseInterface {
  final int _totalTokens;
  
  MockCountTokensResponse({required int totalTokens}) : _totalTokens = totalTokens;
  
  @override
  int get totalTokens => _totalTokens;
}

void main() {
  group('GeminiService Coverage Tests', () {
    late MockGenerativeModelInterface mockModel;
    late GeminiService geminiService;

    setUp(() {
      mockModel = MockGenerativeModelInterface();
      geminiService = GeminiService(mockModel: mockModel);
    });

    group('analyzeMultipleSlideImages with complete mock coverage', () {
      test('should execute all code paths with successful API response', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: '''
{
  "point": 85,
  "good": ["Excellent structure", "Clear visuals"],
  "improve": ["Add more examples", "Increase font size"]
}
''');
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([imageData]);

        // Assert
        expect(result, isA<ReviewResult>());
        expect(result!.point, 85);
        expect(result.good, contains("Excellent structure"));
        expect(result.improve, contains("Add more examples"));
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle null response text', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: null);
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([imageData]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle empty response text', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: '');
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([imageData]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle invalid JSON response', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: 'Invalid JSON');
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([imageData]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle invalid point value (negative)', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: '''
{
  "point": -10,
  "good": ["Test"],
  "improve": ["Test"]
}
''');
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([imageData]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle invalid point value (over 100)', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: '''
{
  "point": 150,
  "good": ["Test"],
  "improve": ["Test"]
}
''');
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([imageData]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle missing point field', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: '''
{
  "good": ["Test"],
  "improve": ["Test"]
}
''');
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([imageData]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle API exception', () async {
        // Arrange
        when(mockModel.generateContent(any)).thenThrow(Exception('API Error'));

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([imageData]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should filter non-string values from arrays', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: '''
{
  "point": 80,
  "good": ["Valid string", 123, null, "Another string"],
  "improve": ["Valid improvement", 456, null, "Another improvement"]
}
''');
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([imageData]);

        // Assert
        expect(result!.point, 80);
        expect(result.good, ["Valid string", "Another string"]);
        expect(result.improve, ["Valid improvement", "Another improvement"]);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle null arrays', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: '''
{
  "point": 60,
  "good": null,
  "improve": null
}
''');
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([imageData]);

        // Assert
        expect(result!.point, 60);
        expect(result.good, isEmpty);
        expect(result.improve, isEmpty);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle multiple images', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: '''
{
  "point": 75,
  "good": ["Multiple slides"],
  "improve": ["Better flow"]
}
''');
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageDataList = [
          Uint8List.fromList([1, 2, 3, 4]),
          Uint8List.fromList([5, 6, 7, 8]),
          Uint8List.fromList([9, 10, 11, 12]),
        ];

        // Act
        final result = await geminiService.analyzeMultipleSlideImages(imageDataList);

        // Assert
        expect(result!.point, 75);
        expect(result.good, contains("Multiple slides"));
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle custom MIME type', () async {
        // Arrange
        final response = MockGenerateContentResponse(text: '''
{
  "point": 80,
  "good": ["JPEG format"],
  "improve": ["Test"]
}
''');
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages(
          [imageData],
          imageMimeType: 'image/jpeg',
        );

        // Assert
        expect(result!.point, 80);
        expect(result.good, contains("JPEG format"));
        verify(mockModel.generateContent(any)).called(1);
      });
    });

    group('countTokens with complete mock coverage', () {
      test('should return token count when API call succeeds', () async {
        // Arrange
        final response = MockCountTokensResponse(totalTokens: 42);
        when(mockModel.countTokens(any)).thenAnswer((_) async => response);

        // Act
        final tokenCount = await geminiService.countTokens('test content');

        // Assert
        expect(tokenCount, 42);
        verify(mockModel.countTokens(any)).called(1);
      });

      test('should return 0 when API call throws exception', () async {
        // Arrange
        when(mockModel.countTokens(any)).thenThrow(Exception('Token count error'));

        // Act
        final tokenCount = await geminiService.countTokens('test content');

        // Assert
        expect(tokenCount, 0);
        verify(mockModel.countTokens(any)).called(1);
      });

      test('should handle empty content', () async {
        // Arrange
        final response = MockCountTokensResponse(totalTokens: 0);
        when(mockModel.countTokens(any)).thenAnswer((_) async => response);

        // Act
        final tokenCount = await geminiService.countTokens('');

        // Assert
        expect(tokenCount, 0);
        verify(mockModel.countTokens(any)).called(1);
      });
    });

    group('extractJsonFromResponse complete coverage', () {
      test('should extract JSON from code block', () {
        final response = '''
```json
{
  "point": 95,
  "good": ["Code block test"],
  "improve": ["Coverage test"]
}
```
''';
        
        final result = geminiService.extractJsonFromResponse(response);
        
        expect(result, isNotNull);
        expect(result!['point'], 95);
        expect(result['good'], contains('Code block test'));
      });

      test('should extract JSON from plain text', () {
        final response = '''
Analysis result:
{
  "point": 88,
  "good": ["Plain text test"],
  "improve": ["Extract test"]
}
End of analysis.
''';
        
        final result = geminiService.extractJsonFromResponse(response);
        
        expect(result, isNotNull);
        expect(result!['point'], 88);
        expect(result['good'], contains('Plain text test'));
      });

      test('should handle malformed JSON gracefully', () {
        final response = '''
{
  "point": 75,
  "good": ["Malformed",
  "improve": "Missing bracket"
}
''';
        
        final result = geminiService.extractJsonFromResponse(response);
        
        expect(result, isNull);
      });

      test('should handle empty response', () {
        final result = geminiService.extractJsonFromResponse('');
        expect(result, isNull);
      });

      test('should handle response with no JSON', () {
        final response = 'This is just plain text without any JSON';
        
        final result = geminiService.extractJsonFromResponse(response);
        
        expect(result, isNull);
      });

      test('should handle JSON pattern matching edge case', () {
        final response = '''
Some text before
{
  "point": 92,
  "good": ["Pattern test"],
  "improve": ["JSON extraction"]
}
Some text after
''';
        
        final result = geminiService.extractJsonFromResponse(response);
        
        expect(result, isNotNull);
        expect(result!['point'], 92);
      });

      test('should handle JSON block without language specifier', () {
        final response = '''
```
{
  "point": 85,
  "good": ["No language test"],
  "improve": ["Block test"]
}
```
''';
        
        final result = geminiService.extractJsonFromResponse(response);
        
        expect(result, isNotNull);
        expect(result!['point'], 85);
      });
    });

    group('Constructor coverage', () {
      test('should initialize with mock model', () {
        final service = GeminiService(mockModel: mockModel);
        expect(service, isA<GeminiService>());
      });

      test('should throw exception for empty API key', () {
        expect(
          () => GeminiService(apiKey: ''),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception for placeholder API key', () {
        expect(
          () => GeminiService(apiKey: 'your_gemini_api_key_here'),
          throwsA(isA<Exception>()),
        );
      });

      test('should initialize with valid API key', () {
        expect(
          () => GeminiService(apiKey: 'valid_test_key'),
          returnsNormally,
        );
      });
    });
  });
}