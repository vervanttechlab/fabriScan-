# FabriSCAN+

Scan a dress fabric with your phone, find out what it is and what it's made of, and get cited care steps (washing, drying, ironing, stain removal, storage). Free, Android and iPhone, works offline, no account needed.

A thesis project of the BS Textile and Fashion Technology researchers, DMMSU Mid-La Union Campus. Supports SDG 12 (Responsible Consumption & Production): garments that are cared for properly last longer.

> **Status:** in development. Milestone **M1** is done (onboarding, home, browse, fabric details, care guide, help, about). Scanning (M2) is next. All fabric and care text in the app is **sample content** until the researchers supply the final, cited content.

## Project map
| Folder | What's inside |
|---|---|
| `docs/product/` | PRD, backlog (user stories), fabric catalog spec, open questions |
| `docs/architecture/` | Architecture, ADRs, ML plan, **dev handoff** (stack, conventions, milestones) |
| `docs/design/` | Design system "Hibla", tokens, user flows, handoff notes, prototype walkthrough video |
| `prototype/` | Clickable HTML prototype of every screen |
| `lib/`, `test/` | Flutter app (Riverpod, go_router, drift) and its tests |
| `assets/` | Bundled fonts, fabric content (`catalog.json`), scanner model (later) |
| `tools/content/` | Researchers' content template (`FabriSCAN_Content.xlsx`) and guide |
| `tools/ml/` | Photo-taking guide for the training dataset, dataset checker |
| `firebase/` | Firestore security rules (accounts and sync, M4) |

## Run it
Requires Flutter 3.50 (stable) and the Android SDK.
```bash
flutter pub get
flutter test
flutter run            # on a connected phone or emulator
flutter build apk --release --split-per-abi
```

## Content
Fabric names, identification and care text come from the researchers through `tools/content/FabriSCAN_Content.xlsx` (see `tools/content/README.md`). Content is data: it is never written in code.
