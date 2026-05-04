# A Milk Filter

Flutter Android app that applies the visual palette of *Milk Outside a Bag of Milk* to any photo. Pixel-by-pixel brightness mapping to a curated 3-tone color palette.

## Stack

- **Language**: Dart 3.x
- **Framework**: Flutter 3.x (Android target)
- **Build**: Gradle + Flutter Gradle plugin
- **Package manager**: pub (`flutter pub get`)

## Architecture

```
lib/
├── core/
│   ├── filter/           # Isolate-safe filter engine (no Flutter deps)
│   │   ├── milk_filter.dart     — compute() entry point, FilterPayload
│   │   ├── milk_palette.dart    — sealed MilkPalette hierarchy, band resolution
│   │   └── filter_options.dart  — immutable FilterOptions value object
│   └── theme/            # Design system tokens
│       ├── app_colors.dart      — all color constants (void/abyss/crimson/mauve…)
│       ├── app_theme.dart       — ThemeData factory
│       └── app_typography.dart  — Courier New monospace text theme
├── features/
│   ├── home/             — HomeScreen: brand hero, drop zone, source buttons
│   └── editor/
│       ├── editor_screen.dart          — orchestrates filter + state machine
│       └── widgets/
│           ├── before_after_view.dart  — draggable split comparison view
│           └── filter_controls.dart   — palette picker, toggles, compression slider
├── shared/widgets/
│   ├── milk_app_bar.dart     — custom AppBar with gradient accent rule
│   └── scanline_overlay.dart — CRT scanline texture (IgnorePointer, RepaintBoundary)
└── main.dart             — edge-to-edge setup, theme, HomeScreen
```

## Filter Algorithm

Brightness = (R + G + B) / 3 (arithmetic mean, no gamma correction — matches original Python)

**Milk I**: void #000000 · crimson #660020 · mauve #890092  
**Milk II**: void #000000 · rust #5C2420 · blood #CB2B2B

Pointillism mode = 70% primary / 30% secondary at boundary bands (stochastic dithering).  
Optional JPEG pre-pass: `img.encodeJpg(quality: 100 - q)` before palette mapping.

## UI Design System

- **Background hierarchy**: void_ → abyss → crypt → vessel (deepening layers)
- **Radius**: 10px standard, 24px pill, 5px label
- **Touch targets**: minimum 52dp height
- **Spacing**: 8pt grid, 20–28px horizontal margins
- **Typography**: Courier New monospace throughout, 8–48px range

## Key Design Decisions

- `SystemUiMode.edgeToEdge` for true edge-to-edge immersive feel
- `CupertinoPageTransitionsBuilder` for fluid navigation on Android
- `AnimatedContainer` + `GestureDetector` over `InkWell` for pixel-precise press states
- `compute()` isolate for filter — never blocks UI thread
- `RepaintBoundary` on scanline overlay — isolated from main widget tree repaints
- Before/After divider uses circular handle (chevron icons) with drag state feedback

## Building

```bash
flutter pub get
flutter run                 # Android device/emulator required
flutter build apk --release
```
