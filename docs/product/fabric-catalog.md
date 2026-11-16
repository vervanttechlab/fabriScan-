# FabriSCAN+ — Fabric Catalog Specification

Status: **DRAFT. The PM proposed these fabrics; the client has not confirmed them** (see Q1–Q3, Q20–Q23). Last updated: 2026-11-16 (CR-01: Gowns + Filipiniana merged; Beaded Fabrics added).
Who owns what: **the researchers own the content** (names, fiber content, care text, citations). **The PM owns this structure.**

## 1. Structure of each fabric entry
Every fabric in the app has these fields. The architect will turn this into the data model.

| Field | Required | Notes |
|---|---|---|
| `fabric_id` | Yes | Stable ID, e.g. `FAB-PINA` |
| `name` | Yes | Common name shown to users, e.g. "Piña" |
| `aka` | No | Other local or trade names, e.g. "Piña cloth" |
| `categories` | Yes | One or more of: Barong, Formal wear, Gowns & Filipiniana, Beaded Fabrics |
| `fiber_content` | Yes | **Answers "san gawa?"** Main fiber(s) and type (natural / synthetic / blend). If the fabric is sold in more than one version (e.g. silk organza vs polyester organza), list each one |
| `description` | Yes | 1–3 sentences: how it looks, how it feels, where it is used |
| `identifying_features` | Yes | What a person can see or feel: sheen, transparency, weave, stiffness. Shown on the result screen so users can double-check the scan themselves |
| `reference_images` | Yes | At least 1 clean photo for Browse and the result screen |
| `care.washing` | Yes | **To be authored by researchers with citation** |
| `care.drying` | Yes | **To be authored by researchers with citation** |
| `care.ironing` | Yes | **To be authored by researchers with citation** (include the temperature setting) |
| `care.stain_removal` | Yes | **To be authored by researchers with citation** (common stains, e.g. food, sweat, make-up) |
| `care.storage` | Yes | **To be authored by researchers with citation** |
| `care_symbols` | Should | ISO 3758 symbols (Q13) |
| `citations` | Yes | At least one source per care section, APA 7 |
| `reviewed_by` / `reviewed_on` | Yes | Which researcher checked the entry, and when |

Rules:
- Care text is written **once per fabric**, even if the fabric is in several categories (default for Q3).
- If a fabric has several fiber versions, the care text must cover the most delicate one, or give separate advice per version.
- Every care section must end with this line: "Always follow the garment's care label if it differs."
- Placeholder text inside the app must start with `[PLACEHOLDER]` and must never ship in a build used for TAM testing.

## 2. Proposed fabric list (for the client to confirm)

### Barong (5)
| ID | Fabric | Typical fiber content (to verify) |
|---|---|---|
| FAB-PINA | Piña | Pineapple-leaf fiber (natural) |
| FAB-PINASEDA | Piña-seda | Pineapple-leaf fiber + silk (natural blend) |
| FAB-JUSI | Jusi | Traditionally silk or abacá. Modern versions are often polyester or a blend |
| FAB-ORGANZA | Organza | Silk or polyester; sheer plain weave |
| FAB-COCOON | Cocoon (gusot-mayaman) | Usually polyester or a polyester blend, wrinkled texture |
Other possible choices: Banana fiber (Musa textilis/banana silk), Linen, Ramie.

### Formal wear (5)
| ID | Fabric | Typical fiber content (to verify) |
|---|---|---|
| FAB-WOOL | Wool suiting | Wool or a wool blend |
| FAB-POLYVIS | Poly-viscose (tropical suiting) | Polyester + viscose rayon |
| FAB-COTTON | Cotton (poplin/broadcloth) | Cotton |
| FAB-LINEN | Linen | Flax |
| FAB-CREPE | Crepe | Polyester, silk, or wool |

### Gowns & Filipiniana (merged by CR-01; 10 proposed, client to confirm or trim, Q20)
| ID | Fabric | Typical fiber content (to verify) |
|---|---|---|
| FAB-SATIN | Satin | Polyester or silk (satin weave) |
| FAB-CHIFFON | Chiffon | Polyester or silk |
| FAB-TULLE | Tulle | Nylon or polyester net |
| FAB-LACE | Lace | Cotton, nylon, or polyester |
| FAB-TAFFETA | Taffeta | Polyester or silk |
| FAB-PINA | Piña | *(shared with Barong)* |
| FAB-JUSI | Jusi | *(shared with Barong)* |
| FAB-SINAMAY | Sinamay | Abacá (natural) |
| FAB-INABEL | Inabel | Cotton, handwoven (Ilocos/La Union heritage; strong local fit) |
| FAB-TNALAK | T'nalak | Abacá, handwoven (T'boli) |
Other possible choices: Mikado, Velvet, Organza (overlaps with Barong).

### Beaded Fabrics (new, CR-01; 5 proposed as a starting point, Q21)
Beads and sequins are sewn **on top of** a base fabric, so each entry names its base fabric too.
| ID | Fabric | Typical fiber content (to verify) |
|---|---|---|
| FAB-BEADLACE | Beaded lace | Lace (nylon, polyester or cotton) with glass or plastic beads |
| FAB-SEQUIN | Sequin fabric | Polyester or nylon mesh with plastic sequins |
| FAB-BEADTULLE | Beaded tulle | Nylon or polyester net with beads |
| FAB-BEADCHIFFON | Beaded chiffon | Polyester or silk chiffon with beads |
| FAB-BEADORGANZA | Beaded organza | Polyester or silk organza with beads |
Other possible choices: Beaded satin, Beaded mesh, Pearl-embellished fabric.

**Totals if accepted:** 4 categories. Barong 5 + Formal wear 5 + Gowns & Filipiniana 10 + Beaded Fabrics 5 = 25 category slots, but only **23 unique fabrics** (Piña and Jusi are shared between Barong and Gowns & Filipiniana). The scanner has to learn 23 fabrics, up from 18.

## 3. Known identification difficulties (for the client and architect)
- Some fabrics are the **same weave in different fibers**: silk vs polyester organza, satin or chiffon. A phone photo can identify the *fabric type* but often cannot tell which *fiber* it is made of. When this happens, the app shows every fiber version from `fiber_content`, plus a hint such as "Check the label to confirm silk vs polyester." The thesis should mention this limitation.
- **Piña, Piña-seda and Jusi** look alike. This trio needs extra training photos and will be checked separately when measuring accuracy.
- **Beaded fabrics (CR-01):** beads and sequins cover the base fabric, so a photo may show mostly beads. Beaded lace vs plain lace and beaded tulle vs plain tulle are new look-alike pairs. Each beaded fabric needs its own physical samples, including close-ups where the base fabric shows between the beads. How the app names a beaded fabric is open (Q22).
