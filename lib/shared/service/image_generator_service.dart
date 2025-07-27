import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 結果画像を生成するサービス。
///
/// 良い点と改善提案を含む結果画像を生成し、シェア用の画像を作成する。
class ImageGeneratorService {
  /// [ImageGeneratorService] のコンストラクタ。
  const ImageGeneratorService();

  /// 結果画像を生成する。
  ///
  /// [sleepPercentage] は寝た人の割合、[title] はタイトル文字列、
  /// [goodPoints] は良い点のリスト、[improvements] は改善提案のリストを指定する。
  Future<Uint8List> generateResultImage({
    required int sleepPercentage,
    required String title,
    required List<String> goodPoints,
    required List<String> improvements,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // 4:3比率の横長サイズ
    const size = Size(800, 600);

    // 背景を描画
    _drawBackground(canvas, size);

    // イラストを描画
    await _drawIllustration(canvas, size, title, sleepPercentage);

    // タイトルは削除（イラスト部分で表示）

    // 良い点を描画
    _drawGoodPoints(canvas, size, goodPoints);

    // 改善提案を描画
    _drawImprovements(canvas, size, improvements);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// 背景を描画する。
  void _drawBackground(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFF7FAFC)
          ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);
  }

  /// イラストを描画する。
  Future<void> _drawIllustration(
    Canvas canvas,
    Size size,
    String title,
    int sleepPercentage,
  ) async {
    try {
      final data = await rootBundle.load('assets/ResultPage.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;

      // 影を描画（先に影を描く）
      final shadowPaint =
          Paint()
            ..color = Colors.black.withValues(alpha: 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(55, 155, 300, 300),
          const Radius.circular(24),
        ),
        shadowPaint,
      );

      // 白い背景のコンテナを描画（中央左）
      const containerRect = Rect.fromLTWH(50, 150, 300, 300);
      final containerPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(containerRect, const Radius.circular(24)),
        containerPaint,
      );

      // イラストを描画
      const imageRect = Rect.fromLTWH(66, 166, 268, 268);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        imageRect,
        Paint(),
      );

      // 上の中央に「X人が寝た!」を表示
      const percentageStyle = TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00B8D9),
      );

      final percentageTextPainter = TextPainter(
        text: TextSpan(
          text: '${sleepPercentage}人が寝た!',
          style: percentageStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      percentageTextPainter
        ..layout()
        ..paint(
          canvas,
          Offset((800 - percentageTextPainter.width) / 2, 50),
        );

      // 画像の下にタイトルを中央揃えで表示
      const titleStyle = TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00B8D9),
        letterSpacing: 1.2,
      );

      final titlePainter = TextPainter(
        text: TextSpan(
          text: title,
          style: titleStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // 画像の中央位置を計算（画像はx: 50, y: 150, width: 300）
      const imageCenterX = 50 + 300 / 2; // 200
      titlePainter.paint(
        canvas,
        Offset(imageCenterX - titlePainter.width / 2, 470),
      );
    } on Exception catch (e) {
      // イラストの読み込みに失敗した場合は何もしない
      debugPrint('Failed to load illustration: $e');
    }
  }

  /// 良い点を描画する。
  void _drawGoodPoints(Canvas canvas, Size size, List<String> goodPoints) {
    const titleStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF00B8D9),
    );

    const contentStyle = TextStyle(
      fontSize: 12,
      color: Color(0xFF374151),
    );

    // タイトルを描画
    TextPainter(
        text: const TextSpan(text: '良い点', style: titleStyle),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, const Offset(400, 150));

    // 内容を描画
    double yOffset = 190;
    for (final point in goodPoints) {
      final textPainter =
          TextPainter(
              text: TextSpan(text: '• $point', style: contentStyle),
              textDirection: TextDirection.ltr,
              maxLines: 2,
            )
            ..layout(maxWidth: 350)
            ..paint(canvas, Offset(400, yOffset));
      yOffset += textPainter.height + 12;
    }
  }

  /// 改善提案を描画する。
  void _drawImprovements(Canvas canvas, Size size, List<String> improvements) {
    const titleStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFF6B35),
    );

    const contentStyle = TextStyle(
      fontSize: 12,
      color: Color(0xFF374151),
    );

    // タイトルを描画
    TextPainter(
        text: const TextSpan(text: '改善提案', style: titleStyle),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, const Offset(400, 370));

    // 内容を描画
    double yOffset = 410;
    for (final improvement in improvements) {
      final textPainter =
          TextPainter(
              text: TextSpan(text: '• $improvement', style: contentStyle),
              textDirection: TextDirection.ltr,
              maxLines: 2,
            )
            ..layout(maxWidth: 350)
            ..paint(canvas, Offset(400, yOffset));
      yOffset += textPainter.height + 12;
    }
  }
}
