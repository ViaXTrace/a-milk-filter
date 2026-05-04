# Filter Algorithm Reference

## Overview

The Milk Filter maps each pixel brightness to a fixed palette derived from the game art direction.
Stochastic dithering at palette boundaries introduces organic grain.

## Brightness Calculation

brightness = (R + G + B) / 3

No gamma correction — matches the original Python implementation, producing harsh contrast.

## Milk I Palette Mapping

| Range        | Output              |
|--------------|---------------------|
| ≤ 25         | #000000 Void        |
| (25, 70]     | #000000 | #660020   |
| (70, 120)    | #660020 | #000000   |
| [120, 200)   | #660020 Crimson     |
| [200, 230)   | #890092 | #660020   |
| ≥ 230        | #890092 Mauve       |

## Milk II Palette Mapping

| Range        | Output              |
|--------------|---------------------|
| ≤ 25         | #000000 Void        |
| (25, 70]     | #000000 | #5C2420   |
| (70, 90)     | #5C2420 | #000000   |
| [90, 150)    | #5C2420 Rust        |
| [150, 200)   | #CB2B2B | #5C2420   |
| ≥ 200        | #CB2B2B Blood       |

## Pointillism Effect

Reduces stochastic probability from 100% to 70%.
30% noise at palette boundaries creates organic grain texture.

## Pre-processing: JPEG Compression

Image compressed to target quality (0-100) before filtering.
Lower quality introduces DCT artifacts that interact with palette quantization.

## Performance (Dart isolate)

| Size      | Time     |
|-----------|----------|
| 1080p     | ~1-2s    |
| 4K        | ~4-7s    |
| 512px     | <100ms   |

Run inside compute() to keep UI at 60fps.
