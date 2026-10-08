import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/ui/shared/admin_header.dart';
import 'package:duex_lapins_manager/ui/shared/admin_sidebar.dart';
import 'package:flutter/material.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1080;

        if (!desktop) {
          return Scaffold(
            key: _scaffoldKey,
            drawer: Drawer(
              width: 260,
              child: AdminSidebar(
                location: widget.location,
                closeDrawer: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  AdminHeader(
                    compact: true,
                    onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const Divider(height: 1),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 244,
                child: AdminSidebar(location: widget.location),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: Column(
                  children: [
                    const AdminHeader(),
                    const Divider(height: 1),
                    Expanded(
                      child: ColoredBox(
                        color: AdminTheme.background,
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
