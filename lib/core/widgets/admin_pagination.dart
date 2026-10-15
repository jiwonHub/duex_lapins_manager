import 'dart:math' as math;

import 'package:deux_lapins_manager/core/theme/admin_theme.dart';
import 'package:deux_lapins_manager/core/theme/admin_typography.dart';
import 'package:flutter/material.dart';

class AdminPagination extends StatelessWidget {
  const AdminPagination({
    super.key,
    required this.totalItems,
    required this.currentPage,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  static const pageSizeOptions = [
    10,
    20,
    50,
    100,
  ];

  final int totalItems;
  final int currentPage;
  final int pageSize;

  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  int get totalPages {
    if (totalItems == 0) {
      return 1;
    }

    return ((totalItems - 1) ~/ pageSize) + 1;
  }

  int get safePage {
    if (currentPage < 1) {
      return 1;
    }

    if (currentPage > totalPages) {
      return totalPages;
    }

    return currentPage;
  }

  @override
  Widget build(BuildContext context) {
    final start = totalItems == 0
        ? 0
        : ((safePage - 1) * pageSize) + 1;

    final end = totalItems == 0
        ? 0
        : math.min(
      safePage * pageSize,
      totalItems,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        border: Border(
          top: BorderSide(
            color: AdminTheme.line,
          ),
        ),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '총 $totalItems개  ·  $start-$end 표시',
            style: AdminTypography.body(
              fontSize: 11,
              color: AdminTheme.muted,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '페이지당',
                style: AdminTypography.body(
                  fontSize: 11,
                  color: AdminTheme.muted,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: AdminTheme.background,
                  border: Border.all(
                    color: AdminTheme.line,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: pageSize,
                    isDense: true,
                    items: pageSizeOptions
                        .map(
                          (value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '$value개',
                          style: AdminTypography.body(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onPageSizeChanged(value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 18),
              IconButton(
                onPressed: safePage > 1
                    ? () => onPageChanged(
                  safePage - 1,
                )
                    : null,
                tooltip: '이전 페이지',
                icon: const Icon(
                  Icons.chevron_left,
                  size: 20,
                ),
              ),
              Container(
                constraints: const BoxConstraints(
                  minWidth: 72,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$safePage / $totalPages',
                  style: AdminTypography.body(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: safePage < totalPages
                    ? () => onPageChanged(
                  safePage + 1,
                )
                    : null,
                tooltip: '다음 페이지',
                icon: const Icon(
                  Icons.chevron_right,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}