import 'package:duex_lapins_manager/app/app_routes.dart';
import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.location,
    this.closeDrawer,
  });

  final String location;
  final VoidCallback? closeDrawer;

  void _go(BuildContext context, String path) {
    context.go(path);
    closeDrawer?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AdminTheme.background,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _go(context, AdminRoutePath.dashboard),
              child: SizedBox(
                height: 76,
                width: 172,
                child: Image.asset(
                  'assets/images/duex_lapins_logo.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '관리자 운영 시스템',
              style: AdminTypography.label(
                fontSize: 9,
                letterSpacing: 1.25,
                color: AdminTheme.muted,
              ),
            ),
            const SizedBox(height: 26),
            const Divider(height: 1),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _group('운영'),
                    const SizedBox(height: 7),
                    _item(context, '대시보드', AdminRoutePath.dashboard),
                    const SizedBox(height: 18),
                    _group('판매 관리'),
                    const SizedBox(height: 7),
                    _item(context, '상품 관리', AdminRoutePath.products),
                    _item(context, '재고 관리', AdminRoutePath.inventory),
                    _item(context, '주문 관리', AdminRoutePath.orders),
                    _item(context, '취소·교환·반품', AdminRoutePath.claims),
                    const SizedBox(height: 18),
                    _group('고객 관리'),
                    const SizedBox(height: 7),
                    _item(context, '회원 관리', AdminRoutePath.customers),
                    _item(context, '문의 관리', AdminRoutePath.inquiries),
                    const SizedBox(height: 18),
                    _group('콘텐츠 관리'),
                    const SizedBox(height: 7),
                    _item(context, '홈페이지 관리', AdminRoutePath.homeContent),
                    _item(context, '저널 관리', AdminRoutePath.journal),
                    const SizedBox(height: 18),
                    _group('시스템'),
                    const SizedBox(height: 7),
                    _item(context, '기본 설정', AdminRoutePath.settings),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 17),
            Text(
              'DUEX LAPINS 관리자 페이지',
              style: AdminTypography.label(
                fontSize: 9,
                letterSpacing: 0.95,
                color: AdminTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group(String value) {
    return Text(
      value,
      style: AdminTypography.label(
        fontSize: 9,
        letterSpacing: 1.6,
        color: AdminTheme.muted,
      ),
    );
  }

  Widget _item(BuildContext context, String label, String path) {
    final selected = _matches(path);

    return InkWell(
      onTap: () => _go(context, path),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AdminTypography.label(
                  fontSize: 11,
                  letterSpacing: 1.3,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 28 : 0,
              height: 1,
              color: AdminTheme.text,
            ),
          ],
        ),
      ),
    );
  }

  bool _matches(String path) {
    if (path == AdminRoutePath.products) return location.startsWith('/products');
    if (path == AdminRoutePath.orders) return location.startsWith('/orders');
    if (path == AdminRoutePath.journal) return location.startsWith('/journal');
    return location == path;
  }
}
