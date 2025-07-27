import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';

/// PDFプレゼンテーションファイルのアップロードページ。
///
/// PDFファイルのアップロードと、簡単なチェックリストを提供するページ。
class StartPage extends ConsumerWidget {
  /// [FilePickerService] を外部から注入できるコンストラクタ。
  ///
  /// テスト時などにモックを渡すことで、ファイル選択処理を差し替えられる。
  const StartPage({super.key, FilePickerService? service}) : _service = service;

  /// ファイルピッカーサービスのインスタンス。
  ///
  /// テスト時は外部から注入、本番時はデフォルトインスタンスを利用する。
  final FilePickerService? _service;

  /// 実際に利用する [FilePickerService] を返すゲッター。
  ///
  /// 外部から注入されていればそれを、なければデフォルトインスタンスを返す。
  FilePickerService get service => _service ?? FilePickerService();

  /// PDFファイルを選択し、分析を実行して結果ページへ遷移する。
  ///
  /// [context] は遷移に利用される。async gap 後の利用は mounted でガードする。
  /// [ref] Riverpodのref
  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    final result = await service.pickFile();
    if (!context.mounted) return;
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      try {
        // PDFファイルのみ対応
        if (file.extension == 'pdf') {
          final pdfData = await service.readPdfFileContent(file);
          if (pdfData != null) {
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

            if (context.mounted) {
              context.go('/result');
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDFファイルの読み取りに失敗しました')),
              );
            }
          }
        } else {
          // PDFファイル以外は対応していない
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDFファイルのみ対応しています')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラーが発生しました: $e')),
          );
        }
      }
    }
  }

  /// ウィジェットツリーを構築する。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 32,
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/StartPage.png',
                    width: 260,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'PDFプレゼンテーションを分析',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00B8D9),
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF00B8D9),
                          ),
                          SizedBox(width: 8),
                          Text('目的ははっきりしている？', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.text_snippet_outlined,
                            color: Color(0xFF00B8D9),
                          ),
                          SizedBox(width: 8),
                          Text('文字ばっかりのスライド？', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            color: Color(0xFF00B8D9),
                          ),
                          SizedBox(width: 8),
                          Text('視聴者目線になっている？', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B8D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // elevation: 4, // デフォルト値なので削除
                    ),
                    onPressed: () {
                      _pickFile(context, ref);
                    },
                    child: const Text(
                      'PDFファイルを選択',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
