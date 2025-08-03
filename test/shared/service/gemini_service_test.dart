import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:presen_neta/shared/service/gemini_service.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';
import 'package:presen_neta/shared/models/review_result.dart';

/// Test implementation of GeminiService for testing purposes
class TestGeminiService implements GeminiServiceInterface {
  String? mockResponse;
  bool shouldThrowError = false;
  String? errorMessage;

  @override
  Future<ReviewResult> analyzeMultipleSlideImages(
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
      throw FormatException('Invalid JSON');
    }

    // Parse the mock response
    final Map<String, dynamic> jsonData;
    try {
      jsonData = {
        'point': 85,
        'good': ['スライドの構成が分かりやすい', '視覚的に魅力的'],
        'improve': ['より詳細な説明が必要', 'フォントサイズを大きく']
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
    } catch (e) {
      throw FormatException('Failed to parse JSON: $e');
    }

    return ReviewResult.fromJson(jsonData);
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
        final result = await geminiService.analyzeMultipleSlideImages(imageDataList);

        // Assert
        expect(result, isA<ReviewResult>());
        expect(result.point, 85);
        expect(result.good, contains("スライドの構成が分かりやすい"));
        expect(result.improve, contains("より詳細な説明が必要"));
      });

      test('should handle invalid JSON response', () async {
        // Arrange
        final imageDataList = [Uint8List.fromList([1, 2, 3, 4])];
        
        geminiService.mockResponse = 'Invalid JSON response';

        // Act & Assert
        expect(
          () => geminiService.analyzeMultipleSlideImages(imageDataList),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle empty response', () async {
        // Arrange
        final imageDataList = [Uint8List.fromList([1, 2, 3, 4])];
        
        geminiService.mockResponse = null;

        // Act & Assert
        expect(
          () => geminiService.analyzeMultipleSlideImages(imageDataList),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle model generation exception', () async {
        // Arrange
        final imageDataList = [Uint8List.fromList([1, 2, 3, 4])];
        
        geminiService.shouldThrowError = true;
        geminiService.errorMessage = 'API Error';

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
        final result = await geminiService.analyzeMultipleSlideImages(imageDataList);

        // Assert
        expect(result.point, 75);
        expect(result.good, contains("複数スライドの一貫性"));
        expect(result.improve, contains("スライド間のつながりを改善"));
      });

      test('should use custom MIME type', () async {
        // Arrange
        final imageDataList = [Uint8List.fromList([1, 2, 3, 4])];
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
        expect(result.point, 80);
        expect(result.good, contains("テスト"));
        expect(result.improve, contains("テスト"));
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
}