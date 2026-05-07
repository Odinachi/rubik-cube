# 🎲 Rubik's Cube — Interactive 3D Puzzle

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.7+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green?style=for-the-badge" alt="Platforms" />
  <img src="https://img.shields.io/badge/Version-1.0.0-orange?style=for-the-badge" alt="Version" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License" />
</p>

A fully interactive, real-time **3D Rubik's Cube** built from scratch in Flutter — no game engines, no third-party 3D renderers. The cube is rendered using a custom **painter-sorting (depth-sorted) algorithm** with `Matrix4` transformations, delivering a silky-smooth, gesture-driven experience across Android, iOS, and the Web.

---

## 📸 Preview

> Drag to rotate in any direction. Scramble, apply moves, get hints, or let the app auto-solve it for you.

| Mobile (Portrait) | Desktop / Wide Layout |
|---|---|
| Controls panel anchored at the bottom | Controls panel docks to the right side |

---

## ✨ Features

| Feature | Description |
|---|---|
| 🧊 **True 3D Rendering** | All 26 cubies rendered via per-face `Matrix4` transforms with correct back-to-front painter sorting |
| 🎨 **Smooth Animations** | Slice rotations use a 300ms `AnimationController` with an `easeInOut` curve |
| 🖐️ **Gesture Rotation** | Drag anywhere on the cube viewport to orbit around the X/Y axes |
| 🔀 **Scramble** | Executes 20 random moves with accelerated 150ms animations, building a full move history |
| 🤖 **Auto-Solve** | Replays the move history in reverse order to undo all scramble moves |
| 💡 **Hint System** | Surfaces the next recommended move (reverse of the last recorded move) via the app bar |
| 🎉 **Confetti Celebration** | Fires a particle confetti burst when the cube is solved |
| 📐 **Responsive Layout** | Automatically switches between a portrait (column) and landscape/wide (row) layout at the 800px breakpoint |
| 🔄 **Prime Toggle** | A toggle switch in the controls panel switches all move buttons to their prime (counter-clockwise) variants |
| 🔁 **Reset** | Restores the cube to its solved state and resets orientation |

---

## 🗂️ Project Architecture

This project follows a **Clean Architecture** philosophy with strict **Separation of Concerns**. Each file has a single, well-defined responsibility.

```
rubik_app/
├── lib/
│   ├── main.dart                   # App entry point & MaterialApp setup
│   │
│   ├── core/                       # Shared, app-wide resources
│   │   ├── app_colors.dart         # Centralized color palette (theme, cube faces, UI)
│   │   ├── app_strings.dart        # All user-facing string constants
│   │   └── app_styles.dart         # Reusable BoxDecorations, TextStyles, ButtonStyles
│   │
│   └── cube/                       # Core cube feature module
│       ├── cube_view.dart          # Root StatefulWidget — orchestrates state, rendering & layout
│       ├── cube_controls.dart      # Glassmorphic controls panel (move buttons, scramble, prime toggle)
│       ├── cube_state.dart         # Pure business logic — cubie initialization, slice rotation, isSolved()
│       ├── cube_move.dart          # Immutable value object representing a single Rubik's move
│       ├── cubie.dart              # Data model for a single cubie (position + 6 face colors)
│       └── cubie_view.dart         # (Reserved) Individual cubie rendering widget
│
└── test/
    └── cube/
        ├── cube_logic_test.dart    # Unit tests for CubeState, CubeMove, and Cubie
        └── cube_view_test.dart     # Widget tests for CubeView interactions
```

### Architectural Principles

- **Separation of Concerns** — UI (`CubeView`, `CubeControls`), state machine (`CubeState`), and data models (`CubeMove`, `Cubie`) are fully decoupled.
- **Resource Centralization** — Colors → `app_colors.dart`, Strings → `app_strings.dart`, Styles → `app_styles.dart`. Zero hardcoded values in UI files.
- **Immutability** — `CubeMove` is a pure value object. All `final` and `const` modifiers are applied wherever possible.
- **Single Responsibility** — `CubeState` knows nothing about rendering. `CubeView` knows nothing about the math.

---

## ⚙️ How The 3D Renderer Works

The rendering engine is a **custom software renderer** built on top of Flutter's `Transform` widget and `Matrix4` math — no `CustomPainter`, no canvas drawing.

### Coordinate System

Each cubie occupies an integer grid position `(x, y, z)` where values are in `{-1, 0, 1}`. The cube has 27 cubies total (3×3×3).

### Face Rendering Pipeline

For every cubie, **6 face transforms** are computed (one per face: Up, Down, Left, Right, Front, Back):

1. **Local face matrix** — Translates the face to the correct side of the cubie and rotates it to face outward.
2. **Animation matrix** — If a slice rotation is in progress (`_isAnimating == true`), cubies on the active layer receive an additional in-progress rotation matrix, linearly interpolated by the `AnimationController` value.
3. **Global view matrix** — A single `Matrix4` built from the user's cumulative pan gestures (`_rx`, `_ry`) is applied to the entire scene.

### Depth Sorting (Painter's Algorithm)

After all face transforms are computed, faces are depth-sorted by projecting each face's world-space center through the global view matrix to extract a **Z-depth value**. Faces are sorted in descending Z order (furthest first), then rendered as a `Stack` of `Transform` widgets — ensuring correct occlusion without a Z-buffer.

### Slice Rotation State Machine

When a move is performed:
1. `_animateMove()` sets `_isAnimating = true` and fires the `AnimationController`.
2. During animation, the `build()` method applies the partial rotation **only** to cubies on the affected layer.
3. On animation completion, `CubeState.rotateSlice()` permanently updates each cubie's `(x, y, z)` position **and** permutes its face colors using the correct 90° rotation rules.

---

## 🧩 Core Classes

### `CubeState`

The single source of truth for the cube's logical state. Completely decoupled from Flutter's widget tree.

| Method | Description |
|---|---|
| `CubeState()` | Initializes 27 cubies at positions `(-1..1, -1..1, -1..1)` with correct face colors |
| `rotateSlice(axis, layer, dir)` | Applies a 90° rotation to all cubies on the given layer, updating position and face colors |
| `isSolved()` | Returns `true` only if every outer face has its canonical color |

### `CubeMove`

An immutable value object representing a single Rubik's Cube move in a 3-integer encoding.

| Property | Type | Description |
|---|---|---|
| `axis` | `int` | `0`=X, `1`=Y, `2`=Z |
| `layer` | `int` | `-1` or `1` (the two outer layers) |
| `dir` | `int` | `1`=clockwise, `-1`=counter-clockwise |
| `reverse` | `CubeMove` | Returns the inverse of this move |
| `name` | `String` | Standard Rubik's notation (e.g., `"U"`, `"R'"`, `"F"`) |

### `Cubie`

A mutable data model representing a single small cube.

```dart
class Cubie {
  int id;
  double x, y, z;       // Grid position — updated on every rotation
  Color? upColor;        // null = internal face (not visible)
  Color? downColor;
  Color? leftColor;
  Color? rightColor;
  Color? frontColor;
  Color? backColor;
}
```

---

## 🎮 Controls Reference

### App Bar Actions

| Icon | Action |
|---|---|
| 💡 Lightbulb | **Hint** — Displays the next recommended move in standard notation |
| ▶️ Play | **Auto-Solve** — Replays move history in reverse to solve the cube |
| 🔄 Refresh | **Reset** — Returns cube to solved state |

### Move Buttons

Standard Rubik's Cube face notation. All 6 faces are accessible:

| Button | Face | Axis | Layer |
|---|---|---|---|
| `U` | Up | Y | -1 |
| `D` | Down | Y | +1 |
| `L` | Left | X | -1 |
| `R` | Right | X | +1 |
| `F` | Front | Z | +1 |
| `B` | Back | Z | -1 |

> **Prime Toggle (`'`)** — Enable to apply all moves counter-clockwise (e.g., `R` becomes `R'`).

### Gesture Controls

| Gesture | Action |
|---|---|
| Drag horizontally | Rotate the cube around the Y-axis |
| Drag vertically | Rotate the cube around the X-axis |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **≥ 3.x**
- Dart SDK **≥ 3.7.2** (comes with Flutter)
- A connected device, simulator, or web browser

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/rubik_app.git
cd rubik_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run

# To target a specific platform:
flutter run -d chrome        # Web
flutter run -d ios           # iOS Simulator
flutter run -d android       # Android Emulator/Device
```

---

## 🧪 Testing

The project includes a comprehensive test suite covering both unit logic and widget behavior.

```bash
# Run all tests
flutter test

# Run with verbose output
flutter test --reporter expanded

# Run a specific test file
flutter test test/cube/cube_logic_test.dart
```

### Test Coverage

| Test File | Scope | Key Scenarios |
|---|---|---|
| `cube_logic_test.dart` | **Unit** | Move equality & hashCode, reverse move correctness, all 12 move names (U/D/L/R/F/B + primes), single-axis rotation, Sexy Move (R U R' U') × 6 algorithm, floating-point stability after 500 random rotations |
| `cube_view_test.dart` | **Widget** | Initial render, responsive layout transitions, app bar hint & auto-solve actions, scramble & reset interactions, gesture handling |

The floating-point stability test is particularly noteworthy — it performs **500 seeded random rotations** then reverses all of them, asserting that `isSolved()` returns `true`. This validates the `round()` precision guard in `CubeState`.

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| [`vector_math`](https://pub.dev/packages/vector_math) | `^2.1.4` | `Vector3` & `Matrix4` for 3D math (face transforms, depth projection) |
| [`confetti`](https://pub.dev/packages/confetti) | `^0.8.0` | Particle celebration effect on cube solve |
| [`flutter_lints`](https://pub.dev/packages/flutter_lints) | `^5.0.0` | Enforces Dart best practices via static analysis |

---

## 🎨 Design System

All visual tokens are centralized to ensure consistency and simplify future theme changes.

### Color Palette (`app_colors.dart`)

| Token | Value | Usage |
|---|---|---|
| `backgroundStart` | `#1a1a2e` | Gradient start |
| `backgroundMiddle` | `#16213e` | Gradient midpoint |
| `backgroundEnd` | `#0f3460` | Gradient end |
| `cubeRight` | Red | Right face |
| `cubeLeft` | Orange | Left face |
| `cubeDown` | Yellow | Down face |
| `cubeUp` | White | Up face |
| `cubeFront` | Green | Front face |
| `cubeBack` | Blue | Back face |

### UI Style

- **Background**: Deep navy-to-blue linear gradient
- **Controls Panel**: Glassmorphism (`BackdropFilter` with 15px blur + semi-transparent border)
- **Move Buttons**: Frosted-glass containers with hover and ink-splash effects
- **App Bar**: Fully transparent, `extendBodyBehindAppBar: true`

---

## 🛣️ Roadmap

- [ ] Implement a proper algorithmic solver (e.g., CFOP / Kociemba's algorithm) rather than history-replay
- [ ] Add touch-based slice rotation (swipe directly on a cube face)
- [ ] Persist and display solve time and move count
- [ ] Add sound effects for move and solve events
- [ ] Support custom color themes / cube skins
- [ ] Implement a timer and move counter for speedcubing practice

---

## 🤝 Contributing

Contributions are welcome! Please adhere to the coding principles defined in [`agent.md`](./agent.md) — particularly the rules around resource centralization, immutability, and separation of concerns.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'feat: add your feature'`)
4. Push and open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](./LICENSE) file for details.

---

<p align="center">Built with ❤️ using Flutter</p>
