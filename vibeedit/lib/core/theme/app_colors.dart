/// App color palette for VibeEdit AI
/// Following Material Design 3 with custom dark theme
library;

import 'package:flutter/material.dart';

/// Primary color palette for the app
abstract final class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY BRAND COLORS - Filmora/Premiere Pro Inspired
  // ═══════════════════════════════════════════════════════════════════════════

  // Main Accent - Purple/Magenta like Filmora
  static const Color primary = Color(0xFF8B5CF6); // Vivid Purple
  static const Color primaryLight = Color(0xFFA78BFA); // Light Purple
  static const Color primaryDark = Color(0xFF7C3AED); // Deep Purple

  // Secondary Accent - Cyan like Premiere Pro
  static const Color accent = Color(0xFF06B6D4); // Cyan-500
  static const Color accentLight = Color(0xFF22D3EE); // Cyan-400
  static const Color accentDark = Color(0xFF0891B2); // Cyan-600

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUND COLORS - Deep Dark Theme
  // ═══════════════════════════════════════════════════════════════════════════

  // True dark like professional video editors
  static const Color background = Color(0xFF000000); // Pure black for OLED
  static const Color backgroundLight = Color(0xFF141414); // Slightly lighter
  static const Color surface = Color(0xFF1A1A1A); // Panel backgrounds
  static const Color surfaceLight = Color(0xFF262626); // Elevated surfaces
  static const Color surfaceVariant = Color(0xFF333333); // Hover states

  // ═══════════════════════════════════════════════════════════════════════════
  // PANEL & CARD COLORS - Glassmorphism Ready
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFF2D2D2D);
  static const Color cardGlow = Color(0x338B5CF6); // Purple glow
  static const Color panelBackground = Color(0xFF171717);
  static const Color panelBorder = Color(0xFF252525);

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textMuted = Color(0xFF4D4D4D);

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF22C55E); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // ═══════════════════════════════════════════════════════════════════════════
  // TIMELINE & TRACK COLORS - Professional NLE Style
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color timelineBackground = Color(0xFF0A0A0A);
  static const Color timelineRuler = Color(0xFF1F1F1F);

  // Playhead with neon glow
  static const Color playhead = Color(0xFFFF3366); // Neon Pink/Red
  static const Color playheadGlow = Color(0x66FF3366);

  // Track colors - each track type has unique color
  static const Color videoTrack = Color(0xFF8B5CF6); // Purple
  static const Color videoTrackLight = Color(0xFFA78BFA);
  static const Color audioTrack = Color(0xFF06B6D4); // Cyan
  static const Color audioTrackLight = Color(0xFF22D3EE);
  static const Color textTrack = Color(0xFF22C55E); // Green
  static const Color textTrackLight = Color(0xFF4ADE80);
  static const Color effectsTrack = Color(0xFFF59E0B); // Amber

  // Clip colors
  static const Color clipSelected = Color(0xFFFFFFFF);
  static const Color clipBorder = Color(0xFF404040);
  static const Color clipHandle = Color(0xFF8B5CF6);

  // ═══════════════════════════════════════════════════════════════════════════
  // AI COPILOT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color aiOnline = Color(0xFF22C55E);
  static const Color aiProcessing = Color(0xFF8B5CF6);
  static const Color userMessage = Color(0xFF06B6D4);
  static const Color aiMessage = Color(0xFF1A1A1A);

  // ═══════════════════════════════════════════════════════════════════════════
  // NEON GLOW COLORS - For interactive elements
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color neonGreen = Color(0xFF22C55E);
  static const Color neonOrange = Color(0xFFF97316);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENT DEFINITIONS
  // ═══════════════════════════════════════════════════════════════════════════

  // Primary gradient - Purple to Cyan (Filmora style)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent gradient - Cyan to Green
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neon gradient - Pink to Purple
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonPink, neonPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Card gradient - Subtle dark gradient
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1F1F1F), Color(0xFF141414)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glass gradient - For glassmorphism effects
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x15FFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Timeline gradient - Very subtle
  static const LinearGradient timelineGradient = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF0A0A0A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Toolbar gradient
  static const LinearGradient toolbarGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF141414)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
