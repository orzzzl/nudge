import 'package:flutter/material.dart';

/// The "macaron" palette, lifted verbatim from the approved mockup
/// `docs/mockups/cute.html`. This is the single source of truth for color —
/// the theme, the candy primitives, and (in tasks 15/16) every screen pull
/// from here, so no widget hard-codes a hex at the call site.
abstract final class CuteColors {
  // Backdrop.
  static const cream = Color(0xFFFFF7EF); // page background
  static const blobPeach = Color(0xFFFFE9D6); // gradient blob
  static const blobMatcha = Color(0xFFE2F5E6); // gradient blob
  static const blobLavender = Color(0xFFF3E6FF); // gradient blob

  // Surfaces.
  static const surface = Color(0xFFFFFDFA); // cards, sheets, bars
  static const white = Color(0xFFFFFFFF);

  // Matcha green family (brand).
  static const matcha = Color(0xFF3F7D5C); // brand / primary text
  static const matchaVivid = Color(0xFF2E9E6B); // emphasis
  static const matchaGradientTop = Color(0xFF8AD6A3);
  static const matchaGradientBottom = Color(0xFF5CC78F);
  static const matchaCandyShadow = Color(0xFF4FB87F); // hard offset shadow

  // Peach family (secondary / "me" accents).
  static const peachGradientTop = Color(0xFFFFB07C);
  static const peachGradientBottom = Color(0xFFFF9B6A);
  static const peachCandyShadow = Color(0xFFF08A55);

  // Text.
  static const textBrown = Color(0xFF5A4A3F); // body
  static const textMuted = Color(0xFFB6A395);
  static const textMuted2 = Color(0xFFA8917F);
  static const textFaint = Color(0xFFCDB9A8);
  static const textFaint2 = Color(0xFFC4B09C);

  // Borders.
  static const borderCream = Color(0xFFF4E7D8);
  static const borderPeach = Color(0xFFFFE0C2);
  static const borderPeach2 = Color(0xFFFFE3CD);
  static const borderMint = Color(0xFFC4EBD1);
  static const borderNeutral = Color(0xFFEADFD2);

  // Tinted fills.
  static const mintConfirm = Color(0xFFEAFAF0); // confirm bg / active tab pill
  static const fieldBg = Color(0xFFFFF3E8);
  static const fieldBg2 = Color(
    0xFFFFF2E4,
  ); // gear button bg / capsule mini-chip
  static const gearShadow = Color(0xFFF0DDCA);

  // Chip / capsule peach-brown ink (duration chips, capsule mini-chip text).
  static const chipBrown = Color(0xFFC89368);

  // Capsule hard shadow (mockup `.capsule box-shadow:0 5px 0 #ffe9d6` == blobPeach).
  static const capsuleShadow = blobPeach;

  // Faint weekly bar (a day with no planned time) + its hard shadow.
  static const barFaint = Color(0xFFECE3D8);
  static const barFaintShadow = Color(0xFFE0D4C5);

  // Streak pill (amber) — bg / border / hard shadow / text.
  static const streakBg = Color(0xFFFFF3E0);
  static const streakBorder = Color(0xFFFFE0B3);
  static const streakShadow = Color(0xFFFFECD1);
  static const streakText = Color(0xFFE08A2E);

  // Ledger row divider (mockup `.li border-bottom #f7efe5`).
  static const rowDivider = Color(0xFFF7EFE5);

  // ── Todo list — mockup `todo-tab.html` ────────────────────────────────────
  // List item card: white fill, cream border, hard offset shadow.
  static const todoCardBorder = Color(0xFFF1E7DA);
  static const todoCardShadow = Color(0xFFF4ECE1);
  // Archived item: flatter, dimmed via colour (never opacity — see task 26).
  static const todoArchBg = Color(0xFFF9F3EA);
  static const todoArchBorder = Color(0xFFEFE6DA);
  // Permanent item: lavender-tinted card.
  static const todoPermBg = Color(0xFFFAF6FF);
  static const todoPermBorder = Color(0xFFECE0FB);

  // Status dot (`.tstat`): border + fill + glyph colour per the 5 states.
  static const todoStatusTodoBorder = Color(0xFFDCCCBA);
  static const todoStatusTodoBg = Color(0xFFF8F2EA);
  static const todoStatusPauseBorder = Color(0xFFFFCE73);
  static const todoStatusPauseBg = Color(0xFFFFF6E6);
  static const todoStatusPauseGlyph = Color(0xFFDD9B2E);
  static const todoStatusDropBorder = Color(0xFFDCCCBA);
  static const todoStatusDropBg = Color(0xFFEFE7DC);
  static const todoStatusDropGlyph = Color(0xFFB6A395);

  // Priority flag (`.pflag`): text / bg / border per priority.
  static const todoP0Text = Color(0xFFD9745F);
  static const todoP0Bg = Color(0xFFFDEEEB);
  static const todoP0Border = Color(0xFFF3D4CD);
  static const todoP1Text = Color(0xFFDD9B2E);
  static const todoP1Bg = Color(0xFFFFF6E6);
  static const todoP1Border = Color(0xFFFFE1A8);
  static const todoP2Text = Color(0xFF3F9E6B);
  static const todoP2Bg = Color(0xFFEAFAF0);
  static const todoP2Border = Color(0xFFC4EBD1);
  static const todoPermText = Color(0xFF8A6FB0);
  static const todoPermFlagBg = Color(0xFFF3E6FF);
  static const todoPermFlagBorder = Color(0xFFE0CCF5);

  // Due-date preview text: muted normally, coral when overdue.
  static const todoDueText = textFaint2;
  static const todoDueOver = Color(0xFFD9745F);

  // Gradients used widely enough to name once.
  static const matchaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [matchaGradientTop, matchaGradientBottom],
  );
  static const peachGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [peachGradientTop, peachGradientBottom],
  );
}
