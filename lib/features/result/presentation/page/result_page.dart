import 'package:flutter/material.dart';

/// 結果ページを表示するウィジェット。
///
/// アップロードされたスライドの解析結果などを表示するページ。
class ResultPage extends StatelessWidget {
  /// [ResultPage] のコンストラクタ。
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('結果'),
      ),
      body: Center(
        child: Text('ここに結果を表示'),
      ),
    );
  }
}
