import 'package:envied/envied.dart';

part 'env_config.g.dart';

/// 環境変数の設定を管理する抽象クラス。
///
/// アプリケーションで使用する環境変数を定義し、型安全にアクセスできるようにする。
/// [envied] パッケージを使用して環境変数をコンパイル時に注入する。
@Envied()
abstract class EnvConfig {
  /// Gemini API のキー。
  ///
  /// Google Gemini API を使用するために必要な API キーを取得する。
  /// 環境変数 `GEMINI_API_KEY_DEV` から値を取得する。
  @EnviedField(varName: 'GEMINI_API_KEY_DEV')
  static const String geminiApiKey = _EnvConfig.geminiApiKey;
}
