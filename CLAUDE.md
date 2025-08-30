# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter app that analyzes presentation slides using AI and estimates how many out of 100 people would fall asleep due to boredom. The app uses Google's Generative AI (Gemini) to analyze PDF slides and generate humorous feedback with visual results.

## Development Commands

### Build and Run
```bash
# Run the app in debug mode
flutter run

# Build for specific platforms
flutter build apk
flutter build ios
flutter build web
```

### Code Generation
```bash
# Generate code for freezed, json_serializable, riverpod
flutter packages pub run build_runner build

# Watch for changes and regenerate
flutter packages pub run build_runner watch

# Clean generated files
flutter packages pub run build_runner clean
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=integration_test/file_picker_service_integration_test.dart
```

### Code Quality
```bash
# Analyze code (uses very_good_analysis)
flutter analyze

# Format code
dart format .
```

## Architecture Overview

### Clean Architecture Pattern
- **lib/app/** - Application-level configurations, routing
- **lib/features/** - Feature modules (start, result pages)
- **lib/shared/** - Shared services, models, providers, configuration
- **Dependency Rule**: App → Features → Shared (no cross-feature dependencies)

### State Management
- **Riverpod**: Primary state management with hooks_riverpod
- **Code Generation**: Uses riverpod_annotation and riverpod_generator
- **Providers**: Centralized in shared/providers/service_providers.dart
- **AsyncValue**: Handles loading, data, and error states

### Key Services
- **PresentationAnalysisService**: Orchestrates PDF analysis workflow
- **GeminiService**: Google Generative AI integration for slide analysis
- **FilePickerService**: PDF file selection and validation
- **ImageGeneratorService**: Generates result images with sleep statistics

### Navigation
- **GoRouter**: Declarative routing with two main routes:
  - `/` (StartPage) - PDF upload and analysis
  - `/result` (ResultPage) - Analysis results display

## Code Generation Requirements

When making changes, regenerate code using:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

Required for:
- Freezed models (*.freezed.dart)
- JSON serialization (*.g.dart) 
- Riverpod providers (*.g.dart)
- Environment configuration (env_config.g.dart)

## Testing Strategy

### Mock Generation
- Uses Mockito with @GenerateMocks annotation
- Service mocks in test/shared/service/mocks/
- Generated mocks with *.mocks.dart files

### Test Organization
- Unit tests: test/shared/service/
- Widget tests: test/features/*/presentation/page/
- Integration tests: integration_test/
- Test providers: test/shared/providers/test_service_providers.dart

### Running Specific Tests
```bash
# Run specific test file
flutter test test/shared/service/presentation_analysis_service_test.dart

# Run tests with verbose output
flutter test --verbose
```

## Environment Configuration

- Uses envied for type-safe environment variables
- Configuration in lib/shared/config/env_config.dart
- Regenerate after env changes: `flutter packages pub run build_runner build`

## Key Development Patterns

- All services implement interfaces for testability
- Use Riverpod providers for dependency injection
- Freezed for immutable data models
- Comprehensive error handling with AsyncValue
- Logging with the logger package
- Interface-based design for service abstractions

## File Organization

- Feature-specific code stays within feature directories
- Shared logic goes in shared/ directory
- Providers defined alongside their related services
- Generated files excluded from version control and analysis