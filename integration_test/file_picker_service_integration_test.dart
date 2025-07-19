import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('filePicker省略時のFilePickerServiceでファイル選択できる', (tester) async {
    final service = FilePickerService(); // filePicker を渡さない
    // ここで実際にファイルピッカーUIが開く
    final result = await service.pickFile();
    // 手動でファイルを選択 or テスト自動化ツールで選択
    expect(result, isNotNull); // ファイルが選択できたことを確認
  });
}
