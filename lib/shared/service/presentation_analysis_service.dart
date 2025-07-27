import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:pdfx/pdfx.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';

/// プレゼンテーション分析処理を担当するサービス。
///
/// PDFファイルの選択、検証、分析実行、エラーハンドリングを統合的に管理する。
class PresentationAnalysisService
    implements PresentationAnalysisServiceInterface {
  /// [FilePickerService] を外部から注入できるコンストラクタ。
  ///
  /// テスト時などにモックを渡すことで、ファイル選択処理を差し替えられる。
  PresentationAnalysisService({FilePickerService? filePickerService})
    : _filePickerService = filePickerService;

  /// ファイルピッカーサービスのインスタンス。
  ///
  /// テスト時は外部から注入、本番時はデフォルトインスタンスを利用する。
  final FilePickerService? _filePickerService;

  /// 実際に利用する [FilePickerService] を返すゲッター。
  ///
  /// 外部から注入されていればそれを、なければデフォルトインスタンスを返す。
  FilePickerService get filePickerService =>
      _filePickerService ?? FilePickerService();

  /// ロガーインスタンス。
  final Logger _logger = Logger();

  /// PDFファイルを選択し、分析を実行する。
  ///
  /// [context] はエラー表示に利用される。async gap 後の利用は mounted でガードする。
  /// [ref] Riverpodのref
  /// 分析成功時は true、失敗時は false を返す。
  @override
  Future<bool> analyzePdfFile(BuildContext context, WidgetRef ref) async {
    _logger.i('PDFファイル分析開始');

    final result = await filePickerService.pickFile();
    if (!context.mounted) {
      _logger.w('コンテキストがマウントされていません');
      return false;
    }

    if (result == null || result.files.isEmpty) {
      _logger.i('ファイルが選択されませんでした');
      return false;
    }

    final file = result.files.first;
    _logger.d('選択されたファイル: ${file.name}');

    try {
      // PDFファイルのみ対応
      final extension = file.name.split('.').last.toLowerCase();
      if (extension != 'pdf') {
        _logger.w('PDF以外のファイルが選択されました: $extension');
        if (context.mounted) {
          _showErrorSnackBar(context, 'PDFファイルのみ対応しています');
        }
        return false;
      }

      final pdfData = await filePickerService.readPdfFileContent(file);
      if (pdfData == null) {
        _logger.e('PDFファイルの読み取りに失敗しました');
        if (context.mounted) {
          _showErrorSnackBar(context, 'PDFファイルの読み取りに失敗しました');
        }
        return false;
      }

      _logger.i('PDFファイル読み取り完了: ${pdfData.length}バイト');

      // PDFを複数のPNGに変換
      final pngImages = await convertPdfToPngImages(pdfData);
      if (pngImages.isEmpty) {
        _logger.e('PDFの変換に失敗しました');
        if (context.mounted) {
          _showErrorSnackBar(context, 'PDFの変換に失敗しました');
        }
        return false;
      }

      _logger.i('PDF変換完了: ${pngImages.length}枚の画像');

      // Riverpodを使用して分析を実行
      await ref
          .read(analysisNotifierProvider.notifier)
          .analyzeMultipleSlideImages(pngImages);

      _logger.i('分析実行完了');
      return true;
    } on Exception catch (e) {
      _logger.e('PDF分析エラー: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'エラーが発生しました: $e');
      }
      return false;
    }
  }

  /// PDFデータを複数のPNG画像に変換する。
  ///
  /// [pdfData] 変換対象のPDFデータ
  /// 変換されたPNG画像のリストを返す。変換に失敗した場合は空のリストを返す。
  @override
  Future<List<Uint8List>> convertPdfToPngImages(Uint8List pdfData) async {
    try {
      _logger.d('PDF変換開始');
      final pdfDocument = await PdfDocument.openData(pdfData);
      final pageCount = pdfDocument.pagesCount;
      _logger.d('PDFページ数: $pageCount');

      final pngImages = <Uint8List>[];

      for (var pageIndex = 0; pageIndex < pageCount; pageIndex++) {
        _logger.d('ページ ${pageIndex + 1} を処理中');
        final page = await pdfDocument.getPage(pageIndex + 1);
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
          format: PdfPageImageFormat.png,
        );

        if (pageImage != null) {
          pngImages.add(pageImage.bytes);
          _logger.d('ページ ${pageIndex + 1} 変換完了: ${pageImage.bytes.length}バイト');
        } else {
          _logger.w('ページ ${pageIndex + 1} の変換に失敗しました');
        }

        await page.close();
      }

      await pdfDocument.close();
      _logger.i('PDF変換完了: ${pngImages.length}枚の画像を生成');
      return pngImages;
    } on Exception catch (e) {
      _logger.e('PDF変換エラー: $e');
      return [];
    }
  }

  /// エラーメッセージをSnackBarで表示する。
  ///
  /// [context] 表示に利用するBuildContext
  /// [message] 表示するエラーメッセージ
  void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      _logger.w('エラーメッセージを表示: $message');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
