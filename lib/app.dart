import 'package:flutter/material.dart';
import 'core/theme/tether_theme.dart';
import 'screens/dashboard/dashboard_screen.dart';

class TetherApp extends StatelessWidget {
  const TetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TETHER',
      debugShowCheckedModeBanner: false,
      theme: TetherTheme.dark,
      home: const DashboardScreen(),
    );
  }
}
