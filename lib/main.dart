import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:presen_neta/app/app_router/app_router.dart';

/// アプリケーションのエントリーポイント。
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// アプリ全体のルートウィジェット。
///
/// [appRouter] を利用してルーティングを管理する。
class MyApp extends StatelessWidget {
  /// [MyApp] のコンストラクタ。
  const MyApp({super.key});

  /// ウィジェットツリーを構築する。
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
    );
  }
}
