import 'package:flutter_test/flutter_test.dart';
import 'package:presen_neta/shared/models/review_result.dart';

void main() {
  group('ReviewResult', () {
    test('should create a ReviewResult with all parameters', () {
      const reviewResult = ReviewResult(
        point: 85,
        good: ['良い点1', '良い点2'],
        improve: ['改善点1', '改善点2'],
      );

      expect(reviewResult.point, 85);
      expect(reviewResult.good, ['良い点1', '良い点2']);
      expect(reviewResult.improve, ['改善点1', '改善点2']);
    });

    test('should create a ReviewResult with empty lists', () {
      const reviewResult = ReviewResult(
        point: 50,
        good: [],
        improve: [],
      );

      expect(reviewResult.point, 50);
      expect(reviewResult.good, isEmpty);
      expect(reviewResult.improve, isEmpty);
    });

    test('should serialize to JSON correctly', () {
      const reviewResult = ReviewResult(
        point: 75,
        good: ['良い点'],
        improve: ['改善点'],
      );

      final json = reviewResult.toJson();

      expect(json['point'], 75);
      expect(json['good'], ['良い点']);
      expect(json['improve'], ['改善点']);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'point': 90,
        'good': ['素晴らしい'],
        'improve': ['なし'],
      };

      final reviewResult = ReviewResult.fromJson(json);

      expect(reviewResult.point, 90);
      expect(reviewResult.good, ['素晴らしい']);
      expect(reviewResult.improve, ['なし']);
    });

    test('should support equality comparison', () {
      const reviewResult1 = ReviewResult(
        point: 80,
        good: ['良い'],
        improve: ['改善'],
      );
      
      const reviewResult2 = ReviewResult(
        point: 80,
        good: ['良い'],
        improve: ['改善'],
      );

      const reviewResult3 = ReviewResult(
        point: 70,
        good: ['良い'],
        improve: ['改善'],
      );

      expect(reviewResult1, reviewResult2);
      expect(reviewResult1, isNot(reviewResult3));
    });

    test('should generate proper hash code', () {
      const reviewResult1 = ReviewResult(
        point: 80,
        good: ['良い'],
        improve: ['改善'],
      );
      
      const reviewResult2 = ReviewResult(
        point: 80,
        good: ['良い'],
        improve: ['改善'],
      );

      expect(reviewResult1.hashCode, reviewResult2.hashCode);
    });

    test('should create a copy with copyWith', () {
      const original = ReviewResult(
        point: 60,
        good: ['元の良い点'],
        improve: ['元の改善点'],
      );

      final copied = original.copyWith(
        point: 70,
        good: ['新しい良い点'],
      );

      expect(copied.point, 70);
      expect(copied.good, ['新しい良い点']);
      expect(copied.improve, ['元の改善点']); // 変更されない
    });

    test('should create a copy with null values using copyWith', () {
      const original = ReviewResult(
        point: 60,
        good: ['良い点'],
        improve: ['改善点'],
      );

      final copied = original.copyWith();

      expect(copied, original);
    });
  });
}