# ADR-008 — Build & release: GitHub Actions (Android) + Codemagic (iOS)

**Status:** Accepted; iOS depends on the budget (Q8) · **Traces to:** N6, US-62, Q8

## Context
TAM respondents must be able to install the app from a link or QR code. The team may not have a Mac. Budget is unknown. Exchange-rate assumption: **USD 1 ≈ PHP 58**.

## Decision
| Concern | Choice |
|---|---|
| Source control | GitHub (private repo), trunk-based development, with short-lived feature branches and pull requests |
| CI (every PR) | GitHub Actions: `flutter analyze`, `flutter test`, content validation (`build_catalog.py --check`) |
| Android test build | GitHub Actions builds a **release APK split by CPU type** (arm64-v8a + armeabi-v7a), signed with an upload key kept in GitHub Secrets → distributed through **Firebase App Distribution** (free) or a Google Drive link + QR code |
| iOS test build | **Codemagic** free tier (500 macOS min/month) → **TestFlight** (external testing; up to 10,000 testers, joined through a public link). Requires an **Apple Developer Program** membership |
| Environments | One Firebase project `fabriscan-prod`. Development and tests use the **Firebase Local Emulator Suite**. No separate staging project (right-sized for a thesis) |
| Versioning | SemVer `MAJOR.MINOR.PATCH+build`. `model_meta.json` and `catalog.json` carry their own versions, shown on the About screen |
| Store release | Later (Q8). Play Console needs the account-deletion feature and a privacy policy URL; the privacy policy could be a GitHub Pages page |

## Costs
| Item | USD | PHP (approx.) | Needed for |
|---|---|---|---|
| Apple Developer Program | 99 / year | ≈ 5,750 / year | **Any iPhone install** (TestFlight) |
| Google Play Console | 25 one-time | ≈ 1,450 | Play Store only (optional) |
| Firebase Spark | 0 | 0 | Auth + Firestore |
| Codemagic free tier | 0 | 0 | iOS builds |
| GitHub + Actions (private repo, 2,000 min/month) | 0 | 0 | CI + APK |
| Google Colab (free) | 0 | 0 | Model training |
| **MVP total** | **0 (Android only) / 99 (with iPhone)** | **0 / ≈ 5,750** | |

## Consequences
- **Without the Apple fee, iPhone respondents cannot install the app.** This conflicts with R7 for TAM testing → escalated to the PM (Q17).
- Signing keys must be backed up outside the repo. Losing the Android key blocks updates on the Play Store later.
