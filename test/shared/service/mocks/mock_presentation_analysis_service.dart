import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';

/// PresentationAnalysisServiceのモッククラス。
///
/// テスト時に実際の分析処理をシミュレートする。
class MockPresentationAnalysisService extends Mock
    implements PresentationAnalysisServiceInterface {
  /// 分析が成功するかどうかを制御するフラグ。
  bool shouldSucceed = true;

  /// 分析処理の遅延時間（ミリ秒）。
  int delayMilliseconds = 1000;

  @override
  Future<bool> analyzePdfFile(BuildContext context, WidgetRef ref) async {
    // 指定された遅延時間だけ待機
    await Future.delayed(Duration(milliseconds: delayMilliseconds));

    // 成功フラグに基づいて結果を返す
    if (shouldSucceed) {
      // 成功時はtrueを返す
      return true;
    } else {
      // 失敗時はfalseを返す
      return false;
    }
  }
}
