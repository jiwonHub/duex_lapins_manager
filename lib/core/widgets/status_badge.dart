import 'package:deux_lapins_manager/core/theme/admin_typography.dart';
import 'package:flutter/material.dart';

enum StatusBadgeTone {
  neutral,
  strong,
  success,
  warning,
  danger,
  info,
  purple,
  teal,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.text,
    this.tone,
    this.emphasis = false,
    this.danger = false,
    this.showDot = true,
  });

  final String text;
  final StatusBadgeTone? tone;
  final bool emphasis;
  final bool danger;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final effectiveTone = tone ??
        (danger
            ? StatusBadgeTone.danger
            : emphasis
                ? StatusBadgeTone.strong
                : StatusBadgeTone.neutral);

    final colors = _colors(effectiveTone);

    return Text(
      text,
      style: AdminTypography.label(
        fontSize: 9.5,
        letterSpacing: 0.7,
        color: colors.foreground,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  _StatusBadgeColors _colors(StatusBadgeTone tone) {
    return switch (tone) {
      StatusBadgeTone.strong => const _StatusBadgeColors(
          foreground: Color(0xFF2B241E),
          background: Color(0xFFE8E1D8),
          border: Color(0xFFBEB2A5),
        ),
      StatusBadgeTone.success => const _StatusBadgeColors(
          foreground: Color(0xFF365D3E),
          background: Color(0xFFE1EBDD),
          border: Color(0xFFA7BCA4),
        ),
      StatusBadgeTone.warning => const _StatusBadgeColors(
          foreground: Color(0xFF8A5A18),
          background: Color(0xFFF3E8D0),
          border: Color(0xFFD7B97F),
        ),
      StatusBadgeTone.danger => const _StatusBadgeColors(
          foreground: Color(0xFF953D35),
          background: Color(0xFFF2DEDA),
          border: Color(0xFFD3A19A),
        ),
      StatusBadgeTone.info => const _StatusBadgeColors(
          foreground: Color(0xFF365F7A),
          background: Color(0xFFDFEAF0),
          border: Color(0xFFA7C0CE),
        ),
      StatusBadgeTone.purple => const _StatusBadgeColors(
          foreground: Color(0xFF675079),
          background: Color(0xFFEAE2EF),
          border: Color(0xFFBBA8C7),
        ),
      StatusBadgeTone.teal => const _StatusBadgeColors(
          foreground: Color(0xFF356861),
          background: Color(0xFFDDEBE7),
          border: Color(0xFF9EBFB8),
        ),
      StatusBadgeTone.neutral => const _StatusBadgeColors(
          foreground: Color(0xFF625E57),
          background: Color(0xFFEDE9E2),
          border: Color(0xFFC8C1B6),
        ),
    };
  }
}

class _StatusBadgeColors {
  const _StatusBadgeColors({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}
