import 'package:duex_lapins_manager/app/app_router.dart';
import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:flutter/material.dart';

class DuexLapinsAdminApp extends StatelessWidget {
  const DuexLapinsAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DUEX LAPINS 관리자',
      theme: AdminTheme.light,
      routerConfig: adminRouter,
    );
  }
}
