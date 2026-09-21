import 'package:flutter/material.dart';

/// MoTA brand color palette — inspired by the Indian government's
/// saffron-white-green tricolor with a professional navy anchor.
class AppColors {
  AppColors._();

  // ── Primary Brand ──────────────────────────────────────────────
  static const Color primary = Color(0xFF1B4F72);        // Deep navy
  static const Color primaryLight = Color(0xFF2E86C1);   // Bright blue
  static const Color primaryDark = Color(0xFF0D2F4F);    // Darkest navy

  // ── Accent / Saffron ──────────────────────────────────────────
  static const Color accent = Color(0xFFF39C12);         // Saffron gold
  static const Color accentLight = Color(0xFFF7DC6F);    // Light gold
  static const Color accentDark = Color(0xFFD68910);     // Deep saffron

  // ── Success / Green ───────────────────────────────────────────
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFFD5F5E3);
  static const Color successDark = Color(0xFF1E8449);

  // ── Error / Red ───────────────────────────────────────────────
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFADBD8);
  static const Color errorDark = Color(0xFFC0392B);

  // ── Warning / Orange ──────────────────────────────────────────
  static const Color warning = Color(0xFFE67E22);
  static const Color warningLight = Color(0xFFFDEBD0);
  static const Color warningDark = Color(0xFFCA6F1E);

  // ── Info / Blue ───────────────────────────────────────────────
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFFD6EAF8);
  static const Color infoDark = Color(0xFF2471A3);

  // ── Neutrals ──────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F3F5);
  static const Color border = Color(0xFFDEE2E6);
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFE9ECEF);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF212529);

  // ── Dark Theme ────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  // ── Status Colors ─────────────────────────────────────────────
  static const Color verified = success;
  static const Color pending = warning;
  static const Color rejected = error;
  static const Color inProgress = info;
  static const Color draft = Color(0xFF95A5A6);
  static const Color mismatch = Color(0xFF8E44AD);

  // ── Scholarship Scheme Colors ─────────────────────────────────
  static const Color preMatric = Color(0xFF2ECC71);
  static const Color postMatric = Color(0xFF3498DB);
  static const Color topClass = Color(0xFF9B59B6);
  static const Color nfst = Color(0xFFE67E22);
  static const Color nos = Color(0xFF1ABC9C);
}
