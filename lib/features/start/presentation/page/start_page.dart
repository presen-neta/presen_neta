import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:presen_neta/features/start/presentation/page/file_picker_service.dart';

/// スタートページを表示するウィジェット。
///
/// スライドファイルのアップロードと、簡単なチェックリストを提供するページ。
class StartPage extends StatelessWidget {
  const StartPage({super.key, FilePickerService? service}) : _service = service;
  final FilePickerService? _service;

  FilePickerService get service => _service ?? FilePickerService();

  /// ファイルピッカーを起動し、ファイルが選択されたら result ページへ遷移する。
  ///
  /// [context] は遷移に利用される。async gap 後の利用は mounted でガードする。
  Future<void> _pickFile(BuildContext context) async {
    final result = await service.pickFile();
    if (!context.mounted) return;
    if (result != null && result.files.isNotEmpty) {
      context.go('/result');
    }
  }

  /// ウィジェットツリーを構築する。
  @override
  Widget build(BuildContext context) {
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
                  '100人中何人が寝るかな？',
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
                      _pickFile(context);
                    },
                    child: const Text(
                      'スライドをアップロード',
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
