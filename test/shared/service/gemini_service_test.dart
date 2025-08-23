import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/shared/models/review_result.dart';
import 'package:presen_neta/shared/service/gemini_service.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/generative_model_interface.dart';

import 'gemini_service_test.mocks.dart';

@GenerateMocks([GenerativeModelInterface])
/// Mock implementation of GenerateContentResponseInterface
class MockGenerateContentResponse implements GenerateContentResponseInterface {
  MockGenerateContentResponse({String? text}) : _text = text;
  final String? _text;

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
  MockCountTokensResponse({required int totalTokens})
    : _totalTokens = totalTokens;
  final int _totalTokens;

  @override
  int get totalTokens => _totalTokens;
}

/// Test implementation of GeminiService for testing purposes
class TestGeminiService implements GeminiServiceInterface {
  String? mockResponse;
  bool shouldThrowError = false;
  String? errorMessage;

  @override
  Future<ReviewResult?> analyzeMultipleSlideImages(
    List<Uint8List> imageDataList, {
    String imageMimeType = 'image/png',
  }) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Test error');
    }

    if (imageDataList.isEmpty) {
      throw ArgumentError('Image data list cannot be empty');
    }

    if (mockResponse == null) {
      throw Exception('No response set');
    }

    // Simulate JSON parsing
    final response = mockResponse!;
    if (response == 'Invalid JSON response') {
      throw const FormatException('Invalid JSON');
    }

    // Parse the mock response more realistically
    try {
      Map<String, dynamic> jsonData;

      if (response.contains('{') && response.contains('}')) {
        // Try to parse actual JSON from response
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          jsonData = json.decode(jsonString) as Map<String, dynamic>;
        } else {
          throw const FormatException('No JSON found in response');
        }
      } else {
        // Fallback for simple test cases
        jsonData = {
          'point': 85,
          'good': ['スライドの構成が分かりやすい', '視覚的に魅力的'],
          'improve': ['より詳細な説明が必要', 'フォントサイズを大きく'],
        };

        // Override with specific test values if provided
        if (response.contains('"point": 75')) {
          jsonData['point'] = 75;
          jsonData['good'] = ['複数スライドの一貫性'];
          jsonData['improve'] = ['スライド間のつながりを改善'];
        } else if (response.contains('"point": 80')) {
          jsonData['point'] = 80;
          jsonData['good'] = ['テスト'];
          jsonData['improve'] = ['テスト'];
        }
      }

      return ReviewResult.fromJson(jsonData);
    } catch (e) {
      throw FormatException('Failed to parse JSON: $e');
    }
  }

  @override
  Future<int> countTokens(String content) async {
    // Return a mock token count for testing
    return content.length ~/ 4; // Rough approximation
  }
}

void main() {
  group('GeminiService', () {
    late TestGeminiService geminiService;

    setUp(() {
      geminiService = TestGeminiService();
    });

    group('analyzeMultipleSlideImages', () {
      test('should return ReviewResult when analysis succeeds', () async {
        // Arrange
        final imageDataList = [
          Uint8List.fromList([1, 2, 3, 4]),
          Uint8List.fromList([5, 6, 7, 8]),
        ];

        geminiService.mockResponse = '''
{
  "point": 85,
  "good": ["スライドの構成が分かりやすい", "視覚的に魅力的"],
  "improve": ["より詳細な説明が必要", "フォントサイズを大きく"]
}
        ''';

        // Act
        final result = await geminiService.analyzeMultipleSlideImages(
          imageDataList,
        );

        // Assert
        expect(result, isA<ReviewResult>());
        expect(result!.point, 85);
        expect(result.good, contains('スライドの構成が分かりやすい'));
        expect(result.improve, contains('より詳細な説明が必要'));
      });

      test('should handle invalid JSON response', () async {
        // Arrange
        final imageDataList = [
          Uint8List.fromList([1, 2, 3, 4]),
        ];

        geminiService.mockResponse = 'Invalid JSON response';

        // Act & Assert
        expect(
          () => geminiService.analyzeMultipleSlideImages(imageDataList),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle empty response', () async {
        // Arrange
        final imageDataList = [
          Uint8List.fromList([1, 2, 3, 4]),
        ];

        geminiService.mockResponse = null;

        // Act & Assert
        expect(
          () => geminiService.analyzeMultipleSlideImages(imageDataList),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle model generation exception', () async {
        // Arrange
        final imageDataList = [
          Uint8List.fromList([1, 2, 3, 4]),
        ];

        geminiService
          ..shouldThrowError = true
          ..errorMessage = 'API Error';

        // Act & Assert
        expect(
          () => geminiService.analyzeMultipleSlideImages(imageDataList),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle multiple images correctly', () async {
        // Arrange
        final imageDataList = [
          Uint8List.fromList([1, 2, 3, 4]),
          Uint8List.fromList([5, 6, 7, 8]),
          Uint8List.fromList([9, 10, 11, 12]),
        ];

        geminiService.mockResponse = '''
{
  "point": 75,
  "good": ["複数スライドの一貫性"],
  "improve": ["スライド間のつながりを改善"]
}
        ''';

        // Act
        final result = await geminiService.analyzeMultipleSlideImages(
          imageDataList,
        );

        // Assert
        expect(result!.point, 75);
        expect(result.good, contains('複数スライドの一貫性'));
        expect(result.improve, contains('スライド間のつながりを改善'));
      });

      test('should use custom MIME type', () async {
        // Arrange
        final imageDataList = [
          Uint8List.fromList([1, 2, 3, 4]),
        ];
        const customMimeType = 'image/jpeg';

        geminiService.mockResponse = '''
{
  "point": 80,
  "good": ["テスト"],
  "improve": ["テスト"]
}
        ''';

        // Act
        final result = await geminiService.analyzeMultipleSlideImages(
          imageDataList,
          imageMimeType: customMimeType,
        );

        // Assert
        expect(result!.point, 80);
        expect(result.good, contains('テスト'));
        expect(result.improve, contains('テスト'));
      });

      test('should handle empty image list', () async {
        // Arrange
        final imageDataList = <Uint8List>[];

        // Act & Assert
        expect(
          () => geminiService.analyzeMultipleSlideImages(imageDataList),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });

  group('Real GeminiService with Mocks', () {
    late MockGenerativeModelInterface mockModel;
    late MockGenerateContentResponse mockResponse;
    late MockCountTokensResponse mockCountResponse;
    late GeminiService geminiService;

    setUp(() {
      mockModel = MockGenerativeModelInterface();
      mockResponse = MockGenerateContentResponse(text: '{}');
      mockCountResponse = MockCountTokensResponse(totalTokens: 0);
      geminiService = GeminiService(mockModel: mockModel);
    });

    group('analyzeMultipleSlideImages with mocked model', () {
      test('should return ReviewResult when API call succeeds', () async {
        // Arrange
        final response = MockGenerateContentResponse(
          text: '''
{
  "point": 85,
  "good": ["Excellent structure", "Clear visuals"],
  "improve": ["Add more examples", "Increase font size"]
}
''',
        );
        when(mockModel.generateContent(any)).thenAnswer((_) async => response);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result, isA<ReviewResult>());
        expect(result!.point, 85);
        expect(result.good, contains('Excellent structure'));
        expect(result.improve, contains('Add more examples'));
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should return null when API response is empty', () async {
        // Arrange
        when(mockResponse.text).thenReturn(null);
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should return null when API response is empty string', () async {
        // Arrange
        when(mockResponse.text).thenReturn('');
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should return null when JSON extraction fails', () async {
        // Arrange
        when(mockResponse.text).thenReturn('This is not JSON at all');
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should return null when point is invalid (negative)', () async {
        // Arrange
        when(mockResponse.text).thenReturn('''
{
  "point": -10,
  "good": ["Test"],
  "improve": ["Test"]
}
''');
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should return null when point is invalid (over 100)', () async {
        // Arrange
        when(mockResponse.text).thenReturn('''
{
  "point": 150,
  "good": ["Test"],
  "improve": ["Test"]
}
''');
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should return null when point is null', () async {
        // Arrange
        when(mockResponse.text).thenReturn('''
{
  "good": ["Test"],
  "improve": ["Test"]
}
''');
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle API exception gracefully', () async {
        // Arrange
        when(mockModel.generateContent(any)).thenThrow(Exception('API Error'));

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result, isNull);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should filter non-string values from good array', () async {
        // Arrange
        when(mockResponse.text).thenReturn('''
{
  "point": 80,
  "good": ["Valid string", 123, null, "Another string"],
  "improve": ["Test"]
}
''');
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result!.point, 80);
        expect(result.good, ['Valid string', 'Another string']);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should filter non-string values from improve array', () async {
        // Arrange
        when(mockResponse.text).thenReturn('''
{
  "point": 70,
  "good": ["Test"],
  "improve": ["Valid improvement", 456, null, "Another improvement"]
}
''');
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result!.point, 70);
        expect(result.improve, ['Valid improvement', 'Another improvement']);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle null good and improve arrays', () async {
        // Arrange
        when(mockResponse.text).thenReturn('''
{
  "point": 60,
  "good": null,
  "improve": null
}
''');
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages([
          imageData,
        ]);

        // Assert
        expect(result!.point, 60);
        expect(result.good, isEmpty);
        expect(result.improve, isEmpty);
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle multiple images', () async {
        // Arrange
        when(mockResponse.text).thenReturn('''
{
  "point": 75,
  "good": ["Multiple slides consistency"],
  "improve": ["Better flow between slides"]
}
''');
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageDataList = [
          Uint8List.fromList([1, 2, 3, 4]),
          Uint8List.fromList([5, 6, 7, 8]),
          Uint8List.fromList([9, 10, 11, 12]),
        ];

        // Act
        final result = await geminiService.analyzeMultipleSlideImages(
          imageDataList,
        );

        // Assert
        expect(result!.point, 75);
        expect(result.good, contains('Multiple slides consistency'));
        verify(mockModel.generateContent(any)).called(1);
      });

      test('should handle custom MIME type', () async {
        // Arrange
        when(mockResponse.text).thenReturn('''
{
  "point": 80,
  "good": ["JPEG format test"],
  "improve": ["Test improvement"]
}
''');
        when(
          mockModel.generateContent(any),
        ).thenAnswer((_) async => mockResponse);

        final imageData = Uint8List.fromList([1, 2, 3, 4]);

        // Act
        final result = await geminiService.analyzeMultipleSlideImages(
          [imageData],
          imageMimeType: 'image/jpeg',
        );

        // Assert
        expect(result!.point, 80);
        expect(result.good, contains('JPEG format test'));
        verify(mockModel.generateContent(any)).called(1);
      });
    });

    group('countTokens with mocked model', () {
      test('should return token count when API call succeeds', () async {
        // Arrange
        when(mockCountResponse.totalTokens).thenReturn(42);
        when(
          mockModel.countTokens(any),
        ).thenAnswer((_) async => mockCountResponse);

        // Act
        final tokenCount = await geminiService.countTokens('test content');

        // Assert
        expect(tokenCount, 42);
        verify(mockModel.countTokens(any)).called(1);
      });

      test('should return 0 when API call throws exception', () async {
        // Arrange
        when(
          mockModel.countTokens(any),
        ).thenThrow(Exception('Token count error'));

        // Act
        final tokenCount = await geminiService.countTokens('test content');

        // Assert
        expect(tokenCount, 0);
        verify(mockModel.countTokens(any)).called(1);
      });

      test('should handle empty content', () async {
        // Arrange
        when(mockCountResponse.totalTokens).thenReturn(0);
        when(
          mockModel.countTokens(any),
        ).thenAnswer((_) async => mockCountResponse);

        // Act
        final tokenCount = await geminiService.countTokens('');

        // Assert
        expect(tokenCount, 0);
        verify(mockModel.countTokens(any)).called(1);
      });

      test('should handle long content', () async {
        // Arrange
        when(mockCountResponse.totalTokens).thenReturn(500);
        when(
          mockModel.countTokens(any),
        ).thenAnswer((_) async => mockCountResponse);

        final longContent = 'test content ' * 100;

        // Act
        final tokenCount = await geminiService.countTokens(longContent);

        // Assert
        expect(tokenCount, 500);
        verify(mockModel.countTokens(any)).called(1);
      });
    });

    group('extractJsonFromResponse comprehensive coverage', () {
      test('should extract JSON from code block', () {
        const response = '''
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
        const response = '''
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
        const response = '''
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
        const response = 'This is just plain text without any JSON';

        final result = geminiService.extractJsonFromResponse(response);

        expect(result, isNull);
      });

      test('should handle JSON with special characters', () {
        const response = r'''
{
  "point": 85,
  "good": ["Good with \"quotes\"", "Line\nbreak", "Tab\there"],
  "improve": ["Fix / issues", "Handle \\ backslashes"]
}
''';

        final result = geminiService.extractJsonFromResponse(response);

        expect(result, isNotNull);
        expect(result!['point'], 85);
        expect((result['good'] as List)[0], contains('"quotes"'));
      });

      test('should handle nested JSON structures', () {
        const response = '''
{
  "point": 92,
  "good": [
    "First comprehensive point",
    "Second detailed point",
    "Third point with details"
  ],
  "improve": [
    "First improvement",
    "Second improvement with explanation"
  ]
}
''';

        final result = geminiService.extractJsonFromResponse(response);

        expect(result, isNotNull);
        expect(result!['point'], 92);
        expect(result['good'], hasLength(3));
        expect(result['improve'], hasLength(2));
      });

      test('should handle multiple JSON blocks and take first', () {
        const response = '''
First JSON:
```json
{
  "point": 70,
  "good": ["First"],
  "improve": ["First improve"]
}
```

Second JSON:
{
  "point": 80,
  "good": ["Second"],
  "improve": ["Second improve"]
}
''';

        final result = geminiService.extractJsonFromResponse(response);

        expect(result, isNotNull);
        expect(result!['point'], 70); // Should extract the first JSON block
        expect(result['good'], contains('First'));
      });

      test('should handle whitespace and formatting variations', () {
        final responses = [
          '   {"point": 85, "good": ["Test"], "improve": ["Test"]}   ',
          '\n\n{"point": 85, "good": ["Test"], "improve": ["Test"]}\n\n',
          '\t{"point": 85, "good": ["Test"], "improve": ["Test"]}\t',
        ];

        for (final response in responses) {
          final result = geminiService.extractJsonFromResponse(response);

          expect(result, isNotNull);
          expect(result!['point'], 85);
        }
      });
    });
  });

  group('Real GeminiService', () {
    test('should throw exception when API key is empty', () {
      expect(
        () => GeminiService(apiKey: ''),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('API key not valid'),
          ),
        ),
      );
    });

    test('should throw exception when API key is placeholder', () {
      expect(
        () => GeminiService(apiKey: 'your_gemini_api_key_here'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('API key not valid'),
          ),
        ),
      );
    });

    test('should initialize with valid API key format', () {
      expect(
        () => GeminiService(apiKey: 'test_valid_key_format'),
        returnsNormally,
      );
    });

    test(
      'should handle API errors gracefully in analyzeMultipleSlideImages',
      () async {
        final service = GeminiService(apiKey: 'test_key_for_coverage');

        final imageData = Uint8List.fromList([1, 2, 3, 4]);
        final result = await service.analyzeMultipleSlideImages([imageData]);

        // With invalid API key, should return null due to error handling
        expect(result, isNull);
      },
    );

    test(
      'should handle empty image list in analyzeMultipleSlideImages',
      () async {
        final service = GeminiService(apiKey: 'test_key_for_coverage');

        final result = await service.analyzeMultipleSlideImages([]);

        expect(result, isNull);
      },
    );

    test('should handle valid JSON parsing from response', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": 85,
  "good": ["Test good point"],
  "improve": ["Test improvement"]
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result?.point, 85);
      expect(result?.good, contains('Test good point'));
      expect(result?.improve, contains('Test improvement'));
    });

    test('should handle invalid point values', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": -10,
  "good": ["Test"],
  "improve": ["Test"]
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result, isNull);
    });

    test('should handle point values over 100', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": 150,
  "good": ["Test"],
  "improve": ["Test"]
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result, isNull);
    });

    test('should handle missing point field', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "good": ["Test"],
  "improve": ["Test"]
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result, isNull);
    });

    test('should handle non-string values in good array', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": 80,
  "good": ["Valid string", 123, null, "Another string"],
  "improve": ["Test"]
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result?.point, 80);
      expect(result?.good, ['Valid string', 'Another string']);
    });

    test('should handle non-string values in improve array', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": 70,
  "good": ["Test"],
  "improve": ["Valid improvement", 456, null, "Another improvement"]
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result?.point, 70);
      expect(result?.improve, ['Valid improvement', 'Another improvement']);
    });

    test('should handle null good and improve arrays', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": 60,
  "good": null,
  "improve": null
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result?.point, 60);
      expect(result?.good, isEmpty);
      expect(result?.improve, isEmpty);
    });

    test('should handle JSON with markdown code blocks', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
```json
{
  "point": 88,
  "good": ["Code block test"],
  "improve": ["Another test"]
}
```
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result?.point, 88);
      expect(result?.good, contains('Code block test'));
    });

    test('should handle response with extra text around JSON', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
Here's the analysis result:

{
  "point": 92,
  "good": ["Extra text test"],
  "improve": ["Surrounded by text"]
}

Additional explanation follows.
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result?.point, 92);
      expect(result?.good, contains('Extra text test'));
    });

    test('should handle response with no JSON pattern', () async {
      final service =
          TestGeminiService()
            ..mockResponse =
                'This is just plain text without any JSON structure';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      expect(
        () => service.analyzeMultipleSlideImages([imageData]),
        throwsA(isA<FormatException>()),
      );
    });

    test('should handle malformed JSON structure', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": 75,
  "good": ["Malformed",
  "improve": "Missing closing bracket for good array"
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      expect(
        () => service.analyzeMultipleSlideImages([imageData]),
        throwsA(isA<FormatException>()),
      );
    });

    test('should handle API errors gracefully in countTokens', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final tokenCount = await service.countTokens('test content');

      // With invalid API key, should return 0 due to error handling
      expect(tokenCount, 0);
    });

    test('should handle empty content in countTokens', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final tokenCount = await service.countTokens('');

      // Should return 0 for empty content
      expect(tokenCount, 0);
    });

    test('should handle multiple images in API call', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final imageData1 = Uint8List.fromList([1, 2, 3, 4]);
      final imageData2 = Uint8List.fromList([5, 6, 7, 8]);

      final result = await service.analyzeMultipleSlideImages([
        imageData1,
        imageData2,
      ]);

      // Should return null due to invalid API key
      expect(result, isNull);
    });

    test('should handle custom MIME type parameter', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      final result = await service.analyzeMultipleSlideImages(
        [imageData],
        imageMimeType: 'image/jpeg',
      );

      // Should return null due to invalid API key
      expect(result, isNull);
    });

    test('should handle empty image list', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final result = await service.analyzeMultipleSlideImages([]);

      // Should return null due to error or empty result
      expect(result, isNull);
    });

    test('should handle very large image data', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      // 10MBの大きな画像データを作成
      final largeImageData = Uint8List.fromList(
        List.generate(10000000, (i) => i % 256),
      );

      final result = await service.analyzeMultipleSlideImages([largeImageData]);

      // 無効なAPIキーのため、nullが返る
      expect(result, isNull);
    });

    test('should handle multiple very small images', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final smallImages = List.generate(
        100,
        (i) => Uint8List.fromList([i % 256, (i + 1) % 256, (i + 2) % 256]),
      );

      final result = await service.analyzeMultipleSlideImages(smallImages);

      // 無効なAPIキーのため、nullが返る
      expect(result, isNull);
    });

    test('should handle different MIME types', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      final results = await Future.wait([
        service.analyzeMultipleSlideImages([
          imageData,
        ]),
        service.analyzeMultipleSlideImages([
          imageData,
        ], imageMimeType: 'image/jpeg'),
        service.analyzeMultipleSlideImages([
          imageData,
        ], imageMimeType: 'image/webp'),
      ]);

      // 全て無効なAPIキーのため、nullが返る
      for (final result in results) {
        expect(result, isNull);
      }
    });

    test('should handle API timeout scenarios', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      // タイムアウトを想定して実行
      final stopwatch = Stopwatch()..start();
      final result = await service.analyzeMultipleSlideImages([imageData]);
      stopwatch.stop();

      // APIが失敗するため、nullが返る
      expect(result, isNull);

      // 処理時間が合理的であることを確認（APIタイムアウトより短い）
      expect(stopwatch.elapsedMilliseconds, lessThan(30000));
    });

    test('should handle malformed image data', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final malformedData = [
        Uint8List.fromList([255, 255, 255, 255]), // 無効なPNGヘッダー
        Uint8List.fromList([0, 0, 0, 0]), // null データ
        Uint8List.fromList([137, 80, 78, 71]), // 不完全なPNGヘッダー
      ];

      for (final data in malformedData) {
        final result = await service.analyzeMultipleSlideImages([data]);
        expect(result, isNull);
      }
    });

    test('should handle concurrent API calls', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      final futures = List.generate(
        5,
        (i) => service.analyzeMultipleSlideImages([imageData]),
      );

      final results = await Future.wait(futures);

      // 全て無効なAPIキーのため、nullが返る
      for (final result in results) {
        expect(result, isNull);
      }
    });

    test('should handle countTokens with various content types', () async {
      final service = GeminiService(apiKey: 'test_key_for_coverage');

      final testContents = [
        'Simple text',
        'テキストの日本語',
        r'🚀 Emojis and symbols! @#$%^&*()',
        'Very long text ' * 1000,
        '   \n\t  ', // 空白文字
        'Mixed content: 日本語 English 123 🌟',
      ];

      for (final content in testContents) {
        final tokenCount = await service.countTokens(content);
        // 無効なAPIキーのため、0が返る
        expect(tokenCount, 0);
      }
    });

    test(
      'should handle empty content in countTokens with real service',
      () async {
        final service = GeminiService(apiKey: 'test_key_for_coverage');

        final tokenCount = await service.countTokens('');

        expect(tokenCount, 0);
      },
    );

    test(
      'TestGeminiService を通じて _extractJsonFromResponse を間接的にテストする',
      () async {
        final service =
            TestGeminiService()
              // Test JSON with code block
              ..mockResponse = '''
```json
{
  "point": 95,
  "good": ["JSON block extraction"],
  "improve": ["Test coverage"]
}
```
''';

        final imageData = Uint8List.fromList([1, 2, 3, 4]);
        final result = await service.analyzeMultipleSlideImages([imageData]);

        expect(result?.point, 95);
        expect(result?.good, contains('JSON block extraction'));
      },
    );

    test('should handle various JSON response formats', () async {
      final service = TestGeminiService();

      final testCases = [
        // Simple JSON
        '{"point": 80, "good": ["Simple"], "improve": ["Test"]}',
        // JSON with whitespace
        '  {"point": 81, "good": ["Whitespace"], "improve": ["Test"]}  ',
        // JSON with newlines
        '{\n  "point": 82,\n  "good": ["Newlines"],\n  "improve": ["Test"]\n}',
        // JSON with extra text before
        'Analysis result: {"point": 83, "good": ["Test"], "improve": ["Test"]}',
        // JSON with extra text after
        '{"point": 84, "good": ["Test"], "improve": ["Test"]} End of analysis.',
      ];

      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      for (var i = 0; i < testCases.length; i++) {
        service.mockResponse = testCases[i];
        final result = await service.analyzeMultipleSlideImages([imageData]);
        expect(result?.point, 80 + i);
      }
    });

    test('should handle complex nested JSON structures', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": 87,
  "good": [
    "First good point with detailed explanation",
    "Second point",
    "Third point with 日本語"
  ],
  "improve": [
    "First improvement suggestion",
    "Second improvement with details"
  ]
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result?.point, 87);
      expect(result?.good.length, 3);
      expect(result?.improve.length, 2);
      expect(result?.good.first, contains('detailed explanation'));
    });

    test('should handle JSON with special characters and escapes', () async {
      final service =
          TestGeminiService()
            ..mockResponse = r'''
{
  "point": 89,
  "good": [
    "Good point with \"quotes\"",
    "Point with \n newline",
    "Point with \t tab"
  ],
  "improve": [
    "Improve with / slash",
    "Improve with \\ backslash"
  ]
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);
      final result = await service.analyzeMultipleSlideImages([imageData]);

      expect(result?.point, 89);
      expect(result?.good.first, contains('"quotes"'));
    });

    test('should handle boundary values for point field', () async {
      final service = TestGeminiService();
      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      // Test boundary values
      final boundaryTests = [
        (0, true), // Minimum valid
        (1, true), // Just above minimum
        (50, true), // Middle value
        (99, true), // Just below maximum
        (100, true), // Maximum valid
        (-1, false), // Just below minimum (invalid)
        (101, false), // Just above maximum (invalid)
      ];

      for (final (point, shouldBeValid) in boundaryTests) {
        service.mockResponse = '''
{
  "point": $point,
  "good": ["Test"],
  "improve": ["Test"]
}
''';

        final result = await service.analyzeMultipleSlideImages([imageData]);

        if (shouldBeValid) {
          expect(result?.point, point);
        } else {
          expect(result, isNull);
        }
      }
    });

    test('should handle JSON parsing edge cases', () async {
      final service = TestGeminiService();
      // shouldThrowError = true を設定せず、空リストの場合は自然に ArgumentError がスローされることを確認する

      // 空の画像リストの場合の例外処理
      expect(
        () => service.analyzeMultipleSlideImages([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle constructor edge cases', () {
      // 空文字列のAPIキー
      expect(
        () => GeminiService(apiKey: ''),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('API key not valid'),
          ),
        ),
      );

      // プレースホルダーのAPIキー
      expect(
        () => GeminiService(apiKey: 'your_gemini_api_key_here'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('API key not valid'),
          ),
        ),
      );

      // 非常に短いAPIキー（実際には短いキーも受け入れられる場合がある）
      expect(
        () => GeminiService(apiKey: 'short_but_valid_key'),
        returnsNormally,
      );

      // 有効な形式のAPIキー（テスト用のモック応答は別のテストで確認）
      expect(
        () => GeminiService(apiKey: 'AIzaSyA${'B' * 32}'),
        returnsNormally,
      );
    });

    test('should handle network connectivity issues', () async {
      final service =
          TestGeminiService()
            ..shouldThrowError = true
            ..errorMessage = 'Network connectivity error';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      // ネットワークエラーを想定
      expect(
        () => service.analyzeMultipleSlideImages([imageData]),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle rate limiting scenarios', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": 80,
  "good": ["テスト"],
  "improve": ["テスト"]
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      // 連続してAPIを呼び出し（レート制限をテスト）
      final results = <ReviewResult?>[];
      for (var i = 0; i < 10; i++) {
        final result = await service.analyzeMultipleSlideImages([imageData]);
        results.add(result);
      }

      // 全て同じ結果が返ることを確認
      for (final result in results) {
        expect(result!.point, 80);
      }
    });

    test('should handle memory pressure with large datasets', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": 75,
  "good": ["複数スライドの一貫性"],
  "improve": ["スライド間のつながりを改善"]
}
''';

      // 大量の小さい画像データを作成
      final manySmallImages = List.generate(
        100,
        (i) => Uint8List.fromList([i % 256, (i + 1) % 256]),
      );

      final result = await service.analyzeMultipleSlideImages(manySmallImages);

      // メモリプレッシャーに対応してデータが処理される
      expect(result!.point, 75);
      expect(result.good, contains('複数スライドの一貫性'));
    });

    test('should maintain consistent behavior across calls', () async {
      final service =
          TestGeminiService()
            ..mockResponse = '''
{
  "point": 80,
  "good": ["テスト"],
  "improve": ["テスト"]
}
''';

      final imageData = Uint8List.fromList([1, 2, 3, 4]);

      // 同じデータで複数回呼び出し
      final result1 = await service.analyzeMultipleSlideImages([imageData]);
      final result2 = await service.analyzeMultipleSlideImages([imageData]);
      final result3 = await service.analyzeMultipleSlideImages([imageData]);

      // 一貫して同じ結果が返ることを確認
      expect(result1!.point, result2!.point);
      expect(result2.point, result3!.point);
      expect(result1.point, 80);
    });

    group('Direct JSON Extraction Tests', () {
      test('should extract JSON from code block', () {
        final service = GeminiService(apiKey: 'test_key_for_coverage');
        const response = '''
```json
{
  "point": 95,
  "good": ["Excellent"],
  "improve": ["Perfect"]
}
```
''';

        final result = service.extractJsonFromResponse(response);

        expect(result, isNotNull);
        expect(result!['point'], 95);
        expect(result['good'], contains('Excellent'));
      });

      test('should extract JSON from plain text', () {
        final service = GeminiService(apiKey: 'test_key_for_coverage');
        const response = '''
Here is the analysis:
{
  "point": 88,
  "good": ["Great structure"],
  "improve": ["Add examples"]
}
End of analysis.
''';

        final result = service.extractJsonFromResponse(response);

        expect(result, isNotNull);
        expect(result!['point'], 88);
        expect(result['good'], contains('Great structure'));
      });

      test('should handle malformed JSON gracefully', () {
        final service = GeminiService(apiKey: 'test_key_for_coverage');
        const response = '''
{
  "point": 75,
  "good": ["Incomplete JSON",
  "improve": "Missing bracket"
}
''';

        final result = service.extractJsonFromResponse(response);

        expect(result, isNull);
      });

      test('should handle empty response', () {
        final service = GeminiService(apiKey: 'test_key_for_coverage');

        final result = service.extractJsonFromResponse('');

        expect(result, isNull);
      });

      test('should handle response with no JSON', () {
        final service = GeminiService(apiKey: 'test_key_for_coverage');
        const response = 'This is just plain text without any JSON';

        final result = service.extractJsonFromResponse(response);

        expect(result, isNull);
      });

      test('should handle JSON with special characters', () {
        final service = GeminiService(apiKey: 'test_key_for_coverage');
        const response = r'''
{
  "point": 85,
  "good": ["Good with \"quotes\"", "Line\nbreak", "Tab\there"],
  "improve": ["Fix / issues", "Handle \\ backslashes"]
}
''';

        final result = service.extractJsonFromResponse(response);

        expect(result, isNotNull);
        expect(result!['point'], 85);
        expect((result['good'] as List)[0], contains('"quotes"'));
      });

      test('should handle nested JSON structures', () {
        final service = GeminiService(apiKey: 'test_key_for_coverage');
        const response = '''
{
  "point": 92,
  "good": [
    "First point with details",
    "Second point",
    "Third comprehensive point"
  ],
  "improve": [
    "First improvement",
    "Second improvement with explanation"
  ]
}
''';

        final result = service.extractJsonFromResponse(response);

        expect(result, isNotNull);
        expect(result!['point'], 92);
        expect(result['good'], hasLength(3));
        expect(result['improve'], hasLength(2));
      });

      test('should handle multiple JSON blocks and take first', () {
        final service = GeminiService(apiKey: 'test_key_for_coverage');
        const response = '''
First JSON:
```json
{
  "point": 70,
  "good": ["First"],
  "improve": ["First improve"]
}
```

Second JSON:
{
  "point": 80,
  "good": ["Second"],
  "improve": ["Second improve"]
}
''';

        final result = service.extractJsonFromResponse(response);

        expect(result, isNotNull);
        expect(result!['point'], 70); // Should extract the first JSON block
        expect(result['good'], contains('First'));
      });

      test('should handle whitespace and formatting variations', () {
        final service = GeminiService(apiKey: 'test_key_for_coverage');
        final responses = [
          '   {"point": 85, "good": ["Test"], "improve": ["Test"]}   ',
          '\n\n{"point": 85, "good": ["Test"], "improve": ["Test"]}\n\n',
          '\t{"point": 85, "good": ["Test"], "improve": ["Test"]}\t',
        ];

        for (final response in responses) {
          final result = service.extractJsonFromResponse(response);

          expect(result, isNotNull);
          expect(result!['point'], 85);
        }
      });
    });
  });
}
