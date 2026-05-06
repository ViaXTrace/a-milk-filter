# A Milk Filter

Flutter Android app that applies the visual palette of *Milk Outside a Bag of Milk* to any photo. Pixel-by-pixel brightness mapping to a curated 3-tone color palette.

## Run & Operate

```bash
flutter pub get
flutter run                  # Android device / emulator required
flutter build apk --release
```

No required env vars. GitHub remote: `https://github.com/ViaXTrace/a-milk-filter`

## Stack

- **Language**: Dart 3.x / Flutter 3.x (Android target, minSdk 21)
- **Build**: Gradle + Flutter Gradle plugin
- **Key packages**: `image` (pixel filter), `image_picker`, `gal` (gallery save), `share_plus`

## Where things live

```
lib/
├── core/
│   ├── filter/       milk_filter.dart · milk_palette.dart · filter_options.dart
│   └── theme/        app_colors.dart · app_theme.dart · app_typography.dart
├── features/
│   ├── home/         home_screen.dart
│   └── editor/       editor_screen.dart · widgets/{before_after_view, filter_controls}.dart
├── shared/widgets/   milk_app_bar.dart · scanline_overlay.dart
└── main.dart
```

## Filter Algorithm

Brightness = (R + G + B) / 3 — arithmetic mean, no gamma correction.

**Milk I**: void #000000 · crimson #660020 · mauve #890092  
**Milk II**: void #000000 · rust #5C2420 · blood #CB2B2B

Pointillism = 70 % primary / 30 % secondary stochastic dithering at band boundaries.  
Optional JPEG pre-pass: `img.encodeJpg(quality: 100 - q)` before palette mapping.

## Architecture decisions

- `compute()` isolate for filter — UI thread never blocked during pixel mapping
- `ScanlineOverlay` is a pure `IgnorePointer > RepaintBoundary > CustomPaint` — callers wrap in `Positioned.fill` inside their own Stack
- `gal` package used for gallery saves (replaces documents-directory workaround)
- `GestureDetector` + `AnimatedContainer` over `InkWell` — pixel-precise press states
- `CupertinoPageTransitionsBuilder` on Android — smoother slide transitions

## Product

- Pick photo from gallery or camera
- Apply Milk I or Milk II palette filter (pixel-by-pixel brightness mapping)
- Pointillism toggle (stochastic dithering) and JPEG compression pre-pass
- Before/After split-screen comparison with draggable divider
- Save to device gallery or share via system share sheet

## User preferences

- Monospace (Courier New) typography throughout — aesthetic constraint, not a bug
- `withOpacity()` kept for Flutter ≤ 3.26 compatibility (upgrade path: `withValues(alpha:)`)

## Gotchas

- Filter runs in an isolate via `compute()` — no Flutter imports allowed in `core/filter/`
- `gal` requires `android:requestLegacyExternalStorage="true"` on API ≤ 29
- `ScanlineOverlay` must be wrapped in `Positioned.fill` when used inside a Stack
