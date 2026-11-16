# FabriSCAN+ — Design System "Hibla"

Version 0.1 · 2026-11-16 · Status: chosen direction (A. Hibla), pending client review.
Machine-readable values: `tokens.json`. Mood board: `directions.html`. Prototype: `prototype/index.html`.
Target: **Flutter, Material 3** (`useMaterial3: true`). Every component below names the widget it maps to.

## 1. Concept
*Hibla* is Filipino for "fiber". The surfaces are warm piña cream, the text is abacá brown and the primary is inabel indigo. Leaf green marks sustainability (SDG 12) cues. Fabric names are set in a soft serif (Fraunces), so a result reads like an entry in a textile reference book. All UI text uses Plus Jakarta Sans.

## 2. Colour (M3 roles)
Every role maps directly to `ColorScheme`. The three confidence colours go into a `ThemeExtension<ConfidenceColors>`.

| Role | Light | Dark | Use |
|---|---|---|---|
| primary / onPrimary | `#2E3F8F` / `#FFFFFF` | `#B7C2FF` / `#15205A` | Scan button, main CTAs, active nav |
| primaryContainer / on | `#DDE1F7` / `#17225A` | `#34418A` / `#DDE1FF` | Scan FAB inside tile, selected chips |
| secondary / on | `#6B4E35` / `#FFFFFF` | `#DCC1A6` / `#3D2914` | Fiber-content chips, step numbers |
| secondaryContainer / on | `#F2DEC8` / `#2A1A0B` | `#55402B` / `#F2DEC8` | Fiber hint banner, category tags |
| tertiary / on | `#3D6B37` / `#FFFFFF` | `#9FD39A` / `#0E3A10` | Sustainability ("Garment life extended") |
| tertiaryContainer / on | `#D3EBC8` / `#10290D` | `#255322` / `#D3EBC8` | Care tip of the day |
| error / on | `#B3261E` / `#FFFFFF` | `#FFB4AB` / `#690005` | Form errors, destructive actions |
| errorContainer / on | `#F9DEDC` / `#410E0B` | `#93000A` / `#FFDAD6` | Error banners |
| surface / onSurface | `#FAF6EE` / `#3B2A1E` | `#17130F` / `#F1E8DA` | App background, body text |
| onSurfaceVariant | `#6B5644` | `#CDBFAE` | Secondary text, captions |
| surfaceContainerLowest…Highest | `#FFFFFF` `#F6F0E4` `#F1EADC` `#EBE3D3` `#E5DCCA` | `#120E0B` `#1F1A15` `#2A241E` `#342D26` `#3F3730` | Cards, tiles, sheets, fields |
| outline / outlineVariant | `#8C7A68` / `#D8CCB9` | `#9A8B7A` / `#4E4337` | Borders (non-text only), dividers |
| inverseSurface / onInverse | `#3B2A1E` / `#FAF6EE` | `#F1E8DA` / `#3B2A1E` | Snackbars |
| **confHigh** (+container/on) | `#2F6B3A` (`#D5EDD3`/`#0F2E14`) | `#8FD49A` (`#1E4A26`/`#D5EDD3`) | "High match" |
| **confPossible** (+container/on) | `#8A5A00` (`#FBE7C2`/`#2E1D00`) | `#F2C46B` (`#5A3D00`/`#FBE7C2`) | "Possible match" |
| **confNotSure** (+container/on) | `#A23A2A` (`#F9DCD5`/`#3D0A03`) | `#FFB4A6` (`#7A2618`/`#F9DCD5`) | "Not sure" / can't identify |

### Contrast (WCAG 2.x, computed)
| Text on background | Light | Dark |
|---|---|---|
| onSurface / surface | 12.7 | 15.2 |
| onSurfaceVariant / surface | 6.4 | 10.3 |
| onSurfaceVariant / surfaceContainerHighest (worst case) | 5.1 | 6.5 |
| onPrimary / primary | 9.4 | 8.8 |
| onPrimaryContainer / primaryContainer | 11.5 | 7.2 |
| onSecondaryContainer / secondaryContainer | 12.8 | 7.5 |
| onTertiary / tertiary | 6.3 | 7.5 |
| primary text / surface | 8.8 | 10.7 |
| error / surface | 6.1 | 10.9 |
| confHigh / confPossible / confNotSure on surfaceContainerLow | 5.6 / 5.2 / 5.8 | 9.9 / 10.6 / 10.1 |
| on-conf containers | 11.9 / 13.4 / 13.1 | 8.2 / 8.2 / 7.7 |
| White on camera glass (`rgba(23,19,15,.62)`) over a light fabric | 9.3 (worst case) | same |
| White on photo scrim (bottom of gradient, `rgba(23,19,15,.82)`) | ≥ 10 | same |
| outline / surface (non-text, needs 3:1) | 3.8 | 5.6 |

**Rule:** confidence is never shown by colour alone. Each level has a word ("High match", "Possible match", "Not sure"), an icon (`verified`, `help`, `report`) and a meter with 3, 2 or 1 filled segments.

## 3. Typography
Fonts: **Fraunces** (variable, opsz 9–144) for display and headline roles; **Plus Jakarta Sans** for everything else. Bundle both via `google_fonts`, or as assets for offline use (recommended: bundle them, since the app is offline-first).

| M3 role | Font | Size / line | Weight | Used for |
|---|---|---|---|---|
| displaySmall | Fraunces | 36/44 | 600 | Splash wordmark |
| headlineLarge | Fraunces | 32/40 | 600 | Fabric name on result A / fabric detail |
| headlineMedium | Fraunces | 28/36 | 600 | Large screen titles (Browse, History) |
| headlineSmall | Fraunces | 24/32 | 600 | Home greeting, onboarding titles, result B card names |
| titleLarge | Jakarta | 20/28 | 700 | App-bar titles, sheet titles |
| titleMedium | Jakarta | 16/24 | 700 | Care section titles, tile labels |
| titleSmall | Jakarta | 14/20 | 700 | List item titles |
| bodyLarge | Jakarta | 16/24 | 400 | Care steps, descriptions |
| bodyMedium | Jakarta | 14/20 | 400 | Supporting text |
| bodySmall | Jakarta | 12/16 | 500 | Captions, dates |
| labelLarge | Jakarta | 14/20 | 600 | Buttons |
| labelMedium / Small | Jakarta | 12/16, 11/16 | 600 | Chips, nav labels, eyebrows |

Text scaling: layouts use flexible heights only, and none of them fixes a text container's height. Tested at 1.3× (see prototype "Text 1.3×" toggle).

## 4. Spacing, shape, elevation
- **Spacing:** 4-pt grid: 4, 8, 12, 16, 24, 32, 48. Screen gutter 16. Gap between bento tiles 10.
- **Shape:** xs 4 · sm 8 · md 12 · lg 16 · xl 22 (bento tiles, cards) · xxl 28 (bottom sheet top, dialogs) · full (chips, nav pill, buttons).
  - Scan FAB **morphs**: rounded square (radius 18) at rest → circle (28) when pressed.
- **Elevation:** M3 tonal elevation. Cards are flat on `surfaceContainer`; the nav bar is level 2 + glass; the FAB is level 3; dialogs are level 3.

## 5. Motion
| Token | Value | Use |
|---|---|---|
| short | 150 ms, standard | Press states, chip toggles, fades |
| medium | 300 ms, emphasized decelerate | Sheet open, page enter, meter fill |
| long | 450 ms, spring (damping 0.8) | Result card "springs in" |
| analyzing | ≤ 2.5 s loop | Woven-thread scan-line animation |
| Easing | standard `cubic-bezier(.2,0,0,1)` · emphasized decelerate `(.05,.7,.1,1)` · emphasized accelerate `(.3,0,.8,.15)` | Flutter: `Easing.standard`, `Easing.emphasizedDecelerate`, `Easing.emphasizedAccelerate` |

**Reduce motion** (`MediaQuery.of(context).disableAnimations`): moving animations become 150 ms fades. The analyzing screen shows a static woven icon with a determinate `LinearProgressIndicator`.

## 6. Icons
**Material Symbols Rounded**, weight 400, optical size 24. Fill 1 for the active nav item and fill 0 everywhere else. Flutter: `material_symbols_icons` package (`Symbols.photo_camera_rounded`). Every icon-only button has a `tooltip` / `Semantics(label:)`.

Key icons: `photo_camera` scan · `photo_library` upload · `grid_view` browse · `history` · `person` profile · `local_laundry_service` washing · `air` drying · `iron` ironing · `water_drop` stain removal · `inventory_2` storage · `verified` / `help` / `report` confidence · `label` fiber hint · `eco` sustainability · `menu_book` sources.

## 7. Component catalog
States: **D** default · **P** pressed · **X** disabled · **F** focus (2 dp primary outline, 2 dp offset) · **E** error.

| Component | Spec | States | Flutter widget |
|---|---|---|---|
| Primary button | Height 52, full radius, primary fill, labelLarge | D, P (state layer 10%), X (onSurface 12% fill / 38% text), F | `FilledButton` |
| Secondary button | Tonal: secondaryContainer fill | D P X F | `FilledButton.tonal` |
| Text / outlined button | — | D P X F | `TextButton`, `OutlinedButton` |
| **Scan button (FAB)** | 64×64 (in tile) / 72 (camera shutter). Radius morphs 18→28 on press, haptic `HapticFeedback.mediumImpact()` | D, P (morph), X, F | `FloatingActionButton.large` with `AnimatedContainer` shape, or a custom `InkWell` + `AnimatedContainer` |
| **Bento tile** | surfaceContainer, radius 22, padding 14, min height 72; icon + titleMedium + optional caption. The Scan tile spans 2 columns, filled primary | D, P (scale 0.98 + state layer), F | `Card.filled` + `InkWell` inside a `GridView`/`Wrap` (or `flutter_staggered_grid_view`) |
| **Fabric card** | Texture photo, 4:3 or square, radius 22, bottom scrim, name in Fraunces, fiber caption | D P F | `Card` + `Ink.image` + `DecoratedBox` gradient |
| **Confidence meter** | Word + icon + 3-segment bar. High: 3/3 confHigh · Possible: 2/3 confPossible · Not sure: 1/3 confNotSure. Optional "about 86%" secondary text in bodySmall | 3 states; animates fill 300 ms | Custom `Row` of 3 `AnimatedContainer`s inside `Semantics(label: "High match")` |
| **Care section card** | Leading icon in secondaryContainer circle, titleMedium, numbered steps (secondary circles), "Sources (n)" text button | Collapsed / expanded, F | `ExpansionTile` inside `Card.filled`, or `ExpansionPanelList` |
| **Stain chip** | Filter chip: Food & oil · Sweat · Make-up · Ink | D, selected (secondaryContainer + check), F, X | `ChoiceChip` in a `Wrap` |
| Fiber hint banner | secondaryContainer, `label` icon, text "Check the garment label to confirm fiber", plus fiber versions as chips | Always visible (not dismissible) | `Card.filled` / `MaterialBanner`-style `Container` |
| Disclaimer banner | surfaceContainerHigh, `info` icon, bodyMedium | Always visible | `Container` (not dismissible) |
| Bottom sheet | Radius 28 top, drag handle, titleLarge, max 90% height | Open/closed; scrim 32% | `showModalBottomSheet(showDragHandle: true, useSafeArea: true)` / `DraggableScrollableSheet` |
| **Floating nav bar** | Pill, 16 inset from the edges, height 64, glass fill + 1 px border, 4 destinations with labels always shown | Active (fill icon + pill indicator primaryContainer), D, F | `NavigationBar` wrapped in `ClipRRect` + `BackdropFilter`, placed in `Scaffold.bottomNavigationBar` with padding (`extendBody: true`) |
| Empty state | Illustration (woven circle), headlineSmall, body, primary button | — | `Column` in `Center` |
| Text field | Filled, radius 12 top, label, helper, error text with `error` icon | D, F (2 dp primary underline), E, X | `TextFormField` with `InputDecoration(filled: true)` |
| Dialog | Radius 28, title, body, 2 actions (destructive = error colour text) | — | `AlertDialog` / `showDialog` |
| Snackbar | inverseSurface | — | `SnackBar` |
| List item | 72 min height, leading thumbnail 48 radius 12 | D P F, swipe-to-delete | `ListTile` + `Dismissible` |
| Search | — | — | `SearchAnchor` + `SearchBar` |
| App bar | Large title collapsing | — | `SliverAppBar.large` / `.medium` |
| Segmented / theme picker | Light · Dark · System | — | `SegmentedButton` |
| Progress | Analyzing: custom woven loop; others: `LinearProgressIndicator` | — | `CustomPainter` + `AnimationController`; `LinearProgressIndicator` |

## 8. Glass, scrims and imagery
- **Glass** is used **only** on (a) camera overlays (tips chip, top bar, capture tray) and (b) the floating nav bar. Fill: light `rgba(255,252,245,.78)` / dark `rgba(31,26,21,.78)`, blur 16; camera `rgba(23,19,15,.62)` with white text (≥ 9.3:1 even over a white fabric).
  - Flutter: `BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16))`. On low-end devices (the Android budget reference), set `kUseBlur = false` and use the same fill at 92% opacity.
- **Photo scrim** on fabric cards: a gradient from transparent at 35% to `rgba(23,19,15,.82)` at the bottom, with white text.
- **Fabric imagery:** macro close-ups (texture fills the frame), square, at least 1080 px, natural light. Requested from the researchers (see `handoff-notes.md`). The prototype uses CSS stand-in textures.

## 9. Voice & copy rules
- Plain English, Grade 8, short. Say "match" and never "confidence score", "model" or "inference".
- Confidence words: **High match**, **Possible match**, **Not sure**. Never use "100%", "certain" or "guaranteed".
- Care steps start with a verb: "Wash by hand in cool water."
- Fixed strings: "Check the garment label to confirm fiber." · "This is general guidance. Always follow the garment's care label if it differs." · "FabriSCAN+ covers modern dress fabrics in Barong, Formal wear, Gowns and Filipiniana."
- Placeholder content is labelled **"Sample content: to be written by researchers"**.
- All strings live in ARB files (l10n) so Filipino can be added later.
