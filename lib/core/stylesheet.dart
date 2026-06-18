import 'package:flutter/material.dart';

abstract final class Stylesheet {
  // ── Colors ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFFFFFF);
  static const Color theme = Color(0xFF386BF6);
  static const Color secondary = Color(0xFF6B8CFF);
  static const Color label = Color(0xFF273B4A);
  static const Color secondaryLabel = Color(0xFF595959);
  static const Color tertiaryLabel = Color(0x78DFE9FF); // DFE9FF @ 47%
  static const Color themeLight = Color(0xFF9DB2CE);
  static const Color themeDark = Color(0xFF273B4A);
  static const Color blue = Color(0xFF386BF6);
  static const Color noteBackground = Color(0xFFDDEBFF);
  static const Color buttonPink = Color(0xFFFF2D55);
  // Verse highlight trio, all @ 33%. Each reduces two RGB channels so they stay
  // equally visible over the white verse background (a pure cyan/green only
  // dims one channel and disappears on white).
  static const Color highlight = Color(0x54FFDFDF); // pink — FFDFDF @ 33%
  static const Color highlightSecondary = Color(0x54DFDFFF); // blue — DFDFFF @ 33%
  static const Color highlightTertiary = Color(0x54DFFFDF); // green — DFFFDF @ 33%

  static const Color numberFieldFlash = Color(
    0xFFFFC9C9,
  ); // flash when a number field is auto-corrected

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6155F5), Color(0xFFFF2D8A)],
  );

  static const LinearGradient aiButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF386BF6), Color(0xFF9747FF)],
  );

  static const LinearGradient noteBackgroundAi = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDFC7FF), Color(0xFFFFB9C6)],
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static const List<BoxShadow> whiteCardShadow = [BoxShadow(blurRadius: 16, color: secondary)];

  static const List<BoxShadow> blackCardShadow = [
    BoxShadow(blurRadius: 16, color: Color(0x40000000)),
  ];

  static const List<BoxShadow> blueCardShadow = [
    BoxShadow(blurRadius: 16, color: Color(0x40002179)),
  ];

  static const List<BoxShadow> buttonShadow = [BoxShadow(blurRadius: 16, color: Color(0xFFFF2D8A))];

  static const List<BoxShadow> iconButtonWhiteShadow = [
    BoxShadow(blurRadius: 16, color: secondary),
  ];

  static const List<BoxShadow> iconButtonBlueShadow = [
    BoxShadow(blurRadius: 16, color: Color(0x80386BF6)),
  ];

  static const List<BoxShadow> saveButtonShadow = [
    BoxShadow(blurRadius: 4, color: Color(0xFF386BF6)),
  ];

  // ── Decorations ───────────────────────────────────────────────────────────
  static const BoxDecoration whiteCardDecoration = BoxDecoration(
    color: primary,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFFE6E9ED))),
    boxShadow: whiteCardShadow,
  );

  static const BoxDecoration whiteLargeCardDecoration = BoxDecoration(
    color: primary,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFFE6E9ED))),
    boxShadow: blackCardShadow,
  );

  static const BoxDecoration blueCardDecoration = BoxDecoration(
    color: blue,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    boxShadow: blueCardShadow,
  );

  static const BoxDecoration secondaryDecoration = BoxDecoration(
    color: secondary,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: secondary)),
    boxShadow: buttonShadow,
  );

  static const BoxDecoration unselectedButtonDecoration = BoxDecoration(
    color: primary,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: secondary)),
  );

  static const BoxDecoration selectedButtonDecoration = BoxDecoration(
    color: secondary,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static const BoxDecoration iconButtonWhiteDecoration = BoxDecoration(
    color: primary,
    borderRadius: BorderRadius.all(Radius.circular(40)),
    boxShadow: iconButtonWhiteShadow,
  );

  static const BoxDecoration iconButtonBlueDecoration = BoxDecoration(
    color: blue,
    borderRadius: BorderRadius.all(Radius.circular(40)),
    border: Border.fromBorderSide(BorderSide(color: themeLight)),
  );

  static const BoxDecoration rangeTextFieldDecoration = BoxDecoration(
    color: primary,
    borderRadius: BorderRadius.all(Radius.circular(8)),
    border: Border.fromBorderSide(BorderSide(color: Color(0x78DFE9FF))),
  );

  static const BoxDecoration numberTextFieldDecoration = BoxDecoration(
    color: noteBackground,
    borderRadius: BorderRadius.all(Radius.circular(8)),
    border: Border.fromBorderSide(BorderSide(color: noteBackground)),
  );

  static const BoxDecoration bigButtonDecoration = BoxDecoration(
    gradient: aiGradient,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static const BoxDecoration recordButtonDecoration = BoxDecoration(
    color: buttonPink,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static const BoxDecoration cardDecoration = BoxDecoration(
    color: noteBackground,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );

  // Verse highlight backgrounds — one per note in a chapter, cycled by recency.
  static const BoxDecoration verseHighlightDecoration = BoxDecoration(
    color: highlight,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const BoxDecoration verseHighlightSecondaryDecoration = BoxDecoration(
    color: highlightSecondary,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const BoxDecoration verseHighlightTertiaryDecoration = BoxDecoration(
    color: highlightTertiary,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const BoxDecoration cardAiDecoration = BoxDecoration(
    gradient: noteBackgroundAi,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    border: Border.fromBorderSide(BorderSide(color: noteBackground)),
  );

  static const BoxDecoration cardAddDecoration = BoxDecoration(
    gradient: noteBackgroundAi,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFFE6E9ED))),
  );

  static const BoxDecoration aiChatButtonDecoration = BoxDecoration(
    gradient: aiGradient,
    borderRadius: BorderRadius.all(Radius.circular(9999)),
  );

  static const BoxDecoration saveButtonDecoration = BoxDecoration(
    color: theme,
    borderRadius: BorderRadius.all(Radius.circular(9999)),
    border: Border.fromBorderSide(BorderSide(color: blue)),
  );

  // ── Padding ───────────────────────────────────────────────────────────────
  static const EdgeInsets iconButtonPadding = EdgeInsets.all(40);
  static const EdgeInsets bigButtonPadding = EdgeInsets.symmetric(vertical: 20);
  static const EdgeInsets recordButtonPadding = EdgeInsets.symmetric(vertical: 4);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets aiChatButtonPadding = EdgeInsets.all(16);
  static const EdgeInsets saveButtonPadding = EdgeInsets.all(16);

  // ── Icon Colors ───────────────────────────────────────────────────────────
  static const Color iconButtonWhiteIconColor = blue;
  static const Color iconButtonBlueIconColor = primary;
}
