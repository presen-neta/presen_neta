import 'package:flutter/material.dart';
import 'app/app_router/app_router.dart';

void main() {
  runApp(const MyApp());
}

/// アプリケーションのエントリーポイント。
///
/// go_router を利用してルーティングを管理する。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
