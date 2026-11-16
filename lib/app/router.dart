import 'package:fabriscan/app/shell.dart';
import 'package:fabriscan/features/care/presentation/care_guide_screen.dart';
import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:fabriscan/features/catalog/presentation/browse_screens.dart';
import 'package:fabriscan/features/catalog/presentation/home_screen.dart';
import 'package:fabriscan/features/history/presentation/history_screens.dart';
import 'package:fabriscan/features/onboarding/presentation/onboarding_screens.dart';
import 'package:fabriscan/features/result/presentation/result_screen.dart';
import 'package:fabriscan/features/scan/presentation/scan_screens.dart';
import 'package:fabriscan/features/settings_help/presentation/settings_help_screens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Routes follow `docs/design/handoff-notes.md` §2.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/browse', builder: (_, _) => const BrowseScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (_, _) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/browse/search', builder: (_, _) => const SearchScreen()),
      GoRoute(
        path: '/browse/:categoryId',
        builder: (_, s) =>
            CategoryScreen(categoryId: s.pathParameters['categoryId']!),
      ),
      GoRoute(
        path: '/fabric/:id',
        builder: (_, s) =>
            FabricDetailScreen(fabricId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/fabric/:id/care',
        builder: (_, s) => CareGuideScreen(
          fabricId: s.pathParameters['id']!,
          section: CareSectionId.values
              .asNameMap()[s.uri.queryParameters['section']],
        ),
      ),
      GoRoute(
        path: '/scan/permission',
        builder: (_, s) =>
            PermissionScreen(denied: s.uri.queryParameters['denied'] == '1'),
      ),
      GoRoute(path: '/scan/camera', builder: (_, _) => const CameraScreen()),
      GoRoute(path: '/scan/review', builder: (_, _) => const ReviewScreen()),
      GoRoute(
        path: '/scan/analyzing',
        builder: (_, _) => const AnalyzingScreen(),
      ),
      GoRoute(path: '/result', builder: (_, _) => const ResultScreen()),
      GoRoute(
        path: '/history/:id',
        builder: (_, s) => HistoryDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(path: '/help', builder: (_, _) => const HelpScreen()),
      GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
    ],
  );
});
