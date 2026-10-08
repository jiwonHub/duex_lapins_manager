import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.index,
    required this.label,
    required this.value,
    required this.caption,
    this.compact = false,
  });

  final String index;
  final String label;
  final String value;
  final String caption;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.fromLTRB(16, 14, 16, 14)
          : const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        border: Border.all(color: AdminTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                index,
                style: AdminTypography.label(
                  fontSize: compact ? 8.5 : 9,
                  letterSpacing: 0.8,
                  color: AdminTheme.muted,
                ),
              ),
              const Spacer(),
              Text(
                label,
                style: AdminTypography.label(
                  fontSize: compact ? 9.5 : 10,
                  letterSpacing: compact ? 0.5 : 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AdminTypography.serif(
              fontSize: compact ? 31 : 38,
              height: 1.0,
            ),
          ),
          SizedBox(height: compact ? 9 : 12),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AdminTypography.body(
              fontSize: compact ? 10.5 : 11.5,
              height: 1.25,
              color: AdminTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}
