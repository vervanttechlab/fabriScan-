# FabriSCAN+ — Development Handoff (contract for dev skills)

**Version:** 0.1 · 2026-11-16 · Follow this document together with `architecture.md` and the ADRs. Any change to it needs a new or superseding ADR.

> **Gate:** UI work starts only after the clickable prototype and design system (`ui-ux-prototype` skill → `docs/design/`, `prototype/`) have been reviewed by the client. Screens must follow `docs/design/design-system.md` and the token mapping in `docs/design/handoff-notes.md`.

## 1. Stack (fixed)
- **Framework:** Flutter (stable) / Dart 3, Material 3. Pinned at M0: **Flutter 3.50.0 / Dart 3.14**. Since Flutter 3.50, Material widgets are imported from `package:material_ui/material_ui.dart`.
- **Libraries:**
  - `flutter_riverpod` (state)
  - `go_router` (navigation)
  - `drift` (local DB). `sqlite3_flutter_libs` is no longer needed: `sqlite3` 3.x bundles SQLite itself (found at M0)
  - `camera`, `image_picker`, `image` (photo capture, picking, processing)
  - `tflite_flutter` (on-device model)
  - `firebase_core`, `firebase_auth`, `cloud_firestore` (accounts and sync)
  - `uuid`, `url_launcher`, `path_provider`
- **Tools:**
  - Python 3.11: `tools/content/build_catalog.py` (pandas + openpyxl)
  - Colab notebook: `tools/ml/`
- **CI:** GitHub Actions (analyze, test, content check, Android APK)
- **iOS builds:** Codemagic → TestFlight

## 2. Repo structure
```text
fabriscan/
  lib/
    main.dart
    app/            router.dart, theme.dart, app.dart
    core/           db/ (drift), config/, errors/, utils/
    features/
      onboarding/   data/ domain/ presentation/
      scan/
      identify/     image_preprocessor.dart, fabric_classifier.dart, decision_policy.dart
      result/
      care/
      catalog/
      history/
      account/      auth_service.dart, sync_service.dart
      settings_help/
  assets/
    model/          fabric_classifier.tflite, labels.txt, model_meta.json
    content/        catalog.json, images/
  test/             mirrors lib/ (unit + widget)
  integration_test/
  tools/
    content/        build_catalog.py, README.md, template FabriSCAN_Content.xlsx
    ml/             train_fabric_classifier.ipynb, splits.csv, parity_check/, reports/
  firebase/         firestore.rules, firestore.rules.test (emulator)
  docs/             (product + architecture)
  .github/workflows/ci.yml
  codemagic.yaml
```
Every feature folder is split into **`data/`** (repositories, data sources), **`domain/`** (models, pure logic) and **`presentation/`** (widgets, Riverpod providers).

## 3. Coding conventions
- Lints: `very_good_analysis` (or `flutter_lints` + strict mode). `flutter analyze` must have zero warnings.
- Formatting: `dart format`, enforced in CI.
- Immutable models (`freezed` is optional; plain `final` classes + `copyWith` are fine).
- No business logic in widgets. `DecisionPolicy`, `ImagePreprocessor`, repositories and `SyncService` must be testable without Flutter widgets.
- Model inference runs in a **background isolate**, never on the UI thread.
- All user-facing strings go in one `l10n` file (ARB), ready for Filipino later (F12). English only for now.
- No `[PLACEHOLDER]` strings in Dart code. Placeholder content exists only in `catalog.json` in dev builds.
- Read thresholds and model settings from `model_meta.json`; **never hard-code them**.
- Commits use Conventional Commits (`feat:`, `fix:`, `docs:`…). PRs reference backlog story IDs.

## 4. Implementation plan (ordered milestones)
| # | Milestone | Stories | Exit criteria |
|---|---|---|---|
| **M0** | Project setup | — | Flutter app runs on Android + iOS simulator. CI is green (analyze, test). Firebase project created + emulator config. Minimum OS versions confirmed (NFR-1) |
| **M1** | Shell + content (offline) | US-01, US-30, US-20, US-50, US-51 | Onboarding, Home, Browse → fabric → 5-section care guide, from a **sample `catalog.json`** (3 fabrics, placeholder text). `build_catalog.py` + validator with tests |
| **M2** | Scan flow with stub classifier | US-10, US-11, US-12, US-13, US-14, US-15, US-40, US-41, US-42 | Camera/gallery → review → `FakeClassifier` (fixed scores) → states A/B/C → care. History saved locally, listed, deleted. `DecisionPolicy` fully unit-tested |
| **M3** | Real on-device model | US-16 | `tflite_flutter` + preprocessing + 5-crop averaging in an isolate, using the **spike model** (Teachable Machine). Parity check passes. Latency measured on the reference devices (NFR-3, NFR-7) |
| **M4** | Accounts & sync | US-02, US-03, US-04, US-05, **US-43 (delete account, pending Q16)** | Email auth, guest import, sync push/pull, logout prompt, delete account. Firestore rules tests pass in the emulator |
| **M5** | Real content + final model | US-60, US-61, US-21, US-52 | Researchers' spreadsheet → `catalog.json` passes `--release` validation. Final model + accuracy report. TAM link set. Stain types shown |
| **M6** | TAM release | US-62 | Signed split APK + TestFlight build. 30-min test pass on the 3 reference devices with no crashes. About shows app/model/content versions. Screenshots taken for the user's manual |
| Later | Could / Later | US-22, US-31, US-63 | — |

M0–M4 can proceed **now**. M5 depends on the client (Q1–Q4, Q12). M6 for iOS depends on Q17.

## 5. Definition of Done (each story)
- [ ] All the story's acceptance criteria (`backlog.md`) are met and demonstrated on an Android device
- [ ] Unit and widget tests added; `flutter test` is green; coverage of `domain/` stays ≥ 80%
- [ ] `flutter analyze` has zero issues; code is formatted
- [ ] Works offline where the story requires it (check in airplane mode)
- [ ] Text scales to 1.3× without clipping; tap targets ≥ 48 dp
- [ ] No new permission, network call or data field without an ADR or architecture update
- [ ] The PR references the story ID; docs are updated if behaviour changed

## 6. Testing strategy
| Level | What | Tools |
|---|---|---|
| Unit | `DecisionPolicy` (table-driven: A/B/C edges, margin, `not_fabric`); `ImagePreprocessor` (crop math, normalization); repositories; `SyncService` (pending/deleted/conflict); catalog parsing | `flutter_test`, `mocktail` |
| Widget | Result states A/B/C; care guide sections + disclaimer; empty history; permission-denied screen | `flutter_test` |
| Integration | Gallery image from test assets → result → care → history (fake + real model) | `integration_test` |
| Content | `build_catalog.py`: required fields, citations, no placeholders, labels↔catalog | `pytest` in CI |
| Security | Firestore rules: owner-only access | Firebase emulator + `@firebase/rules-unit-testing` |
| ML | Parity check (Dart vs Python scores ±0.02); evaluation report | `tools/ml/parity_check` |
| Manual | Per-release device pass on the reference devices (budget Android, mid-range Android, iPhone): UF1–UF5, airplane mode, low light | Checklist in `docs/qa/device-pass.md` (create at M2) |

## 7. Ready for development?
**Yes for M0–M4.** M5 and M6 are blocked on the client inputs listed above, and development is not.
