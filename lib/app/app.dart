import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import '../services/scholarship/scholarship_data_service.dart';

class TribalScholarApp extends StatelessWidget {
  const TribalScholarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScholarshipDataService(),
      child: MaterialApp.router(
        title: 'Tribal Scholar Saathi',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}