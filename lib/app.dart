import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/tether_theme.dart';
import 'providers/relationship_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';

class TetherApp extends StatelessWidget {
  const TetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RelationshipProvider(),
      child: MaterialApp(
        title: 'TETHER',
        debugShowCheckedModeBanner: false,
        theme: TetherTheme.dark,
        home: const DashboardScreen(),
      ),
    );
  }
}
