# Programming Paradigms & Best Practices

When working on this project, adhere to the following software engineering paradigms and best practices to maintain a clean, scalable, and robust codebase.

## 1. Clean Architecture & Modularity
- **Separation of Concerns**: Keep the UI (Widgets), state management, and business logic decoupled.
- **Single Responsibility Principle (SRP)**: Each class or file should have one specific purpose. For example, `CubeMove` should only represent a move, `CubeState` should manage the mathematical state, and `CubeView` should handle the rendering.
- **Small Widgets**: Break down monolithic UI files into smaller, reusable widgets (like we did with `CubeControls`). 

## 2. DRY (Don't Repeat Yourself)
- Avoid code duplication. If you find yourself writing the same logic or UI widget more than once, extract it into a reusable function or a custom Widget.

## 3. Immutability
- Prefer `final` and `const` variables wherever possible in Dart. This improves performance (especially for Flutter's Widget tree) and prevents unintended side-effects.
- Build state as immutable objects. If you need to change a state, create a copy of the object rather than modifying the existing one directly, where practical.

## 4. State Management
- Keep state as low in the widget tree as possible. If a piece of state only affects one widget, manage it locally with a `StatefulWidget`.
- For global or app-wide states, rely on state management paradigms (e.g., Provider, Riverpod, BLoC) rather than passing callbacks deep down the widget tree.

## 5. Defensive Programming & Safety
- **Null Safety**: Leverage Dart's strong null safety features. Avoid using the `!` bang operator unless you are absolutely certain a value cannot be null.
- **Handle Edge Cases**: Check for boundary conditions (e.g., array bounds, floating-point inaccuracies when dealing with 3D coordinate rotations).

## 6. UI/UX Principles
- **Responsive Design**: Always build with multiple screen sizes in mind using tools like `LayoutBuilder` or `MediaQuery`.
- **Feedback & Affordance**: Provide visual feedback for interactions (e.g., hover states, tap ripples) and handle loading/error states gracefully.

## 7. Clean Code & Readability
- Use descriptive, meaningful names for variables, methods, and classes.
- Comment *why* the code is doing something, not *what* it is doing (the code itself should be self-explanatory).
- Adhere strictly to the official Dart linting rules (`flutter_lints`).

## 8. Separation of Resources
- **Ensure text is from one file**: Do not hardcode strings in the UI. Keep all text assets localized or centralized in a single file (e.g., `strings.dart`).
- **Ensure styling is from another file**: Extract generic styles, text themes, and paddings into a dedicated styling file (e.g., `styles.dart` or within a centralized `ThemeData` definition) rather than defining them inline.
- **Ensure colors are from another file**: Centralize all color definitions (e.g., `colors.dart`) to ensure consistency and facilitate easy theme switching (like light/dark modes).

By adhering to these principles, the project remains highly maintainable, less prone to regression bugs, and accessible for future developers.
