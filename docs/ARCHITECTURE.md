# Architecture Decision Records

## ADR-001 — Flutter for Native Android

**Status:** Accepted  
**Date:** 2026-05-04

### Context
The original Python/Tkinter implementation is desktop-only and requires the user to have a Python environment. Porting to native Android enables mobile use, camera access, and gallery export.

### Decision
Flutter (Dart) was chosen over Kotlin/Jetpack Compose and React Native.

### Rationale
- Single codebase, native performance via Skia/Impeller
- `image` package (pure Dart) for pixel-level manipulation without native bridges
- Strong isolate support for non-blocking filter processing
- Hot reload during development

### Consequences
- Filter must be reimplemented in Dart (no Python bridge)
- Pixel loop runs in a `compute()` isolate to avoid jank on the main thread

---

## ADR-002 — Filter Engine as Pure Dart Isolate

**Status:** Accepted  
**Date:** 2026-05-04

### Context
The filter algorithm iterates over every pixel in the image. For a 4K image (~8M pixels), this can take several seconds. Running it on the main isolate would freeze the UI.

### Decision
The filter engine (`core/filter/milk_filter.dart`) is a pure function with no Flutter dependencies. It is invoked via `compute()`, which spawns a new isolate.

### Consequences
- No platform channels needed
- Engine is easily unit-testable
- `compute()` serializes/deserializes via `Uint8List` — acceptable overhead for this use case

---

## ADR-003 — Palette Definition as Sealed Classes

**Status:** Accepted

### Context
Milk I and Milk II have distinct brightness-to-color mappings. These must be extensible without modifying the engine.

### Decision
Use Dart sealed classes to represent palettes. The engine receives a `MilkPalette` and dispatches via exhaustive pattern matching.

```dart
sealed class MilkPalette {}
class MilkPaletteOne extends MilkPalette {}
class MilkPaletteTwo extends MilkPalette {}
```

### Consequences
- Adding a new palette requires only a new subclass + mapping table
- Pattern matching is exhaustive — compiler catches missing cases

---

## ADR-004 — Design System: Game-Derived Tokens

**Status:** Accepted

### Context
The app's UI should evoke the game's aesthetic without directly copying its assets.

### Decision
Color tokens are extracted from the game's palette and formalized as static `const` values in `app_colors.dart`. Typography uses `Courier`/monospace as the primary font family.

| Token | Value | Role |
|-------|-------|------|
| `colorVoid` | `#000000` | Primary background |
| `colorAbyss` | `#0A0608` | Card/surface |
| `colorCrimson` | `#660020` | Primary accent |
| `colorMaroon` | `#3D0019` | Pressed states |
| `colorMauve` | `#890092` | Secondary accent |
| `colorChalk` | `#EDE0EC` | Foreground text |
