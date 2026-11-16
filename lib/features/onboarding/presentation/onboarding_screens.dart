import 'dart:async';

import 'package:fabriscan/core/db/prefs.dart';
import 'package:fabriscan/core/widgets/banners.dart';
import 'package:fabriscan/core/widgets/hibla_logo.dart';
import 'package:fabriscan/features/catalog/data/catalog_repository.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// S01 Splash. Waits for settings + catalog (and a short beat for the logo),
/// then goes to onboarding on first launch, otherwise Home.
class SplashScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_route());
  }

  Future<void> _route() async {
    final beat = Future<void>.delayed(const Duration(milliseconds: 1400));
    final catalog = ref.read(catalogProvider.future);
    final settings = await ref.read(settingsProvider.future);
    await catalog;
    await beat;
    if (!mounted) return;
    context.go(settings.onboardingDone ? '/' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 18,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: reduce ? 1 : 0.8, end: 1),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutBack,
                      builder: (context, v, child) => Opacity(
                        opacity: ((v - 0.8) / 0.2).clamp(0, 1),
                        child: Transform.scale(scale: v, child: child),
                      ),
                      child: const HiblaLogo(size: 88),
                    ),
                    const Wordmark(),
                    Text(
                      l.splashTagline,
                      style: t.textTheme.bodyLarge?.copyWith(
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Text(
                l.splashCredit,
                textAlign: TextAlign.center,
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// S02–S04 Onboarding (US-01): 3 pages, Skip on every page.
class OnboardingScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) context.go('/welcome');
  }

  void _to(int i) => MediaQuery.disableAnimationsOf(context)
      ? _pages.jumpToPage(i)
      : _pages.animateToPage(
          i,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final pages = [
      (l.onb1Title, l.onb1Body, Symbols.photo_camera_rounded),
      (l.onb2Title, l.onb2Body, Symbols.menu_book_rounded),
      (l.onb3Title, l.onb3Body, Symbols.history_rounded),
    ];
    final last = _index == pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(onPressed: _finish, child: Text(l.onbSkip)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final (title, body, icon) = pages[i];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      spacing: 24,
                      children: [
                        const SizedBox(height: 8),
                        _Illustration(icon: icon),
                        Text(
                          title,
                          style: t.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          body,
                          style: t.textTheme.bodyLarge?.copyWith(
                            color: t.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Semantics(
              label: l.onbStep(_index + 1, pages.length),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  for (var i = 0; i < pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: i == _index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? t.colorScheme.primary
                            : t.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Row(
                spacing: 8,
                children: [
                  if (_index > 0)
                    OutlinedButton(
                      onPressed: () => _to(_index - 1),
                      child: Text(l.onbBack),
                    ),
                  Expanded(
                    child: FilledButton(
                      onPressed: last ? _finish : () => _to(_index + 1),
                      child: Text(last ? l.onbGetStarted : l.onbNext),
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

class _Illustration extends StatelessWidget {
  const new({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox(
        width: 240,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 220,
              height: 200,
              decoration: BoxDecoration(
                color: s.secondaryContainer,
                borderRadius: BorderRadius.circular(80),
              ),
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: s.primary,
                borderRadius: BorderRadius.circular(36),
              ),
              child: Icon(icon, size: 56, color: s.onPrimary, fill: 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// S05 Access choice (US-02): guest is the primary path; login never blocks.
class WelcomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              spacing: 28,
              children: [
                Column(
                  spacing: 14,
                  children: [
                    const HiblaLogo(size: 64),
                    Text(l.welcomeTitle, style: t.textTheme.headlineMedium),
                    Text(
                      l.welcomeBody,
                      style: t.textTheme.bodyLarge?.copyWith(
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Symbols.arrow_forward_rounded),
                      label: Text(l.welcomeGuest),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          showComingSoon(context, l.comingAccounts),
                      child: Text(l.welcomeLogin),
                    ),
                    TextButton(
                      onPressed: () =>
                          showComingSoon(context, l.comingAccounts),
                      child: Text(l.welcomeSignup),
                    ),
                  ],
                ),
                Text(
                  l.welcomeNote,
                  style: t.textTheme.bodySmall?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
