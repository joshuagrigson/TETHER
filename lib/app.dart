import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/tether_theme.dart';
import 'providers/relationship_provider.dart';
import 'screens/dashboard/north_star_dashboard_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

class TetherApp extends StatefulWidget {
  const TetherApp({super.key});

  @override
  State<TetherApp> createState() => _TetherAppState();
}

class _TetherAppState extends State<TetherApp> {
  late final Future<bool> _onboardingFuture;

  @override
  void initState() {
    super.initState();
    _onboardingFuture = _hasCompletedOnboarding();
  }

  Future<bool> _hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tether_onboarding_complete') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RelationshipProvider(),
      child: MaterialApp(
        title: 'TETHER',
        debugShowCheckedModeBanner: false,
        theme: TetherTheme.dark,
        home: FutureBuilder<bool>(
          future: _onboardingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _TetherLaunchScreen();
            }
            if (snapshot.data == true) {
              return const NorthStarDashboardScreen();
            }
            return const OnboardingScreen();
          },
        ),
      ),
    );
  }
}

class _TetherLaunchScreen extends StatelessWidget {
  const _TetherLaunchScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: TetherColors.obsidian,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hub_outlined, size: 46, color: TetherColors.violet),
            SizedBox(height: 18),
            Text(
              'TETHER',
              style: TextStyle(
                color: TetherColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
