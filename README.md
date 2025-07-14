# presen_neta

## Project Overview

A fun mobile app that analyzes your presentation slides and estimates how many out of 100 people would fall asleep due to boredom.

---

## Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: hooks_riverpod
- **Routing**: go_router
- **CI/CD**: GitHub Actions
- **Testing**: Flutter Test, Mockito
- **Logging**: logger
- **Documentation**: Notion
- **Design**: Figma

---

## Page Structure

### StartPage

- Illustration of a person giving a presentation
- Large title: "How many out of 100 will fall asleep?"
- Reflection prompts (e.g., "Is your purpose clear?", "Is it all text?", "Is it self-centered?")
- "Upload Slide" button
    - Select file
    - Reward ad is shown while AI is analyzing

### ResultPage

- Result image (illustration of people sleeping)
    - Short comment (e.g., "What's your point?", "Too much text!", "So boring!")
    - Number of people who fell asleep (e.g., "80% fell asleep!")
- Share button
- Blurred block indicating "Detailed evaluation coming soon"
- "Upload another slide" button

---

## Directory Structure (Clean Architecture)

```
lib/
  app/        # App-wide settings, routing, DI, common widgets, etc.
  features/   # Feature modules (UI, models, repositories, services, providers, etc.)
  shared/     # Shared resources (models, repositories, services, widgets, constants, exceptions, etc.)
  main.dart   # Entry point
test/         # Test code
assets/       # Image and other assets
```

- **Dependency Rule**: Only App → Feature → Shared is allowed. No direct dependencies between features. Shared does not depend on anything.

---

## Development & Operation Rules

- Each feature should be divided into subdirectories by responsibility
- Common logic should be placed in `shared/`
- When adding new features, create a new directory under `features/`
- Providers should be defined in the same file as their related repository or service implementation
- Use consistent naming conventions

---

## References

- [Flutter App Architecture – a modular approach](https://deep5.io/en/flutter-app-architecture-a-modular-approach/)
- [Effective Dart: Directory Structure](https://dart.dev/guides/libraries/create-library-packages#directory-structure)
