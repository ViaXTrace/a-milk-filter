<div align="center">

```
 █████╗     ███╗   ███╗██╗██╗      ██╗  ██╗    ███████╗██╗██╗  ████████╗███████╗██████╗ 
██╔══██╗    ████╗ ████║██║██║      ██║ ██╔╝    ██╔════╝██║██║  ╚══██╔══╝██╔════╝██╔══██╗
███████║    ██╔████╔██║██║██║      █████╔╝     █████╗  ██║██║     ██║   █████╗  ██████╔╝
██╔══██║    ██║╚██╔╝██║██║██║      ██╔═██╗     ██╔══╝  ██║██║     ██║   ██╔══╝  ██╔══██╗
██║  ██║    ██║ ╚═╝ ██║██║███████╗ ██║  ██╗    ██║     ██║███████╗██║   ███████╗██║  ██║
╚═╝  ╚═╝    ╚═╝     ╚═╝╚═╝╚══════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝╚══════╝╚═╝   ╚══════╝╚═╝  ╚═╝
```

# A Milk Filter

**Transform your photos into the aesthetic of the unseen.**

[![Platform](https://img.shields.io/badge/platform-Android-660020?style=flat-square&logo=android&logoColor=white)](https://developer.android.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-890092?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-3D0019?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/status-In%20Development-660020?style=flat-square)]()

*Inspired by the visual aesthetic of "Milk Outside a Bag of Milk Outside a Bag of Milk"*

</div>

---

## Overview

**A Milk Filter** is a native Android image filter application that maps any photograph into the distinctive color palette of the game *Milk Outside a Bag of Milk Outside a Bag of Milk* — a lo-fi, surreal, deeply dark aesthetic defined by voids of black, bleeding crimson, and unsettling violet.

The original concept began as a playful Python script. This repository marks the beginning of its transformation into a polished, production-grade Android application built with Flutter.

---

## The Palette

The filter operates on two distinct aesthetic modes, each derived directly from the game's visual language:

| Mode | Dark | Mid | High |
|------|------|-----|------|
| **Milk I** | `#000000` Void | `#660020` Crimson | `#890092` Mauve |
| **Milk II** | `#000000` Void | `#5C2420` Rust | `#CB2B2B` Blood |

Each pixel's brightness is analyzed and mapped to the nearest palette tone, with an optional **pointillism effect** that introduces stochastic dithering at transition boundaries.

---

## Algorithm

```
For each pixel (x, y):
  brightness = (R + G + B) / 3

  [Milk I]
  brightness ≤ 25         → #000000 (Void)
  brightness ∈ (25, 70]   → #000000 | #660020 (stochastic)
  brightness ∈ (70, 120)  → #660020 | #000000 (stochastic)
  brightness ∈ [120, 200) → #660020 (Crimson)
  brightness ∈ [200, 230) → #890092 | #660020 (stochastic)
  brightness ≥ 230        → #890092 (Mauve)

  [Milk II]
  brightness ≤ 25         → #000000 (Void)
  brightness ∈ (25, 70]   → #000000 | #5C2420 (stochastic)
  brightness ∈ (70, 90)   → #5C2420 | #000000 (stochastic)
  brightness ∈ [90, 150)  → #5C2420 (Rust)
  brightness ∈ [150, 200) → #CB2B2B | #5C2420 (stochastic)
  brightness ≥ 200        → #CB2B2B (Blood)
```

**Pointillism** reduces stochastic probability from 100% to 70%, creating a grain texture at palette boundaries.

---

## App Architecture

```
lib/
├── core/
│   ├── filter/           # Pure Dart filter engine (isolate-safe)
│   │   ├── milk_filter.dart
│   │   ├── palette.dart
│   │   └── filter_options.dart
│   ├── theme/            # Design system tokens
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   └── utils/
│       └── image_utils.dart
├── features/
│   ├── home/             # Landing & image picker
│   ├── editor/           # Before/after preview + controls
│   ├── export/           # Save & share
│   └── settings/         # App preferences
├── shared/
│   ├── widgets/          # Reusable UI components
│   └── extensions/       # Dart extensions
└── main.dart
```

---

## Roadmap

- [ ] Native Android Flutter app (in progress)
- [ ] Isolate-based filter processing (non-blocking UI)
- [ ] Before / after split-view with gesture control
- [ ] Milk I & Milk II filter modes
- [ ] Pointillism effect toggle
- [ ] JPEG compression pre-processing
- [ ] Export to gallery (PNG/JPEG)
- [ ] Share sheet integration
- [ ] Custom palette editor

---

## Development

### Prerequisites

- Flutter 3.x (stable channel)
- Android SDK 21+
- Dart 3.x

### Getting Started

```bash
git clone https://github.com/ViaXTrace/a-milk-filter.git
cd a-milk-filter
flutter pub get
flutter run
```

---

## Origin

This project started as a Python/Tkinter desktop tool — a joke that landed a little too well. The core algorithm was always the heart of it: a pixel-by-pixel brightness scan mapped to a hand-curated palette extracted from the game's art direction.

The Android rewrite keeps the algorithm intact, wraps it in proper isolate threading, and builds a UI that matches the aesthetic it applies.

---

## License

MIT © [ViaXTrace](https://github.com/ViaXTrace)

---

<div align="center">
<sub>built in the void · filtered through crimson · exported to your gallery</sub>
</div>
