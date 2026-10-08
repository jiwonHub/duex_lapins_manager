import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:flutter/material.dart';

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.trailing,
    this.compact = false,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 720;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: AdminTypography.label(
            fontSize: compact ? 9 : 9.5,
            letterSpacing: compact ? 0.8 : 1.8,
            color: AdminTheme.muted,
          ),
        ),
        SizedBox(height: compact ? 6 : 10),
        Text(
          title,
          style: AdminTypography.serif(
            fontSize: compact ? 36 : (narrow ? 40 : 52),
            height: 0.92,
          ),
        ),
        SizedBox(height: compact ? 7 : 12),
        Text(
          description,
          style: AdminTypography.body(
            fontSize: compact ? 11.5 : 12.5,
            color: AdminTheme.muted,
          ),
        ),
      ],
    );

    if (narrow || trailing == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          copy,
          if (trailing != null) ...[
            SizedBox(height: compact ? 12 : 20),
            trailing!,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: copy),
        trailing!,
      ],
    );
  }
}
