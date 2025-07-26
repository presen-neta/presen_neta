import 'package:envied/envied.dart';

part 'env_config.g.dart';

@Envied()
abstract class EnvConfig {
  @EnviedField(varName: 'API_KEY')
  static const String geminiApiKey = _EnvConfig.geminiApiKey;
}
