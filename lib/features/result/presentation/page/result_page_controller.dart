import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presen_neta/shared/service/image_generator_service.dart';
import 'package:share_plus/share_plus.dart';

/// ResultPageのシェア機能を担当するコントローラー。
class ResultPageController {
  /// 画像生成サービス。
  final ImageGeneratorService _imageGenerator;

  /// シェアサービス。
  final SharePlus _shareService;

  /// 一時ディレクトリ取得関数。
  final Future<Directory> Function() _getTemporaryDirectory;

  /// [ResultPageController] のコンストラクタ。
  ///
  /// [imageGenerator] 画像生成サービス（デフォルト: ImageGeneratorService）
  /// [shareService] シェアサービス（デフォルト: SharePlus.instance）
  /// [getTempDir] 一時ディレクトリ取得関数（デフォルト: getTemporaryDirectory）
  ResultPageController({
    ImageGeneratorService? imageGenerator,
    SharePlus? shareService,
    Future<Directory> Function()? getTempDir,
  }) : _imageGenerator = imageGenerator ?? const ImageGeneratorService(),
       _shareService = shareService ?? SharePlus.instance,
       _getTemporaryDirectory = getTempDir ?? getTemporaryDirectory;

  /// 結果画像を生成してシェアする。
  ///
  /// [sleepPercentage] 寝た人数のパーセンテージ
  /// [title] 結果のタイトル
  /// [goodPoints] 良い点のリスト
  /// [improvements] 改善提案のリスト
  ///
  /// 画像生成に失敗した場合はテキストのみでシェアする。
  Future<void> shareResult({
    required int sleepPercentage,
    required String title,
    required List<String> goodPoints,
    required List<String> improvements,
  }) async {
    try {
      final imageBytes = await _imageGenerator.generateResultImage(
        sleepPercentage: sleepPercentage,
        title: title,
        goodPoints: goodPoints,
        improvements: improvements,
      );

      final tempDir = await _getTemporaryDirectory();
      final imageFile = File(
        '${tempDir.path}/result_image.png',
      );
      await imageFile.writeAsBytes(imageBytes);

      await _shareService.share(
        ShareParams(
          text: '$sleepPercentage人が寝た! #プレゼン寝た判定',
          files: [XFile(imageFile.path)],
        ),
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
      // エラーが発生した場合はテキストのみシェア
      await _shareService.share(
        ShareParams(text: '$sleepPercentage人が寝た! #プレゼン寝た判定'),
      );
    }
  }
}
