# FabriSCAN+ — Design → Flutter Handoff Notes

Version 0.1 · 2026-11-16 · Direction: **A. Hibla** · Status: awaiting client review (gate in `dev-handoff.md`).
Sources: `design-system.md`, `tokens.json`, `user-flows.md`, `prototype/index.html` (published artifact: https://claude.ai/artifact/KqwNyLhk9Dh5wVB7MxbJXU).

## 1. Theme setup (`lib/app/theme.dart`)
```dart
ColorScheme hiblaLight = const ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF2E3F8F), onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFDDE1F7), onPrimaryContainer: Color(0xFF17225A),
  secondary: Color(0xFF6B4E35), onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF2DEC8), onSecondaryContainer: Color(0xFF2A1A0B),
  tertiary: Color(0xFF3D6B37), onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFD3EBC8), onTertiaryContainer: Color(0xFF10290D),
  error: Color(0xFFB3261E), onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFF9DEDC), onErrorContainer: Color(0xFF410E0B),
  surface: Color(0xFFFAF6EE), onSurface: Color(0xFF3B2A1E), onSurfaceVariant: Color(0xFF6B5644),
  surfaceContainerLowest: Color(0xFFFFFFFF), surfaceContainerLow: Color(0xFFF6F0E4),
  surfaceContainer: Color(0xFFF1EADC), surfaceContainerHigh: Color(0xFFEBE3D3),
  surfaceContainerHighest: Color(0xFFE5DCCA),
  outline: Color(0xFF8C7A68), outlineVariant: Color(0xFFD8CCB9),
  inverseSurface: Color(0xFF3B2A1E), onInverseSurface: Color(0xFFFAF6EE),
  inversePrimary: Color(0xFFB7C2FF), scrim: Color(0xFF000000), shadow: Color(0xFF000000),
);
// hiblaDark: same keys, values from tokens.json → color.dark
```
- `ThemeData(useMaterial3: true, colorScheme: …, textTheme: hiblaTextTheme, extensions: [ConfidenceColors.light])`. Use `themeMode` from Settings (Light / Dark / System, stored in `app_prefs`).
- **`ConfidenceColors extends ThemeExtension`**: `high`, `highContainer`, `onHighContainer`, `possible…`, `notSure…` (values in `tokens.json`).
- **TextTheme:** display + headline roles use Fraunces; title, body and label roles use Plus Jakarta Sans. Sizes and weights are in `tokens.json → typeScale`. **Bundle the fonts as assets** (offline-first); don't fetch them at runtime.
- Component themes:
  - `filledButtonTheme`: min size 52, `StadiumBorder`
  - `cardTheme`: radius 22, elevation 0
  - `bottomSheetTheme`: radius 28, `showDragHandle: true`
  - `dialogTheme`: radius 28
  - `inputDecorationTheme`: filled, radius 12 top
  - `chipTheme`: `StadiumBorder`
  - `navigationBarTheme`: transparent background, indicator primaryContainer, `labelBehavior: alwaysShow`
- Icons: `material_symbols_icons` (Rounded). Active nav icon uses `fill: 1`.

## 2. Screen → widget mapping
| ID | Screen | Route (`go_router`) | Key widgets |
|---|---|---|---|
| S01 | Splash | `/splash` | `flutter_native_splash` for the native splash, then a `Scaffold` with an animated logo; redirects on `onboarding_done` |
| S02–S04 | Onboarding | `/onboarding` | `PageView` + `SmoothPageIndicator`-style dots (custom `AnimatedContainer`), `TextButton` Skip, `FilledButton` Next |
| S05 | Access choice | `/welcome` | `FilledButton` (Continue as Guest), `OutlinedButton`, `TextButton` |
| S06 | Home | `/` (shell tab 0) | `CustomScrollView`; bento grid = `SliverGrid`/`StaggeredGrid` of `Card.filled` + `InkWell`; recent strip = horizontal `ListView`; tip = `Card.filled(color: tertiaryContainer)` |
| — | Floating nav | `StatefulShellRoute.indexedStack` | `NavigationBar` (4 destinations) inside `ClipRRect(borderRadius: 999)` + `BackdropFilter`; centre Scan = custom `AnimatedContainer` button overlaid (or `FloatingActionButton` with `FloatingActionButtonLocation.centerDocked`); `Scaffold(extendBody: true)` |
| S07 | Permission primer / denied | `/scan/permission` | `permission_handler`; denied → `openAppSettings()`; `FilledButton.tonal` Upload instead |
| S08 | Camera | `/scan/camera` | `camera` `CameraPreview` full-bleed in a `Stack`; reticle = `CustomPainter` (4 corners, scale pulse); tips chip = glass `Container` + `AnimatedSwitcher`; shutter `GestureDetector` + `HapticFeedback.mediumImpact()` |
| S08 gallery | Photo picker | — | `image_picker.pickImage(source: gallery)` (system photo picker; Android 13+ needs no storage permission) |
| S09 | Review photo | `/scan/review` | `Image.file`, `OutlinedButton` Retake, `FilledButton` Use photo; error = banner when decode fails ("Couldn't open this photo. Try another.") |
| S10 | Analyzing | `/scan/analyzing` | `CustomPainter` scan line + thread overlay driven by `AnimationController` (repeat); `AnimatedSwitcher` for messages; `LinearProgressIndicator`; inference runs in an isolate |
| S11 | Result A | `/result` (state in extra) | `SingleChildScrollView`; `ConfidenceMeter` (custom); fabric name `headlineLarge`; `Wrap` of `Chip`s; `FiberHint` card; `FilledButton` View care guide; `TextButton` → `showModalBottomSheet` (other matches) |
| S12 | Result B | same | 3 × `FabricOptionCard` (`Card.outlined`), each with `FilledButton.tonal` "This one"; staggered entrance |
| S13 | Result C | same | Empty-state `Column`, tips list, `FilledButton` Retake, `FilledButton.tonal` Browse, scope `Card` |
| S14 | Fiber hint | component | `FiberHint` widget (secondaryContainer `Card.filled`), not dismissible; shown whenever `fiberContent.length > 1` |
| S15 | Care guide | `/fabric/:id/care` | `CustomScrollView`: `SliverAppBar` + photo hero with gradient scrim; disclaimer `Card`; sticky section chips = `SliverPersistentHeader` with `ActionChip`s (scroll with `Scrollable.ensureVisible`); 5 × `CareSectionCard` (`ExpansionTile` in `Card.filled`, initially expanded); stain types = `ChoiceChip` `Wrap`; Sources → `showModalBottomSheet` |
| S16 | Browse | `/browse` (shell tab 1) | `SliverAppBar.large`; `SearchBar` (opens S26); 4 category `Card`s with `Ink.image` + scrim |
| S17 | Category | `/browse/:categoryId` | `SliverGrid` 2 columns, `FabricCard` (aspect 4:5) |
| S18 | Fabric detail | `/fabric/:id` | `SliverAppBar` with hero image (`Hero` tag shared with `FabricCard`); fiber `Chip`s; feature list; `ListTile`s → care section |
| S19 | History | `/history` (shell tab 2) | `ListView` of `ListTile` in `Dismissible` (swipe-to-delete with confirm) + trailing delete `IconButton`; guest prompt `Card`; empty state widget |
| S20 | History item | `/history/:scanId` | Thumbnail, `ConfidenceMeter`, `FilledButton` care guide; delete = `showDialog(AlertDialog)` |
| S21 | Log in / Sign up / Forgot | `/auth?mode=` | `SegmentedButton` (Log in / Sign up), `TextFormField`s with `Form` validation, password visibility toggle, offline banner from `connectivity_plus` |
| S22 | Import guest scans | sheet | `showModalBottomSheet`, `isDismissible: false`; Yes → `HistoryRepository.claimGuestRows(uid)` |
| S23 | Profile & Settings | `/profile` (shell tab 3) | Account `Card`, `SegmentedButton` theme, `ListTile`s; Clear all / Delete account = `AlertDialog`; survey = `url_launcher` (hidden if no URL in `AppConfig`) |
| S24 | Help | `/help` | Static `ListView`; strings shared with the user's manual |
| S25 | About & privacy | `/about` | Static; versions from `package_info_plus` + `model_meta.json` + `catalog.json.contentVersion` |
| S26 | Search (Could) | `/browse/search` | `SearchAnchor` / `SearchBar` + filtered `ListView` (diacritic-insensitive: "pina" matches "Piña") |

### Custom widgets to build (in `lib/core/widgets/`)
- `ConfidenceMeter(level)`: chip (word + icon) + 3 segments. `Semantics(label: 'High match')`, with the percentage optional in a `Tooltip`.
- `FiberHint(fabric)`
- `CareLabelDisclaimer`
- `CareSectionCard(section, steps, citations)`
- `IronSetting(dots, text)`
- `FabricCard`
- `BentoTile`
- `GlassContainer(blur: bool)`
- `EmptyState`
- `SampleContentTag`: dev builds only; asserts it never appears in release

## 3. Motion specs
| Moment | Spec | Flutter |
|---|---|---|
| Screen push | 300 ms, fade + 8 dp rise, emphasized decelerate | `CustomTransitionPage` / `FadeThroughTransition` (`animations` pkg) |
| Scan FAB | Radius 18 → 28 on press (300 ms, emphasized decelerate); gentle 3.2 s "breathe" loop on Home | `AnimatedContainer` + `ShapeBorder` lerp |
| Shutter | Inner disc scales to 0.86 and morphs to a rounded square; white flash 350 ms; medium haptic | `AnimatedScale`, `HapticFeedback.mediumImpact()` |
| Reticle | Corners pulse to 0.94 scale, 2.4 s loop | `AnimationController.repeat(reverse: true)` |
| Analyzing | Scan line 1.4 s alternate, thread overlay scroll; total ≤ 2.5 s, or as long as inference takes | `CustomPainter` |
| Result card | Spring in: translateY 24 → 0, scale 0.96 → 1, 450 ms (overshoot ~1%) | `SpringSimulation` or `Curves.easeOutBack` (subtle) |
| Confidence meter | Segments fill left → right, 300 ms each, 100 ms stagger | `TweenAnimationBuilder` |
| Bottom sheet | 300 ms emphasized decelerate | default M3 |
| Reduce motion | All of the above become a 150 ms fade; no loops; analyzing shows a static icon + `LinearProgressIndicator` | `MediaQuery.disableAnimationsOf(context)` |

## 4. Behaviour notes for developers
- **Tap count:** after capture, Use photo → result → View care guide = 2 taps (A). In state B, tapping "This one" opens the care guide directly.
- **Saving:** A is saved when the result appears; B when the user picks; C never. "Other possible matches" in A replaces the saved fabric with the one the user picks.
- **Back stack after a scan:** camera and review are removed from the stack when Use photo is tapped, so Back from a result returns to where the scan started (Home, History, etc.).
- **Offline:** only S21 (auth), S23 sync status, and Take the survey show network states. Disable the primary button and show the amber offline banner; never block other features.
- **Glass blur on budget phones:** set `GlassContainer(blur: false)` when the device is low-end (e.g. `deviceInfo.totalMemory < 4 GB`); use the same fill at 92% opacity.
- **Text 1.3×:** no fixed heights on text containers; tiles use `minHeight`. Test with `MediaQuery(textScaler: TextScaler.linear(1.3))` in widget tests.
- **Semantics:** every `IconButton` has a `tooltip`. The confidence meter and iron dots expose text labels. The camera tip chip is a polite live region (`Semantics(liveRegion: true)`).

## 5. Assets needed from researchers
| Asset | Spec | Count |
|---|---|---|
| Fabric hero photos | Macro close-up, fabric fills the frame, natural light, no glare, square ≥ 1080 px, JPEG/WebP | 1 per fabric (18), +1 optional "drape" photo |
| Category cover photos | Garment or fabric in context, 16:9 ≥ 1280 px | 4 |
| Care content | 5 sections × 18 fabrics, numbered steps, iron setting (dots + °C), stain steps per stain type (food & oil, sweat, make-up, ink) | per `fabric-catalog.md` |
| Citations | APA 7, ≥ 1 per section, with reviewer and date | ≥ 90 |
| Identifying features | 3 short "check" phrases per fabric | 18 × 3 |
| Researcher names | For About | 8 |
| Care tip of the day | 1–2 sentences each, cited | ≥ 10 (Could) |
| Illustrations | Onboarding (3) and empty states (History, Can't identify, Camera off). The prototype uses simple shape compositions; a designer or researcher can redraw them in the same style | 6 |

## 6. Open design questions (for client review)
1. **Percentage shown?** The prototype hides the raw percentage. Should it appear as secondary text (e.g. "about 86%") under the confidence word? (PRD §6 allows it.) Design recommendation: hide it for TAM. It adds no clarity and invites "is that accurate?" questions.
2. **State B wording:** "This could be…" + Option 1/2/3. Is that clear to respondents, or would "Which one is it?" be better?
3. **Fiber hint placement:** shown in full on the result and fabric detail, and as a one-line reminder on the care guide. OK?
4. **Care guide default:** all 5 sections expanded (scrollable, with jump chips), or collapsed so users open one at a time?
5. **Care tip of the day on Home:** keep it (needs ~10 cited tips from researchers) or drop it to reduce content work?
6. **Category photos vs textures:** can the researchers supply real garment photos for the 4 category tiles?
7. **Care-label symbols (US-22, Could):** if the researchers supply ISO 3758 symbols, they'll sit next to each section title. Confirm whether they will.
