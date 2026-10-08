import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:flutter/material.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({
    super.key,
    this.compact = false,
    this.onMenu,
  });

  final bool compact;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return SizedBox(
        height: 66,
        child: Row(
          children: [
            IconButton(
              onPressed: onMenu,
              icon: const Icon(Icons.menu, size: 21),
            ),
            const SizedBox(width: 4),
            Text(
              'DUEX LAPINS / 관리자',
              style: AdminTypography.label(
                fontSize: 10,
                letterSpacing: 1.25,
              ),
            ),
            const Spacer(),
            const _AdminIdentity(),
            const SizedBox(width: 14),
          ],
        ),
      );
    }

    return SizedBox(
      height: 86,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: Text(
                'DUEX LAPINS / 관리자',
                style: AdminTypography.label(
                  fontSize: 9.5,
                  letterSpacing: 1.5,
                  color: AdminTheme.muted,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 430,
              child: TextField(
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '상품, 주문번호, 회원을 검색해보세요',
                  prefixIcon: Icon(Icons.search, size: 17),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: const Text('스토어 보기'),
                  ),
                  const SizedBox(width: 12),
                  const _AdminIdentity(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminIdentity extends StatelessWidget {
  const _AdminIdentity();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '관리자',
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AdminTheme.text,
          border: Border.all(color: AdminTheme.text),
        ),
        child: Text(
          '관',
          style: AdminTypography.serif(
            fontSize: 18,
            color: AdminTheme.background,
          ),
        ),
      ),
    );
  }
}
