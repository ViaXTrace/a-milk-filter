# A Milk Filter

Flutter Android app that applies the visual palette of *Milk Outside a Bag of Milk* to any photo. Pixel-by-pixel brightness mapping to a curated 3-tone color palette, with AdMob monetization and a full-screen interactive viewer.

## Run & Operate

```bash
flutter pub get
flutter run                  # Android device / emulator required
flutter build apk --release
flutter build appbundle --release
```

No required env vars. GitHub remote: `https://github.com/ViaXTrace/a-milk-filter`

## Stack

- **Language**: Dart 3.x / Flutter 3.x (Android target, minSdk 21)
- **Build**: Gradle + Flutter Gradle plugin
- **Key packages**: `image` (pixel filter), `image_picker`, `gal` (gallery save), `share_plus`, `google_mobile_ads` (AdMob)

## Where things live

```
lib/
├── core/
│   ├── filter/       milk_filter.dart · milk_palette.dart · filter_options.dart
│   └── theme/        app_colors.dart · app_theme.dart · app_typography.dart
├── features/
│   ├── home/         home_screen.dart  (banner ad at bottom)
│   ├── editor/       editor_screen.dart · widgets/{before_after_view, filter_controls}.dart
│   └── viewer/       image_viewer.dart  (full-screen InteractiveViewer)
├── shared/widgets/   milk_app_bar.dart · scanline_overlay.dart · banner_ad_widget.dart
└── main.dart         (MobileAds.instance.initialize())
```

## Filter Algorithm

Brightness = (R + G + B) / 3 — arithmetic mean, no gamma correction.

**Milk I**: void #000000 · crimson #66001F · mauve #890092
**Milk II**: void #000000 · rust #5C243C · blood #CB2B2B

Pointillism = 70 % primary / 30 % secondary stochastic dithering at band boundaries.
Optional JPEG pre-pass: `img.encodeJpg(quality: 100 - q)` before palette mapping.

## Architecture decisions

- `compute()` isolate for filter — UI thread never blocked during pixel mapping
- `ScanlineOverlay` is a pure `IgnorePointer > RepaintBoundary > CustomPaint` — callers wrap in `Positioned.fill` inside their own Stack
- `gal` package used for gallery saves (replaces documents-directory workaround)
- `GestureDetector` + `AnimatedContainer` over `InkWell` — pixel-precise press states
- `CupertinoPageTransitionsBuilder` on Android — smoother slide transitions
- AdMob banner is self-loading and self-disposing (`BannerAdWidget` stateful); interstitial reloads itself after each display
- Interstitial fires every `_savesPerInterstitial` (default 3) saves in `editor_screen.dart`

## Product

- Pick photo from gallery or camera
- Apply Milk I or Milk II palette filter (pixel-by-pixel brightness mapping)
- Pointillism toggle (stochastic dithering) and JPEG compression pre-pass
- Film Grain toggle (±10 luminance CRT noise)
- Before/After split-screen comparison with draggable divider
- **EXPAND button** on AFTER pane → full-screen `InteractiveViewer` (pinch zoom, double-tap reset, save, share)
- Save to device gallery or share via system share sheet
- AdMob banner ad on home screen; interstitial every 3 saves

## AdMob IDs to replace before publishing

| Location | Constant | File |
|----------|----------|------|
| Android App ID | `AndroidManifest.xml` meta-data value | `android/app/src/main/AndroidManifest.xml` |
| Banner unit | `_bannerAdUnitId` | `lib/shared/widgets/banner_ad_widget.dart` |
| Interstitial unit | `_interstitialAdUnitId` | `lib/features/editor/editor_screen.dart` |

## User preferences

- Monospace (Courier New) typography throughout — aesthetic constraint, not a bug
- `withValues(alpha:)` used (Flutter ≥ 3.26); fall back to `withOpacity()` if needed on older SDKs

## Gotchas

- Filter runs in an isolate via `compute()` — no Flutter imports allowed in `core/filter/`
- `gal` requires `android:requestLegacyExternalStorage="true"` on API ≤ 29
- `ScanlineOverlay` must be wrapped in `Positioned.fill` when used inside a Stack
- Pixel-exact palette colors: Milk I crimson = `0xFF66001F` (not `0xFF660020`); Milk II rust = `0xFF5C243C` (not `0xFF5C2420`) — corrected from original Python `(102,0,31)` and `(92,36,60)`
- `MobileAds.instance.initialize()` must complete before any ad is requested — done in `main()` with `await`

## Pointers

- Filter algorithm reference: `attached_assets/android_(1)_1777918016954.py`
- AdMob docs: https://developers.google.com/admob/flutter/quick-start
