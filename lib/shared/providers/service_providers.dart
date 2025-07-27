import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';
import 'package:presen_neta/shared/service/gemini_service.dart';
import 'package:presen_neta/shared/service/presentation_analysis_service.dart';
import 'package:presen_neta/shared/service/interfaces/file_picker_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';

/// FilePickerServiceのプロバイダー。
///
/// テスト時にモックに置き換え可能にするための抽象化。
final filePickerServiceProvider = Provider<FilePickerServiceInterface>((ref) {
  return FilePickerService();
});

/// GeminiServiceのプロバイダー。
///
/// テスト時にモックに置き換え可能にするための抽象化。
final geminiServiceProvider = Provider<GeminiServiceInterface>((ref) {
  return GeminiService();
});

/// PresentationAnalysisServiceのプロバイダー。
///
/// テスト時にモックに置き換え可能にするための抽象化。
final presentationAnalysisServiceProvider =
    Provider<PresentationAnalysisServiceInterface>((ref) {
      final filePickerService = ref.watch(filePickerServiceProvider);
      return PresentationAnalysisService(
        filePickerService: filePickerService as FilePickerService,
      );
    });
