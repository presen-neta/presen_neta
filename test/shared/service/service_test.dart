import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/shared/providers/service_providers.dart';
import 'package:presen_neta/shared/service/interfaces/file_picker_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';
import '../providers/test_service_providers.dart';

/// サービス層のテストクラス。
///
/// 修正されたアーキテクチャがテスト可能であることを確認する。
void main() {
  group('Service Providers', () {
    test('FilePickerServiceプロバイダーが正しく動作する', () {
      final container = ProviderContainer(overrides: testServiceOverrides);
      addTearDown(container.dispose);

      final service = container.read(filePickerServiceProvider);
      expect(service, isA<FilePickerServiceInterface>());
    });

    test('GeminiServiceプロバイダーが正しく動作する', () {
      final container = ProviderContainer(overrides: testServiceOverrides);
      addTearDown(container.dispose);

      final service = container.read(geminiServiceProvider);
      expect(service, isA<GeminiServiceInterface>());
    });

    test('PresentationAnalysisServiceプロバイダーが正しく動作する', () {
      final container = ProviderContainer(overrides: testServiceOverrides);
      addTearDown(container.dispose);

      final service = container.read(presentationAnalysisServiceProvider);
      expect(service, isA<PresentationAnalysisServiceInterface>());
    });
  });

  group('Test Service Providers', () {
    test('テスト用プロバイダーオーバーライドが正しく動作する', () {
      final container = ProviderContainer(
        overrides: testServiceOverrides,
      );
      addTearDown(container.dispose);

      final filePickerService = container.read(filePickerServiceProvider);
      final geminiService = container.read(geminiServiceProvider);
      final presentationAnalysisService = container.read(
        presentationAnalysisServiceProvider,
      );

      expect(filePickerService, isA<FilePickerServiceInterface>());
      expect(geminiService, isA<GeminiServiceInterface>());
      expect(
        presentationAnalysisService,
        isA<PresentationAnalysisServiceInterface>(),
      );
    });
  });
}
