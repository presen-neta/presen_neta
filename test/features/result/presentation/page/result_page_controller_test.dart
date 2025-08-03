import 'package:flutter_test/flutter_test.dart';
import 'package:presen_neta/features/result/presentation/page/result_page_controller.dart';

void main() {
  group('ResultPageController', () {
    test('デフォルトコンストラクタで正常にインスタンス化される', () {
      final controller = ResultPageController();
      expect(controller, isA<ResultPageController>());
    });
  });
}