import 'package:flutter/material.dart';

/// Design system color tokens extracted from the Milk Outside a Bag of Milk
/// visual palette. All values are intentionally fixed constants —
/// the aesthetic depends on exact palette fidelity.
abstract final class AppColors {
  // ── Background hierarchy ────────────────────────────────────────────────
  static const Color void_ = Color(0xFF000000);   // Primary background
  static const Color abyss = Color(0xFF0A0608);   // Surface / card
  static const Color crypt = Color(0xFF140010);   // Elevated surface
  static const Color vessel = Color(0xFF1E0018);  // Highest elevation

  // ── Accent — Milk I palette ─────────────────────────────────────────────
  static const Color crimson = Color(0xFF660020);  // Primary accent
  static const Color maroon = Color(0xFF3D0019);   // Pressed / tinted bg
  static const Color mauve = Color(0xFF890092);    // Secondary accent
  static const Color haze = Color(0xFF3A0040);     // Mauve surface tint

  // ── Accent — Milk II palette ────────────────────────────────────────────
  static const Color rust = Color(0xFF5C2420);
  static const Color blood = Color(0xFFCB2B2B);

  // ── Foreground ──────────────────────────────────────────────────────────
  static const Color chalk = Color(0xFFEDE0EC);   // Primary text
  static const Color dust = Color(0xFF9A7080);    // Secondary text
  static const Color ash = Color(0xFF6A4050);     // Disabled / hint
  static const Color ember = Color(0xFF4A2030);   // Subtle text

  // ── Semantic ────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFCB2B2B);
  static const Color divider = Color(0xFF1E000F);
  static const Color border = Color(0xFF2A0018);
  static const Color shadow = Color(0x80660020);
}
