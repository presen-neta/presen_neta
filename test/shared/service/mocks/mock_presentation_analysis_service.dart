import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';

/// PresentationAnalysisServiceのモッククラス。
///
/// テスト時に実際の分析処理をシミュレートする。
class MockPresentationAnalysisService extends Mock
    implements PresentationAnalysisServiceInterface {
  /// 分析が成功するかどうかを制御するフラグ。
  bool shouldSucceed = true;

  /// 分析処理の遅延時間（ミリ秒）。
  int delayMilliseconds = 0;

  @override
  Future<bool> analyzePdfFile(BuildContext context, WidgetRef ref) async {
    // 指定された遅延時間だけ待機
    await Future<void>.delayed(Duration(milliseconds: delayMilliseconds));

    // 成功フラグに基づいて結果を返す
    if (shouldSucceed) {
      // 成功時はAnalysisNotifierにテスト画像を送って分析を実行
      final testImages = [
        Uint8List.fromList([1, 2, 3, 4]), // テスト画像1
        Uint8List.fromList([5, 6, 7, 8]), // テスト画像2
      ];
      
      // Riverpodを使用して分析を実行
      await ref
          .read(analysisNotifierProvider.notifier)
          .analyzeMultipleSlideImages(testImages);
      
      return true;
    } else {
      // 失敗時はfalseを返す
      return false;
    }
  }

  @override
  Future<List<Uint8List>> convertPdfToPngImages(Uint8List pdfData) async {
    // 指定された遅延時間だけ待機
    await Future<void>.delayed(Duration(milliseconds: delayMilliseconds));
    
    // テスト用のダミー画像データを返す
    return [
      Uint8List.fromList([1, 2, 3, 4]), // ダミー画像1
      Uint8List.fromList([5, 6, 7, 8]), // ダミー画像2
    ];
  }
}
