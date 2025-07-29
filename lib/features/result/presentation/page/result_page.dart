import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:presen_neta/features/result/presentation/page/result_page_controller.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';

/// プレゼンテーション分析結果を表示するページ。
///
/// 判定結果のイラスト、コメント、シェアボタン、AI分析結果、再アップロードボタンを表示する。
class ResultPage extends ConsumerWidget {
  /// [ResultPage] のコンストラクタ。
  const ResultPage({super.key});

  /// ロガーインスタンス。
  static final Logger _logger = Logger();

  /// 分析結果に基づいて判定メッセージを生成する。
  ///
  /// [point] 分析結果の点数
  /// 判定メッセージを返す
  String _getJudgmentMessage(int point) {
    if (point >= 90) {
      return 'いいんじゃない？';
    } else if (point >= 75) {
      return 'まあまあだけど';
    } else if (point >= 60) {
      return 'がんばれ';
    } else {
      return 'つまらん！';
    }
  }

  /// 分析結果に基づいて寝た率メッセージを生成する。
  ///
  /// [point] 分析結果の点数
  /// 寝た率メッセージを返す
  String _getSleepRateMessage(int point) {
    final sleepRate = 100 - point;
    return '$sleepRate人が寝た!';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // 分析状態を監視
    final analysisState = ref.watch(analysisNotifierProvider);

    _logger.d('ResultPage - 分析状態: $analysisState');

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: analysisState.when(
          data: (result) {
            _logger.d('ResultPage - data状態: result=${result?.point ?? 'null'}');
            if (result == null) {
              // 分析結果がない場合はStartPageに戻る
              _logger.i('ResultPage - 分析結果なし、StartPageに戻る');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  // 安全にナビゲーション
                  try {
                    context.go('/');
                  } on Exception catch (e) {
                    _logger.e('ResultPage - ナビゲーションエラー: $e');
                  }
                }
              });
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file,
                      color: Color(0xFF00B8D9),
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'PDFをアップロードしてください',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B8D9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'StartPageに戻ります...',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // 分析結果がある場合は結果を表示
            return SingleChildScrollView(
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
                        'assets/ResultPage.png',
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _getSleepRateMessage(result.point),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00B8D9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B8D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () async {
                          final controller = ResultPageController();
                          await controller.shareResult(
                            sleepPercentage: 100 - result.point,
                            title: _getJudgmentMessage(result.point),
                            goodPoints: result.good,
                            improvements: result.improve,
                          );
                        },
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: const Text(
                          '結果をシェア',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.psychology,
                                color: Color(0xFF00B8D9),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI分析結果',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00B8D9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (result.good.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.thumb_up,
                                  color: Color(0xFF00B8D9),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '良い点',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00B8D9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ...result.good.map(
                              (good) => Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• '),
                                    Expanded(
                                      child: Text(
                                        good,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              height: 1.5,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (result.improve.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  color: Color(0xFFFF6B35),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '改善提案',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFF6B35),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ...result.improve.map(
                              (improve) => Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• '),
                                    Expanded(
                                      child: Text(
                                        improve,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              height: 1.5,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF00B8D9),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          // 分析結果をリセットしてStartPageに戻る
                          ref.read(analysisNotifierProvider.notifier).reset();
                          context.go('/');
                        },
                        icon: const Icon(
                          Icons.upload_file,
                          color: Color(0xFF00B8D9),
                        ),
                        label: const Text(
                          '別のスライドをアップロード',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00B8D9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () {
            _logger.d('ResultPage - loading状態');
            return const Scaffold(
              backgroundColor: Color(0xFFF7FAFC),
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF00B8D9),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 24),
                      Text(
                        '分析中...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B8D9),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'AIがプレゼンテーションを評価しています',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (error, stack) {
            _logger.e('ResultPage - error状態: $error');
            return Scaffold(
              backgroundColor: const Color(0xFFF7FAFC),
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '分析エラー',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'エラーが発生しました: $error',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B8D9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              // エラー状態をリセットしてStartPageに戻る
                              ref
                                  .read(analysisNotifierProvider.notifier)
                                  .reset();
                              context.go('/');
                            },
                            child: const Text(
                              '最初からやり直す',
                              style: TextStyle(
                                fontSize: 16,
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
          },
        ),
      ),
    );
  }
}
