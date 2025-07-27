import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';

/// プレゼンテーション分析処理を担当するサービス。
///
/// PDFファイルの選択、検証、分析実行、エラーハンドリングを統合的に管理する。
class PresentationAnalysisService {
  /// [FilePickerService] を外部から注入できるコンストラクタ。
  ///
  /// テスト時などにモックを渡すことで、ファイル選択処理を差し替えられる。
  const PresentationAnalysisService({FilePickerService? filePickerService})
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

  /// PDFファイルを選択し、分析を実行する。
  ///
  /// [context] はエラー表示に利用される。async gap 後の利用は mounted でガードする。
  /// [ref] Riverpodのref
  /// 分析成功時は true、失敗時は false を返す。
  Future<bool> analyzePdfFile(BuildContext context, WidgetRef ref) async {
    final result = await filePickerService.pickFile();
    if (!context.mounted) return false;

    if (result == null || result.files.isEmpty) {
      return false;
    }

    final file = result.files.first;

    try {
      // PDFファイルのみ対応
      final extension = file.name.split('.').last.toLowerCase();
      if (extension != 'pdf') {
        _showErrorSnackBar(context, 'PDFファイルのみ対応しています');
        return false;
      }

      final pdfData = await filePickerService.readPdfFileContent(file);
      if (pdfData == null) {
        _showErrorSnackBar(context, 'PDFファイルの読み取りに失敗しました');
        return false;
      }

      // 一時的にサンプル画像データを使用（PDF変換機能は後で実装）
      final sampleImageData = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        // PNGヘッダー（最小限のサンプルデータ）
      ]);

      // Riverpodを使用して分析を実行
      await ref
          .read(analysisNotifierProvider.notifier)
          .analyzeMultipleSlideImages([sampleImageData]);

      return true;
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'エラーが発生しました: $e');
      }
      return false;
    }
  }

  /// エラーメッセージをSnackBarで表示する。
  ///
  /// [context] 表示に利用するBuildContext
  /// [message] 表示するエラーメッセージ
  void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
