// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$geminiServiceHash() => r'7468f5154ee604120046e70ddffe71b15ca8fdc3';

/// GeminiServiceのプロバイダー
///
/// Copied from [geminiService].
@ProviderFor(geminiService)
final geminiServiceProvider = AutoDisposeProvider<GeminiService>.internal(
  geminiService,
  name: r'geminiServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$geminiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeminiServiceRef = AutoDisposeProviderRef<GeminiService>;
String _$analysisNotifierHash() => r'1fa6c61abd62932b21bb6f38a79fa7dbda6b2124';

/// 分析結果の状態管理プロバイダー
///
/// Copied from [AnalysisNotifier].
@ProviderFor(AnalysisNotifier)
final analysisNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AnalysisNotifier, String>.internal(
      AnalysisNotifier.new,
      name: r'analysisNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$analysisNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnalysisNotifier = AutoDisposeAsyncNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
