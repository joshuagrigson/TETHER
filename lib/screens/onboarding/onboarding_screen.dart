import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/tether_theme.dart';
import '../dashboard/premium_dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      eyebrow: 'RELATIONSHIP INTELLIGENCE',
      title: 'Keep the people\nwho matter close.',
      body:
          'TETHER turns the relationships you care about into living bonds you can understand, strengthen, and remember.',
      icon: Icons.hub_outlined,
      accent: TetherColors.neon,
    ),
    _OnboardingPageData(
      eyebrow: 'BOND MEMORY',
      title: 'Remember what\nmatters to them.',
      body:
          'Capture conversations, memories, important dates, tags, and personal details before they disappear into the noise.',
      icon: Icons.auto_awesome_outlined,
      accent: TetherColors.violet,
    ),
    _OnboardingPageData(
      eyebrow: 'INTENTIONALITY ENGINE',
      title: 'Know who needs\nyou next.',
      body:
          'TETHER watches relationship cadence and health so you can spend less time remembering and more time showing up.',
      icon: Icons.insights_outlined,
      accent: TetherColors.neon,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tether_onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PremiumDashboardScreen()),
    );
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_page];

    return Scaffold(
      backgroundColor: TetherColors.obsidian,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 18, 0),
              child: Row(
                children: [
                  const _BrandMark(),
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        color: TetherColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => _OnboardingPage(
                  data: _pages[index],
                  pageIndex: index,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        width: index == _page ? 28 : 8,
                        decoration: BoxDecoration(
                          color: index == _page
                              ? page.accent
                              : TetherColors.line,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: page.accent,
                        foregroundColor: TetherColors.obsidian,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _page == _pages.length - 1
                            ? 'ENTER TETHER'
                            : 'CONTINUE',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data, required this.pageIndex});

  final _OnboardingPageData data;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _OrbitalCore(accent: data.accent, pageIndex: pageIndex),
          const SizedBox(height: 42),
          Text(
            data.eyebrow,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: data.accent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TetherColors.text,
              fontSize: 34,
              height: 1.04,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Text(
              data.body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TetherColors.muted,
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitalCore extends StatelessWidget {
  const _OrbitalCore({required this.accent, required this.pageIndex});

  final Color accent;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 212,
            height: 212,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.12)),
            ),
          ),
          Transform.rotate(
            angle: pageIndex * 0.48,
            child: Container(
              width: 164,
              height: 164,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.26)),
              ),
            ),
          ),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TetherColors.midnight,
              border: Border.all(color: accent.withValues(alpha: 0.65)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.12),
                  blurRadius: 38,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(Icons.hub_outlined, color: accent, size: 42),
          ),
          Positioned(
            top: 26,
            right: 34,
            child: _Node(accent: accent, size: 8),
          ),
          Positioned(
            bottom: 34,
            left: 24,
            child: _Node(accent: accent, size: 6),
          ),
          Positioned(
            bottom: 12,
            right: 72,
            child: _Node(accent: accent, size: 5),
          ),
        ],
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.accent, required this.size});

  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent,
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 12),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: TetherColors.neon,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.hub_outlined,
            size: 18,
            color: TetherColors.obsidian,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'TETHER',
          style: TextStyle(
            color: TetherColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.6,
          ),
        ),
      ],
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final Color accent;
}
