# FabriSCAN+ — User Flow Map

Version 0.1 · 2026-11-16 · Source: PRD v0.1 §5 (UF1–UF5), backlog v0.1. Screen IDs (S01–S26) are used in the prototype (`prototype/index.html#S11`) and in `handoff-notes.md`.

## Screen inventory
| ID | Screen / state | Trace |
|---|---|---|
| S01 | Splash | UF1 |
| S02–S04 | Onboarding 1–3 (Scan · Care guide · History), Skip | US-01 |
| S05 | Access choice: Continue as Guest / Log in / Sign up | US-02 |
| S06 | Home (bento) | UF1 |
| S07 | Camera permission primer + denied state | US-10 |
| S08 | Camera / scan | US-10 |
| S09 | Review photo (from camera or gallery) + "Couldn't open" error | US-10, US-11 |
| S10 | Analyzing | US-16 |
| S11 | Result A: confident (+ "Not right?" sheet) | US-12 |
| S12 | Result B: unsure, top-3 compare | US-13 |
| S13 | Result C: can't identify | US-14 |
| S14 | Fiber ambiguity hint (component inside S11/S12) | US-15 |
| S15 | Care guide (5 sections, stain types, Sources sheet, disclaimer) | US-20, US-21, US-22 |
| S16 | Browse: 4 categories | US-30 |
| S17 | Category → fabric list | US-30 |
| S18 | Fabric detail | US-30 |
| S19 | History list + empty state | US-41 |
| S20 | History item + delete confirm | US-41, US-42 |
| S21 | Log in / Sign up / Forgot password (+ error) | US-03 |
| S22 | Import guest scans (sheet) | US-04 |
| S23 | Profile / Settings | US-42, US-43 |
| S24 | Help & photo tips | US-50 |
| S25 | About & privacy + Take the survey | US-51, US-52 |
| S26 | Search (Could) | US-31 |

## Flow map
```mermaid
flowchart TD
  S01[S01 Splash] -->|first launch| S02[S02 Onboarding 1 Scan]
  S01 -->|returning| S06
  S02 --> S03[S03 Onboarding 2 Care] --> S04[S04 Onboarding 3 History] --> S05
  S02 & S03 -->|Skip| S05[S05 Access choice]
  S05 -->|Continue as Guest - primary| S06[S06 Home bento]
  S05 -->|Log in / Sign up| S21[S21 Auth]
  S21 -->|success| S06
  S21 -->|sign-up with guest scans| S22[S22 Import N scans? sheet] --> S06

  S06 -->|Scan| P{Camera permission?}
  P -->|not asked| S07[S07 Permission primer]
  S07 -->|Allow| S08
  S07 -->|Denied| S07d[S07 Denied state<br/>Open Settings / Upload instead]
  P -->|granted| S08[S08 Camera]
  S06 -->|Upload| GAL[[System photo picker]]
  S07d -->|Upload instead| GAL
  S08 -->|gallery thumb| GAL
  S08 -->|shutter| S09[S09 Review photo]
  GAL --> S09
  S09 -->|Retake| S08
  S09 -->|Use photo| S10[S10 Analyzing ≤2.5 s]
  S10 --> D{DecisionPolicy}
  D -->|A| S11[S11 Result A High match<br/>+ S14 fiber hint]
  D -->|B| S12[S12 Result B Top 3<br/>+ S14 fiber hint]
  D -->|C| S13[S13 Result C Can't identify]
  S11 -->|View care guide| S15[S15 Care guide]
  S11 -->|Not right?| SH1[[Other matches sheet]] --> S15
  S12 -->|pick a card| S15
  S13 -->|Retake| S08
  S13 -->|Browse fabrics| S16

  S06 -->|category tile / Browse tab| S16[S16 Browse]
  S16 --> S17[S17 Fabric list] --> S18[S18 Fabric detail] -->|Care guide| S15
  S16 -->|search| S26[S26 Search] --> S18

  S06 -->|History tab / recent strip| S19[S19 History]
  S19 -->|empty: Scan| S08
  S19 --> S20[S20 History item] -->|Care guide| S15
  S20 -->|Delete| DLG[[Confirm dialog]] --> S19

  S06 -->|Profile tab| S23[S23 Profile & Settings]
  S23 -->|Create account / Log in| S21
  S23 --> S24[S24 Help & tips]
  S23 --> S25[S25 About & privacy] -->|Take the survey| EXT[[External Google Form]]
```

## Tap count check (UF2, after capture)
Capture → **1** Use photo → (Analyzing, automatic) → Result A → **2** View care guide → care guide visible. **2 taps.**
For state B: **1** Use photo → **2** tap the matching card → care guide. **2 taps.**

## Saving rules shown in the flow
- A: saved to History automatically when the result appears.
- B: saved when the user picks a card.
- C: nothing saved (US-14), unless the user then opens a fabric from Browse (that is browsing, not a scan).
