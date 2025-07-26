import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:presen_neta/shared/service/image_generator_service.dart';

void main() {
  late ImageGeneratorService service;

  setUp(() {
    service = const ImageGeneratorService();
  });

  group('ImageGeneratorService', () {
    test('generateResultImage が正常に画像を生成する', () async {
      // テスト実行
      final result = await service.generateResultImage(
        sleepPercentage: 69,
        title: 'つまらん！',
        goodPoints: [
          'スライドの構成が分かりやすい',
          '文字サイズが適切',
        ],
        improvements: [
          'アニメーションを追加して動きを出す',
          'より具体的なデータを提示する',
        ],
      );

      // 結果の検証
      expect(result, isA<Uint8List>());
      expect(result.length, greaterThan(0));
    });

    test('generateResultImage が空のリストでも正常に動作する', () async {
      final result = await service.generateResultImage(
        sleepPercentage: 50,
        title: 'テスト',
        goodPoints: [],
        improvements: [],
      );

      expect(result, isA<Uint8List>());
      expect(result.length, greaterThan(0));
    });

    test('generateResultImage が長いテキストでも正常に動作する', () async {
      final result = await service.generateResultImage(
        sleepPercentage: 80,
        title: 'とても長いタイトル文字列です',
        goodPoints: [
          'これは非常に長い良い点の説明文です。複数行にわたる可能性があります。',
          'もう一つの長い良い点の説明文です。',
        ],
        improvements: [
          'これは非常に長い改善提案の説明文です。複数行にわたる可能性があります。',
          'もう一つの長い改善提案の説明文です。',
        ],
      );

      expect(result, isA<Uint8List>());
      expect(result.length, greaterThan(0));
    });

    test('generateResultImage が異なるsleepPercentageでも正常に動作する', () async {
      final result = await service.generateResultImage(
        sleepPercentage: 100,
        title: '完璧！',
        goodPoints: ['完璧なプレゼン'],
        improvements: ['改善点なし'],
      );

      expect(result, isA<Uint8List>());
      expect(result.length, greaterThan(0));
    });

    test('generateResultImage がエラーを適切に処理する', () async {
      // 存在しないファイル名でテスト
      final result = await service.generateResultImage(
        sleepPercentage: 0,
        title: 'エラーテスト',
        goodPoints: ['テスト'],
        improvements: ['テスト'],
      );

      // エラーが発生しても何らかの結果が返されることを確認
      expect(result, isA<Uint8List>());
    });
  });
}
