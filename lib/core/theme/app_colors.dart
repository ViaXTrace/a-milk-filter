import 'package:flutter/material.dart';

/// Design-system color tokens extracted from the *Milk Outside a Bag of Milk*
/// visual palette. All values are intentionally fixed constants —
/// the aesthetic depends on exact palette fidelity.
abstract final class AppColors {
  // ── Background hierarchy (deepening darkness) ───────────────────────────
  static const Color void_ = Color(0xFF000000); // Primary scaffold bg
  static const Color abyss = Color(0xFF080406); // Surface / card bg
  static const Color crypt = Color(0xFF11000D); // Elevated surface
  static const Color vessel = Color(0xFF1C0016); // Highest elevation

  // ── Accent — Milk I ─────────────────────────────────────────────────────
  static const Color crimson = Color(0xFF660020); // Primary accent
  static const Color maroon = Color(0xFF3D0019); // Pressed / deep tint
  static const Color mauve = Color(0xFF890092); // Secondary accent
  static const Color haze = Color(0xFF360039); // Mauve surface tint

  // ── Accent — Milk II ────────────────────────────────────────────────────
  static const Color rust = Color(0xFF5C2420);
  static const Color blood = Color(0xFFCB2B2B);

  // ── Foreground hierarchy ─────────────────────────────────────────────────
  static const Color chalk = Color(0xFFEEE0ED); // Primary text
  static const Color dust = Color(0xFF9A6F81); // Secondary text
  static const Color ash = Color(0xFF664455); // Disabled / hint
  static const Color ember = Color(0xFF452030); // Barely-there text

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFCB2B2B);
  static const Color success = Color(0xFF890092);
  static const Color divider = Color(0xFF1A000E);
  static const Color border = Color(0xFF280016);
  static const Color borderActive = Color(0xFF660020);
  static const Color shadow = Color(0x80660020);
}
