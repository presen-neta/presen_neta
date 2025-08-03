import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/shared/providers/service_providers.dart';
import 'package:presen_neta/shared/service/file_picker_service.dart';
import 'package:presen_neta/shared/service/gemini_service.dart';
import 'package:presen_neta/shared/service/presentation_analysis_service.dart';
import 'package:presen_neta/shared/service/interfaces/file_picker_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';

void main() {
  group('ServiceProviders', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('filePickerServiceProvider', () {
      test('should provide FilePickerService instance', () {
        final service = container.read(filePickerServiceProvider);
        
        expect(service, isA<FilePickerServiceInterface>());
        expect(service, isA<FilePickerService>());
      });

      test('should return same instance on multiple reads', () {
        final service1 = container.read(filePickerServiceProvider);
        final service2 = container.read(filePickerServiceProvider);
        
        expect(service1, same(service2));
      });
    });

    group('geminiServiceProvider', () {
      test('should provide GeminiService instance', () {
        final service = container.read(geminiServiceProvider);
        
        expect(service, isA<GeminiServiceInterface>());
        expect(service, isA<GeminiService>());
      });

      test('should return same instance on multiple reads', () {
        final service1 = container.read(geminiServiceProvider);
        final service2 = container.read(geminiServiceProvider);
        
        expect(service1, same(service2));
      });
    });

    group('presentationAnalysisServiceProvider', () {
      test('should provide PresentationAnalysisService instance', () {
        final service = container.read(presentationAnalysisServiceProvider);
        
        expect(service, isA<PresentationAnalysisServiceInterface>());
        expect(service, isA<PresentationAnalysisService>());
      });

      test('should return same instance on multiple reads', () {
        final service1 = container.read(presentationAnalysisServiceProvider);
        final service2 = container.read(presentationAnalysisServiceProvider);
        
        expect(service1, same(service2));
      });

      test('should inject FilePickerService dependency', () {
        final presentationService = container.read(presentationAnalysisServiceProvider) as PresentationAnalysisService;
        final filePickerService = container.read(filePickerServiceProvider);
        
        expect(presentationService.filePickerService, same(filePickerService));
      });
    });

    group('provider dependencies', () {
      test('presentationAnalysisServiceProvider should depend on filePickerServiceProvider', () {
        // Get the services
        final filePickerService = container.read(filePickerServiceProvider);
        final presentationService = container.read(presentationAnalysisServiceProvider) as PresentationAnalysisService;
        
        // Verify the dependency is correctly injected
        expect(presentationService.filePickerService, same(filePickerService));
      });

      test('should handle provider overrides correctly', () {
        // Create a container with provider overrides
        final overrideContainer = ProviderContainer(
          overrides: [
            filePickerServiceProvider.overrideWithValue(FilePickerService()),
          ],
        );

        try {
          final service = overrideContainer.read(filePickerServiceProvider);
          expect(service, isA<FilePickerService>());
        } finally {
          overrideContainer.dispose();
        }
      });
    });

    group('provider lifecycle', () {
      test('should dispose providers correctly', () {
        // Read all providers to initialize them
        container.read(filePickerServiceProvider);
        container.read(geminiServiceProvider);
        container.read(presentationAnalysisServiceProvider);
        
        // Dispose should not throw
        expect(() => container.dispose(), returnsNormally);
      });

      test('should handle multiple containers independently', () {
        final container1 = ProviderContainer();
        final container2 = ProviderContainer();

        try {
          final service1 = container1.read(filePickerServiceProvider);
          final service2 = container2.read(filePickerServiceProvider);
          
          // Different containers should provide different instances
          expect(service1, isNot(same(service2)));
        } finally {
          container1.dispose();
          container2.dispose();
        }
      });
    });
  });
}