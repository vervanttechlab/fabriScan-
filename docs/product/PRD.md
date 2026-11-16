# FabriSCAN+ — Product Requirements Document

**Version:** 0.2 · **Date:** 2026-11-16 · **Status:** DRAFT (proposed defaults are in use; see `open-questions.md`)
**Change log:** v0.2: client CR-01. Categories are now Barong, Formal wear, Gowns & Filipiniana (merged) and Beaded Fabrics (new).
**Sources:** `docs/00-client-brief.md` (R = client note, I = implied by the thesis), `client_details/`

---

## 1. Problem & goals
Many people can't tell what fabric a garment is made of, so they wash, dry, iron and store it wrongly. The garment gets damaged and thrown away sooner, which adds to textile waste. The closest competitor app is iOS-only, puts its main features behind a payment, and stops at naming the fabric without saying how to care for it.

**Product goal:** a free app for Android and iPhone that identifies a modern dress fabric from a photo and gives cited care guidance for it. This supports SDG 12 (Responsible Consumption & Production).

**Thesis objectives this PRD must enable:**
- Obj 1: design and build FabriSCAN+ → this PRD plus the backlog.
- Obj 2: evaluate the app with TAM (Perceived Usefulness, Perceived Ease of Use) → §9, F9, and the TAM-ready release in §11.
- Obj 3: user's manual → every flow in §5 is a numbered list of steps that can be documented directly.

## 2. Non-goals / out of scope
- Fabrics outside the 4 categories (Barong, Formal wear, Gowns & Filipiniana, Beaded Fabrics), or outside modern dress (e.g. upholstery, industrial textiles).
- Identifying a garment's style, brand, size, or damage.
- Shopping, marketplace, or price lookup.
- Paid features, ads, or in-app purchases (**never**: this is the competitor's weakness, I3).
- Social features (sharing feeds, comments).
- Lab-grade fiber analysis. The app gives a **likely** identification; it is not a certified test.

## 3. Users & personas
| Persona | Description | What they need |
|---|---|---|
| **P1 Guest consumer** | Opens the app to check one garment, e.g. a barong for a wedding. Does not want to sign up | Scan with no account, a clear answer, care steps that are easy to read |
| **P2 Registered consumer** | Cares for formal or heritage garments regularly, e.g. Filipiniana for events | Saved history across devices, quick access to past garments |
| **P3 TAM respondent / thesis panel** | Installs a test build, completes set tasks, fills in the TAM survey | Easy install, first use that needs no explanation, a survey link inside the app |
| **P4 Researcher (content owner)** | One of the 8 researchers who maintain the fabric and care content | Content can be updated in one structured place (architect to decide how) |

## 4. Feature list
| ID | Feature | Description | Priority | Source |
|---|---|---|---|---|
| F1 | Scan with camera | Take a photo of a fabric in the app, with guide overlay and photo tips | Must | R2 |
| F2 | Upload photo | Choose an existing photo from the gallery | Must | R2 |
| F3 | Identification result | Fabric name, fiber content ("san gawa"), confidence level, identifying features, other likely matches, category tag(s) | Must | R2 |
| F4 | Care guide | 5 sections: Washing, Drying, Ironing, Stain removal, Storage, each with citations | Must | R3, I4 |
| F5 | Browse by category | Barong / Formal wear / Gowns & Filipiniana / Beaded Fabrics → fabric list → fabric detail and care guide, without scanning | Must | R6 |
| F6 | History | List of past scans (thumbnail, result, date); open one again; delete one or all | Must | R4 |
| F7 | Optional account | Guest mode by default; optional sign-up/login; history syncs when logged in; guest history can be imported on sign-up | Must (guest + login), Should (sync/import) | R5 |
| F8 | Help & About | Photo tips, how-to screens (match the user's manual), about the study, care-label disclaimer, data/privacy note | Must | I2 |
| F9 | TAM survey link | Button that opens the external TAM survey (Q11 default) | Should | I1 |
| F10 | Search | Search fabrics by name or alias in Browse | Could | Inferred |
| F11 | Care-label symbols | ISO 3758 symbols alongside each care section | Could | Inferred (Q13) |
| F12 | Filipino language | Translated UI and content | Won't (MVP) / Later | Q7 |

## 5. Key user flows
**UF1 – First launch**
1. User opens the app → splash screen.
2. 3-screen onboarding: Scan → Get care guide → History (can be skipped).
3. Choice screen: **Continue as Guest** (shown as the main button) or **Log in / Sign up**.
4. User lands on the Home screen, which shows a large Scan button, Upload, Browse categories, and Recent scans.

**UF2 – Scan → result → care**
1. On Home, tap **Scan** (or **Upload**).
2. If asked, allow camera or photo permission.
3. Line up the fabric inside the on-screen frame (photo tips are shown) → capture. Or choose a photo from the gallery.
4. Review the photo → **Use photo** or **Retake**.
5. The app shows a working indicator while it identifies.
6. The result screen appears, following the rules in §6.
7. Tap **View care guide** → 5 tabs or sections: Washing, Drying, Ironing, Stain removal, Storage.
8. The scan is saved to History automatically.

**UF3 – Browse**
1. Home → **Browse** → pick a category.
2. Pick a fabric → the fabric detail screen opens (description, fiber content, identifying features, care guide).

**UF4 – History**
1. Home → **History** → list, newest first.
2. Tap an item → its saved result and care guide open. Swipe or menu → delete. Settings → clear all history.

**UF5 – Guest → sign up**
1. Settings (or a prompt in History) → **Create account**.
2. User completes sign-up.
3. The app asks: "Import your N saved scans to your account?" → Yes / No.

## 6. Identification behaviour rules
The result has three states. Confidence is shown **in words** ("High", "Possible", "Not sure"), not as a raw percentage. The percentage can be shown as secondary detail.

| State | Default trigger (architect calibrates after testing the model) | What the user sees |
|---|---|---|
| **A. Confident** | top-1 ≥ 0.80 | One fabric card: name, fiber content, "High match", identifying features ("Check: sheer, crisp, slight sheen"), **View care guide**. Below it: "Not right? See other possible matches" (collapsed) |
| **B. Unsure** | 0.50 ≤ top-1 < 0.80, or top-2 within 0.15 of top-1 | "This could be…" followed by the **top 3** cards with identifying features, so the user can compare and choose. The fabric they choose is saved to History |
| **C. Can't identify** | top-1 < 0.50, or the photo is detected as not fabric or out of scope | "We couldn't identify this fabric." Shows: retake tips, **Retake**, **Browse fabrics**, and "FabriSCAN+ covers modern dress fabrics in Barong, Formal wear, Gowns & Filipiniana, and Beaded Fabrics." |

Extra rules:
- **Fiber ambiguity** (e.g. silk vs polyester satin): the result lists every fiber version and shows a hint: "Check the garment label to confirm fiber."
- **Care-label disclaimer** on every care guide: "This is general guidance. Always follow the garment's care label if it differs."
- **Photo tips** (shown on the camera screen and in state C): use good natural light, avoid flash glare, fill the frame with flat fabric, hold the phone 10–15 cm away, keep the photo in focus, use a single layer of fabric.
- Results must never say "100%" or "certain".

## 7. Content requirements
- The catalog follows `fabric-catalog.md`: 4 categories (Barong, Formal wear, Gowns & Filipiniana, Beaded Fabrics), about 23 unique fabrics (to be confirmed, Q1–Q3, Q20–Q23).
- **Beaded fabrics:** the care guide must cover the beads and sequins as well as the base fabric (e.g. no ironing directly on beads, how to store heavy beaded pieces). The researchers write this content (Q22).
- Each fabric needs all 5 care sections, each with at least one citation (APA 7). Each entry records which researcher reviewed it.
- MVP language: English (Q7). Write in plain language at about a Grade 8 reading level, with short numbered steps.
- No `[PLACEHOLDER]` content may appear in the build used for TAM testing.

## 8. Non-functional expectations (product terms; the architect sets the technical numbers)
| ID | Expectation |
|---|---|
| N1 | Runs on Android and iPhone (R7), including budget Android phones common in the Philippines (about 3 GB RAM). The architect sets the minimum OS versions |
| N2 | Time from tapping "Use photo" to seeing the result: **≤ 5 s** on a mid-range phone |
| N3 | Browse, care guides and History work **with no internet**. Scanning offline is preferred (Q6) |
| N4 | Guests' photos never leave the phone. Logged-in users' photos are uploaded only for history sync, and the user is told this (Q14) |
| N5 | A first-time user completes UF2 **without help** (tested during TAM) |
| N6 | Installable by TAM respondents through a link or a QR code (Q8) |
| N7 | Basic accessibility: text resizes with system settings, buttons are at least 44 pt tap targets, and colour is never the only way information is shown |

## 9. Success metrics
| Metric | Target (proposed) | How it's measured |
|---|---|---|
| TAM Perceived Usefulness | Weighted mean ≥ 3.41 ("Agree") on a 5-point Likert scale | TAM survey |
| TAM Perceived Ease of Use | Weighted mean ≥ 3.41 ("Agree") | TAM survey |
| Identification accuracy | top-1 ≥ 80%, top-3 ≥ 90% on a held-back test set of photos the scanner never trained on; each category ≥ 70% | Test-set results + confusion matrix (for the thesis) |
| Task completion | ≥ 90% of respondents complete UF2 unaided | Observation during TAM testing |
| Content completeness | 100% of fabrics have all 5 care sections + citations | Content checklist |

## 10. Assumptions, risks, open questions
**Assumptions:** the researchers can supply physical fabric samples and photos, and can write the care content. The proposed fabric lists are close to final.

| Risk | Impact | Mitigation |
|---|---|---|
| Identification is too inaccurate (look-alikes such as Piña / Piña-seda / Jusi; silk vs polyester) | Users are misled; the thesis is questioned at the defense | §6 rules for unsure results; extra photos for look-alike fabrics; the limitation is stated in the thesis; Browse as a fallback |
| Training photos arrive late or are too few | Accuracy target missed; schedule slips | Agree the photo-taking guide and minimum photos per fabric early (Q4) |
| Care content arrives late or has no citations | MVP cannot go to TAM testing | Content checklist; placeholder text blocks a TAM release |
| Fabric list keeps changing (it already changed once: CR-01) | Scanner must be retrained; content redone | Freeze the list (Q1–Q3, Q20–Q21) before full photo collection starts |
| Beaded fabrics hide their base fabric under beads and sequins | The scanner may confuse beaded lace with plain lace, or name only "beaded" without the base fabric | Decide how beaded fabrics are named and identified (Q22); photograph beaded and plain versions (Q23); state the limitation in the thesis |
| iOS distribution cost or access | iPhone respondents can't install the app | Budget decision (Q8); Android APK as the backup |

Open questions: see `open-questions.md` (Q1–Q23).

## 11. Release plan
**MVP (TAM-ready):** F1–F8 plus F9, covering UF1–UF5. Fixed fabric list, final care content, Android APK + iOS TestFlight.
**Later:** F10 Search, F11 care symbols, F12 Filipino, store release, more fabrics or categories, content updates without releasing a new app version (if the architect doesn't already cover this).

---

## Ready for Architecture checklist
| Item | Status |
|---|---|
| Every Must feature has an ID, a source and acceptance criteria (backlog) | ✅ |
| Identification uncertainty UX defined | ✅ (default thresholds; architect calibrates them) |
| Personas and main flows defined | ✅ |
| Non-functional expectations stated with numbers | ✅ |
| Fabric list confirmed by client (Q1–Q3) | ⚠️ Proposed only. Affects how many fabrics the scanner learns, not the architecture itself |
| Owner of training photos agreed (Q4) | ⚠️ Open. Affects the scanner training plan |
| Offline requirement for scanning (Q6) | ⚠️ Open; the default is stated |
| Distribution and budget (Q8) | ⚠️ Open; the default is stated |

**Verdict:** **Conditionally ready.** The architect can start on the framework, data model, content model, accounts and history now. The scanner training plan (`ml-plan.md`) should stay in draft until Q1–Q4 are answered.
