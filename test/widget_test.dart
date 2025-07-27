import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:presen_neta/main.dart';
import 'shared/providers/test_service_providers.dart';

void main() {
  testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: testServiceOverrides,
        child: const MyApp(),
      ),
    );
  });
}
