import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:presen_neta/features/result/provider/result_provider.dart';
import 'package:presen_neta/shared/providers/service_providers.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';

/// PDFプレゼンテーションファイルのアップロードページ。
///
/// PDFファイルのアップロードと、簡単なチェックリストを提供するページ。
class StartPage extends ConsumerStatefulWidget {
  /// [PresentationAnalysisServiceInterface] を外部から注入できるコンストラクタ。
  ///
  /// テスト時などにモックを渡すことで、ファイル選択処理を差し替えられる。
  const StartPage({super.key, PresentationAnalysisServiceInterface? service})
    : _service = service;

  /// プレゼンテーション分析サービスのインスタンス。
  ///
  /// テスト時は外部から注入、本番時はプロバイダーから取得する。
  final PresentationAnalysisServiceInterface? _service;

  @override
  ConsumerState<StartPage> createState() => _StartPageState();
}

class _StartPageState extends ConsumerState<StartPage> {
  /// ロガーインスタンス。
  final Logger _logger = Logger();

  /// 分析が開始されたかどうかを追跡するフラグ。
  bool _isAnalysisStarted = false;

  /// 実際に利用する [PresentationAnalysisServiceInterface] を返すゲッター。
  ///
  /// 外部から注入されていればそれを、なければプロバイダーから取得する。
  PresentationAnalysisServiceInterface get service =>
      widget._service ?? ref.read(presentationAnalysisServiceProvider);

  /// PDFファイルを選択し、分析を実行して結果ページへ遷移する。
  ///
  /// [context] は遷移に利用される。async gap 後の利用は mounted でガードする。
  /// [ref] Riverpodのref
  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    _logger.i('PDFファイル選択開始');
    setState(() {
      _isAnalysisStarted = true;
    });

    try {
      final success = await service.analyzePdfFile(context, ref);
      if (success && context.mounted) {
        _logger.i('分析成功、ResultPageに遷移');
        context.go('/result');
      } else {
        _logger.w('分析失敗またはコンテキストがマウントされていない');
        if (mounted) {
          setState(() {
            _isAnalysisStarted = false;
          });
        }
      }
    } catch (e) {
      _logger.e('分析中にエラーが発生: $e');
      if (mounted) {
        setState(() {
          _isAnalysisStarted = false;
        });
      }
    }
  }

  /// 全画面ローディングオーバーレイを表示する。
  ///
  /// [context] 表示に利用するBuildContext
  void _showLoadingOverlay(BuildContext context) {
    // 既にダイアログが表示されている場合は何もしない
    if (Navigator.of(context).canPop()) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF00B8D9),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'PDFを分析中...',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00B8D9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AIがプレゼンテーションを評価しています',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ローディングダイアログを閉じる。
  ///
  /// ダイアログが表示されている場合にのみ閉じる。
  void _closeLoadingDialog() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// ウィジェットツリーを構築する。
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 分析状態を監視
    final analysisState = ref.watch(analysisNotifierProvider);

    _logger.d('StartPage - 分析状態: ${analysisState.toString()}');

    // 分析が開始されたらローディングオーバーレイを表示
    analysisState.when(
      data: (result) {
        _logger.d('StartPage - data状態: result=${result?.point ?? 'null'}');
        // 分析完了後、少し遅延してからResultPageに遷移
        if (result != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              _logger.i('StartPage - 分析完了、ResultPageに遷移');
              // ローディングダイアログを安全に閉じる
              _closeLoadingDialog();
              context.go('/result');
            }
          });
        }
        return null;
      },
      loading: () {
        _logger.d('StartPage - loading状態');
        // ローディング状態になったらオーバーレイを表示
        // ただし、分析が開始されていない場合は表示しない
        if (_isAnalysisStarted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // 既にローディングダイアログが表示されているかチェック
              final isDialogShowing = Navigator.of(context).canPop();
              if (!isDialogShowing) {
                _logger.i('StartPage - ローディングオーバーレイを表示');
                _showLoadingOverlay(context);
              }
            }
          });
        }
        return null;
      },
      error: (error, stack) {
        _logger.e('StartPage - error状態: $error');
        // エラー時はローディングダイアログを閉じる
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _logger.i('StartPage - エラー、ローディングダイアログを閉じる');
            _closeLoadingDialog();
          }
        });
        return null;
      },
    );

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
                  'PDFプレゼンテーションを分析',
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
                    ),
                    onPressed: () {
                      _pickFile(context, ref);
                    },
                    child: const Text(
                      'PDFファイルを選択',
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
