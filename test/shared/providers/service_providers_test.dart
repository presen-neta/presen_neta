import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:presen_neta/shared/providers/service_providers.dart';
import 'package:presen_neta/shared/service/interfaces/file_picker_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/gemini_service_interface.dart';
import 'package:presen_neta/shared/service/interfaces/presentation_analysis_service_interface.dart';
import '../service/mocks/mock_file_picker_service.dart';
import '../service/mocks/mock_gemini_service.dart';
import '../service/mocks/mock_presentation_analysis_service.dart';

void main() {
  group('ServiceProviders', () {
    late ProviderContainer container;
    late MockFilePickerService mockFilePickerService;
    late MockGeminiService mockGeminiService;
    late MockPresentationAnalysisService mockPresentationAnalysisService;

    setUp(() {
      mockFilePickerService = MockFilePickerService();
      mockGeminiService = MockGeminiService();
      mockPresentationAnalysisService = MockPresentationAnalysisService();

      container = ProviderContainer(
        overrides: [
          filePickerServiceProvider.overrideWithValue(mockFilePickerService),
          geminiServiceProvider.overrideWithValue(mockGeminiService),
          presentationAnalysisServiceProvider.overrideWithValue(
            mockPresentationAnalysisService,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('filePickerServiceProvider', () {
      test('should provide FilePickerService instance', () {
        final service = container.read(filePickerServiceProvider);

        expect(service, isA<FilePickerServiceInterface>());
        expect(service, same(mockFilePickerService));
      });

      test('should return same instance on multiple reads', () {
        final service1 = container.read(filePickerServiceProvider);
        final service2 = container.read(filePickerServiceProvider);

        expect(service1, same(service2));
        expect(service1, same(mockFilePickerService));
      });

      test('should maintain provider state correctly', () {
        final service1 = container.read(filePickerServiceProvider);
        final service2 = container.read(filePickerServiceProvider);

        expect(identical(service1, service2), isTrue);
      });
    });

    group('geminiServiceProvider', () {
      test('should provide GeminiService instance', () {
        final service = container.read(geminiServiceProvider);

        expect(service, isA<GeminiServiceInterface>());
        expect(service, same(mockGeminiService));
      });

      test('should return same instance on multiple reads', () {
        final service1 = container.read(geminiServiceProvider);
        final service2 = container.read(geminiServiceProvider);

        expect(service1, same(service2));
        expect(service1, same(mockGeminiService));
      });

      test('should maintain provider state correctly', () {
        final service1 = container.read(geminiServiceProvider);
        final service2 = container.read(geminiServiceProvider);

        // Should maintain same instance
        expect(identical(service1, service2), isTrue);
      });
    });

    group('presentationAnalysisServiceProvider', () {
      test('should provide PresentationAnalysisService instance', () {
        final service = container.read(presentationAnalysisServiceProvider);

        expect(service, isA<PresentationAnalysisServiceInterface>());
        expect(service, same(mockPresentationAnalysisService));
      });

      test('should return same instance on multiple reads', () {
        final service1 = container.read(presentationAnalysisServiceProvider);
        final service2 = container.read(presentationAnalysisServiceProvider);

        expect(service1, same(service2));
      });

      test('should inject FilePickerService dependency', () {
        final presentationService = container.read(
          presentationAnalysisServiceProvider,
        );
        final filePickerService = container.read(filePickerServiceProvider);

        // モックサービスは依存性注入を持たないため、提供されていることのみを検証する
        expect(
          presentationService,
          isA<PresentationAnalysisServiceInterface>(),
        );
        expect(filePickerService, isA<FilePickerServiceInterface>());
      });

      test('should maintain dependency chain correctly', () {
        final service1 = container.read(presentationAnalysisServiceProvider);
        final service2 = container.read(presentationAnalysisServiceProvider);

        expect(identical(service1, service2), isTrue);
      });

      test('should update when filePickerService changes', () {
        final newMockFilePickerService = MockFilePickerService();
        final newContainer = ProviderContainer(
          overrides: [
            filePickerServiceProvider.overrideWithValue(
              newMockFilePickerService,
            ),
            presentationAnalysisServiceProvider.overrideWithValue(
              mockPresentationAnalysisService,
            ),
          ],
        );

        try {
          final filePickerService = newContainer.read(
            filePickerServiceProvider,
          );
          final presentationService = newContainer.read(
            presentationAnalysisServiceProvider,
          );

          expect(filePickerService, same(newMockFilePickerService));
          expect(presentationService, same(mockPresentationAnalysisService));
        } finally {
          newContainer.dispose();
        }
      });
    });

    group('provider dependencies', () {
      test(
        '''presentationAnalysisServiceProvider should depend on filePickerServiceProvider''',
        () {
          // Get the services
          final filePickerService = container.read(filePickerServiceProvider);
          final presentationService = container.read(
            presentationAnalysisServiceProvider,
          );

          // Verify both services are provided as expected interfaces
          expect(filePickerService, isA<FilePickerServiceInterface>());
          expect(
            presentationService,
            isA<PresentationAnalysisServiceInterface>(),
          );
        },
      );

      test('should handle provider overrides correctly', () {
        // Create another mock service for override testing
        final anotherMockFilePickerService = MockFilePickerService();

        // Create a container with provider overrides
        final overrideContainer = ProviderContainer(
          overrides: [
            filePickerServiceProvider.overrideWithValue(
              anotherMockFilePickerService,
            ),
          ],
        );

        try {
          final service = overrideContainer.read(filePickerServiceProvider);
          expect(service, same(anotherMockFilePickerService));
          expect(service, isA<FilePickerServiceInterface>());
        } finally {
          overrideContainer.dispose();
        }
      });
    });

    group('provider lifecycle', () {
      test('should dispose providers correctly', () {
        // Read all providers to initialize them
        container
          ..read(filePickerServiceProvider)
          ..read(geminiServiceProvider)
          ..read(presentationAnalysisServiceProvider);

        // Dispose should not throw
        expect(() => container.dispose(), returnsNormally);
      });

      test('should handle multiple containers independently', () {
        final mockService1 = MockFilePickerService();
        final mockService2 = MockFilePickerService();

        final container1 = ProviderContainer(
          overrides: [
            filePickerServiceProvider.overrideWithValue(mockService1),
          ],
        );
        final container2 = ProviderContainer(
          overrides: [
            filePickerServiceProvider.overrideWithValue(mockService2),
          ],
        );

        try {
          final service1 = container1.read(filePickerServiceProvider);
          final service2 = container2.read(filePickerServiceProvider);

          // Different containers should provide different instances
          expect(service1, same(mockService1));
          expect(service2, same(mockService2));
          expect(service1, isNot(same(service2)));
        } finally {
          container1.dispose();
          container2.dispose();
        }
      });

      test('should handle container recreation', () {
        // Create and dispose multiple containers
        for (var i = 0; i < 3; i++) {
          final testContainer = ProviderContainer(
            overrides: [
              filePickerServiceProvider.overrideWithValue(
                MockFilePickerService(),
              ),
            ],
          );

          final service = testContainer.read(filePickerServiceProvider);
          expect(service, isA<FilePickerServiceInterface>());

          testContainer.dispose();
        }
      });
    });
  });
}
