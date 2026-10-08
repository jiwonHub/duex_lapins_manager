import 'package:duex_lapins_manager/app/admin_shell.dart';
import 'package:duex_lapins_manager/app/app_routes.dart';
import 'package:duex_lapins_manager/ui/claims/claims_page.dart';
import 'package:duex_lapins_manager/ui/content/content_page.dart';
import 'package:duex_lapins_manager/ui/customers/customers_page.dart';
import 'package:duex_lapins_manager/ui/dashboard/dashboard_page.dart';
import 'package:duex_lapins_manager/ui/inquiries/inquiries_page.dart';
import 'package:duex_lapins_manager/ui/inventory/inventory_page.dart';
import 'package:duex_lapins_manager/ui/journal/journal_editor_page.dart';
import 'package:duex_lapins_manager/ui/journal/journal_page.dart';
import 'package:duex_lapins_manager/ui/orders/order_detail_page.dart';
import 'package:duex_lapins_manager/ui/orders/orders_page.dart';
import 'package:duex_lapins_manager/ui/products/product_create_page.dart';
import 'package:duex_lapins_manager/ui/products/products_page.dart';
import 'package:duex_lapins_manager/ui/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final adminRouter = GoRouter(
  initialLocation: AdminRoutePath.dashboard,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AdminShell(
        location: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(
          path: AdminRoutePath.dashboard,
          pageBuilder: (context, state) => _page(state, const DashboardPage()),
        ),
        GoRoute(
          path: AdminRoutePath.products,
          pageBuilder: (context, state) => _page(state, const ProductsPage()),
        ),
        GoRoute(
          path: AdminRoutePath.productCreate,
          pageBuilder: (context, state) => _page(
            state,
            const ProductCreatePage(),
          ),
        ),
        GoRoute(
          path: '/products/:productId/edit',
          pageBuilder: (context, state) => _page(
            state,
            ProductCreatePage(productId: state.pathParameters['productId']),
          ),
        ),
        GoRoute(
          path: AdminRoutePath.inventory,
          pageBuilder: (context, state) => _page(state, const InventoryPage()),
        ),
        GoRoute(
          path: AdminRoutePath.orders,
          pageBuilder: (context, state) => _page(state, const OrdersPage()),
        ),
        GoRoute(
          path: '/orders/:orderId',
          pageBuilder: (context, state) => _page(
            state,
            OrderDetailPage(orderId: state.pathParameters['orderId'] ?? ''),
          ),
        ),
        GoRoute(
          path: AdminRoutePath.claims,
          pageBuilder: (context, state) => _page(state, const ClaimsPage()),
        ),
        GoRoute(
          path: AdminRoutePath.customers,
          pageBuilder: (context, state) => _page(state, const CustomersPage()),
        ),
        GoRoute(
          path: AdminRoutePath.inquiries,
          pageBuilder: (context, state) => _page(state, const InquiriesPage()),
        ),
        GoRoute(
          path: AdminRoutePath.homeContent,
          pageBuilder: (context, state) => _page(state, const ContentPage()),
        ),
        GoRoute(
          path: AdminRoutePath.journal,
          pageBuilder: (context, state) => _page(state, const JournalPage()),
        ),
        GoRoute(
          path: AdminRoutePath.journalCreate,
          pageBuilder: (context, state) => _page(
            state,
            const JournalEditorPage(),
          ),
        ),
        GoRoute(
          path: '/journal/:journalId/edit',
          pageBuilder: (context, state) => _page(
            state,
            JournalEditorPage(journalId: state.pathParameters['journalId']),
          ),
        ),
        GoRoute(
          path: AdminRoutePath.settings,
          pageBuilder: (context, state) => _page(state, const SettingsPage()),
        ),
      ],
    ),
  ],
);

Page<void> _page(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}
