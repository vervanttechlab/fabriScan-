# FabriSCAN+ — Client Brief (source of truth)

Source: `client_details/thought_from_client.txt` + thesis excerpt images (title page, Chapter I, Statement of Objectives).
Last reviewed: 2026-11-16 (CR-01 added)

## Who / what
- **Title:** FabriSCAN+: Development of Textile Care Through Smart Mobile Application for Fabric Identification and Garment Maintenance
- **Client:** 8 researchers, BS Textile and Fashion Technology, DMMSU Mid-La Union Campus, College of Technology, San Fernando, La Union. Dated October 2026.
- **Nature:** Academic thesis deliverable. Educational / support tool. Advocacy: SDG 12 (Responsible Consumption & Production) — extend garment life, reduce textile waste.
- **Competitor / gap:** "Fabric Identifier – FabriScan" — iOS only, core features behind in-app purchase, stops at material profile with **no care guidance**. FabriSCAN+ must beat all three.

## Stated requirements (client notes, verbatim intent)
| # | Requirement | Note |
|---|---|---|
| R1 | Scope limited to fabrics of **modern / contemporary dress** | |
| R2 | **Camera capture and photo upload** → identify fabric and what it is made of ("san gawa ung tela") | AI image recognition |
| R3 | **Care guidance** per fabric: Washing, Drying, Ironing, Stain removal, Storage | "Scientifically based" |
| R4 | **History saved** | |
| R5 | **Login optional** — guest user supported | |
| R6 | **Fabric categories:** Barong (5 fabrics), Formal wear (5), **Gowns & Filipiniana** (merged), **Beaded Fabrics** (new) | Changed 2026-11-16 by CR-01 (below). Was: Barong, Formal wear, Gowns (count ?), Filipiniana (5) |
| R7 | Runs on **Android and iPhone** | |

## Implied by thesis objectives
| # | Requirement | Source |
|---|---|---|
| I1 | App must be evaluated with **TAM**: Perceived Usefulness, Perceived Ease of Use → installable for respondents, very usable | Objective 2 |
| I2 | **User's manual** deliverable | Objective 3 |
| I3 | Free, no paywall | Gap vs competitor |
| I4 | Accurate, cited care information | "scientifically based" |

## Open questions (must be resolved by PM before architecture is final)
1. Gown category — how many fabrics, which ones?
2. Exact fabric list per category; are overlaps (e.g., organza in Barong and Gown) one fabric or two entries?
3. Who builds the image dataset (photos of physical samples)? How many per fabric?
4. Low-confidence behavior: top-3 suggestions? "Unknown"? Manual browse fallback?
5. Offline required?
6. Language: English, Filipino, both?
7. Store release (Play Store / App Store) or test distribution (APK / TestFlight)? Budget for dev accounts/hosting?
8. Defense / deadline date?
9. Does history sync across devices for logged-in users? What happens to guest history on sign-up?
10. Is TAM survey in-app or external (Google Forms)?

## Change requests from the client
| ID | Date | Channel | What the client said | Meaning (PM reading) | Status |
|---|---|---|---|---|---|
| CR-01 | 2026-11-16 | Messenger | "sa may Gowns and Filipiniana na Category is gagawin na lang namin siyang isahan, ta magdadagdag kami ng isang category which is yung Beaded Fabrics po." | Merge **Gowns** and **Filipiniana** into one category, and add a new category, **Beaded Fabrics**. Still 4 categories in total. | Accepted in PRD v0.2. Details to confirm: Q20–Q23 |
