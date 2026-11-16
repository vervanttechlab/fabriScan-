# FabriSCAN+ Photo-Taking Guide (for the researchers)

**Version 0.1 · 2026-11-16** · Based on `docs/architecture/ml-plan.md` §2

The scanner learns to recognize fabrics only from the photos you take. **More variety means a better app.** The number of different physical pieces of cloth matters more than the number of photos.

> **The fabric list is not final yet** (open questions Q1, Q2). Start with the 5 "spike" fabrics in step 0. They are in every version of the list, and they show early whether look-alikes can be told apart.

---

## 0. Start here: the week-1 spike
Before the full collection, photograph only these 5 fabrics: **Piña, Piña-seda, Jusi, Organza and Satin**.
- At least **3 different pieces** of each, about **50 photos per piece**.
- Follow the same rules as the rest of this guide.
- Upload them to the shared Drive and tell the developer. One piece of each fabric is kept hidden from training, so the test is fair.

If the scanner can't tell Piña, Piña-seda and Jusi apart well, we will know **now** and can change the plan early. Options include close-up "macro" photos, more pieces, or showing a combined "Piña / Piña-seda" result.

---

## 1. What a "sample" is
A **sample** is **one physical piece of cloth**: one swatch, one garment, or one bolt from one shop.

- Two photos of the same piece = same sample.
- The same fabric bought from two different shops = two samples.
- A different colour or batch of the same fabric = a different sample.

**Why it matters:** we test the scanner on pieces it has **never seen**. That is the honest accuracy number for the thesis, and it can only be measured if every photo is labelled with the right sample.

## 2. How many

| | Minimum | Target |
|---|---|---|
| Different pieces (samples) per fabric | 3 | **5** |
| … for **Piña, Piña-seda, Jusi, Organza** (they look alike) | 3 | **6 or more** |
| Photos per piece | 50 | **60–80** |
| Photos per fabric (total) | 150 | **300+** |
| "Not fabric" photos (see §6) | 300 | **500** |

**Full collection at target size:** 23 fabrics → about **119 pieces** and **≈ 7,600 photos**. One piece takes about **20–25 minutes**, so the full set is roughly **45–50 hours**. Split across 8 researchers, that is about **6 hours each**.

**Choose pieces with variety on purpose:**
- different colours of the same fabric
- plain **and** embroidered or printed pieces (e.g. a barong's plain body and its embroidered panel)
- fabric **on a real garment** as well as flat swatches
- different shops, brands or weavers

## 3. The 60-photo recipe (one piece)
Do **20 photos in each of 3 lights**. Within each light, take 10 close and 10 far:

| Light (≈ ⅓ each) | Close: 10–15 cm (texture) | Far: 25–30 cm (drape, sheen) |
|---|---|---|
| **Daylight** near a window (not direct sun) | 10 | 10 |
| **Indoor** LED or fluorescent | 10 | 10 |
| **Dim or mixed** (evening room, lamp + window) | 10 | 10 |

Within each group of 10, mix the angles:
- about **4 straight on**
- about **3 tilted** about 30°
- about **3 folded, draped or bunched**

Move a little between shots, to a different spot on the cloth or a slightly different angle. **Don't take 10 identical photos.**

## 4. Capture checklist (print this)
- [ ] **Phones:** use at least **3 different phones** across the whole project: 2 or more Android phones (one of them a budget phone) and 1 iPhone if available. Shoot **each fabric with at least 2 phones**.
- [ ] **No flash.** Turn it off.
- [ ] Use the **default camera app**: no filters, no beauty mode, no "AI scene" mode. JPEG.
- [ ] Fabric fills **at least 80% of the photo**.
- [ ] **Sheer fabrics** (Organza, Piña, Tulle) need shots over **both a light and a dark background**, about half each.
- [ ] **Focus:** retake clearly blurry shots. A few slightly soft ones are fine, because real users take those too.
- [ ] **No people's faces** in any photo. Garments on a hanger or mannequin are best. If a person wears the garment, keep the face out of the frame.
- [ ] Before you put a piece away, **photograph its label or receipt** (claimed fiber content). Save this photo in the sample log, **not** in the dataset folder.

## 5. Folder and file names
Put every photo in the shared Google Drive like this:

```text
dataset/
  FAB-PINA/
    S01/
      FAB-PINA_S01_phoneA_day_close_001.jpg
      FAB-PINA_S01_phoneA_day_far_002.jpg
      ...
    S02/
  FAB-JUSI/
  ...
  not_fabric/
    S01/
      not_fabric_S01_phoneB_indoor_close_001.jpg
```

**File name parts** (separated by `_`):

| Part | Allowed values | Example |
|---|---|---|
| Fabric ID | from the table in §8, or `not_fabric` | `FAB-PINA` |
| Sample | `S01`, `S02`, … (per fabric) | `S03` |
| Phone | `phoneA`, `phoneB`, … (write down which phone is which in the sample log) | `phoneB` |
| Light | `day`, `indoor`, `dim` | `indoor` |
| Distance | `close`, `far` | `close` |
| *(sheer fabrics only)* Background | `onlight`, `ondark` | `ondark` |
| Number | `001`, `002`, … | `014` |

Examples:
- `FAB-SATIN_S02_phoneC_dim_far_031.jpg`
- `FAB-ORGANZA_S01_phoneA_day_close_ondark_007.jpg`

**Tip:** rename in batches. Take all the "day, close" shots of a piece, then select and rename them together. On Windows, select the files and press F2. On Android, use any bulk-rename app. Ask the developer for a renaming script if this is slow.

## 6. "Not fabric" photos
The app must say **"We couldn't identify this fabric"** instead of guessing when someone scans a floor or a hand. Take **500 photos** of everyday things: floors, walls, tables, paper, plastic bags, phone screens, food, plants, **hands and arms (never faces)**, shoes and leather bags.

Use the same naming rules. Each **place or session** is one sample (`S01` = living room, `S02` = canteen…). Use at least 5 samples.

## 7. Two logs to keep

### 7.1 `metadata.csv` (one row per photo)
The developer's script fills this in **automatically from the file names**, so you only need to fix rows with problems.

| Column | Meaning |
|---|---|
| `file` | path inside `dataset/`, e.g. `FAB-PINA/S01/FAB-PINA_S01_phoneA_day_close_001.jpg` |
| `fabric_id` | e.g. `FAB-PINA` |
| `sample_id` | e.g. `S01` |
| `phone` | e.g. `phoneA` |
| `light` | `day` / `indoor` / `dim` |
| `distance` | `close` / `far` |
| `background` | `onlight` / `ondark` / blank |
| `notes` | anything unusual (e.g. "embroidered panel", "on mannequin") |

### 7.2 `sample_log.csv` (one row per piece of cloth, for the methodology chapter)
Template: `tools/ml/templates/sample_log.csv`

| Column | Example |
|---|---|
| `fabric_id` | `FAB-PINA` |
| `sample_id` | `S01` |
| `source` | Shop, weaver or supplier, and town (e.g. "Kalibo weaver, Aklan") |
| `date_obtained` | `2026-11-20` |
| `claimed_fiber` | As written on the label or said by the seller (e.g. "100% piña") |
| `label_photo` | File name of the label/receipt photo (kept outside `dataset/`) |
| `form` | `swatch` / `garment` / `bolt` |
| `colour` | `natural ecru` |
| `embroidered_or_printed` | `yes` / `no` |
| `phones_used` | `phoneA; phoneC` |
| `photographer` | initials only |
| `notes` | |

Also keep a small table of the phones: `phoneA = Samsung A14 (budget)`, `phoneB = …`.

## 8. Fabric IDs (proposed list, to be confirmed; updated for the client change of 2026-11-16)
| Category | Fabrics |
|---|---|
| Barong | `FAB-PINA`, `FAB-PINASEDA`, `FAB-JUSI`, `FAB-ORGANZA`, `FAB-COCOON` |
| Formal wear | `FAB-WOOL`, `FAB-POLYVIS`, `FAB-COTTON`, `FAB-LINEN`, `FAB-CREPE` |
| Gowns & Filipiniana | `FAB-SATIN`, `FAB-CHIFFON`, `FAB-TULLE`, `FAB-LACE`, `FAB-TAFFETA`, `FAB-SINAMAY`, `FAB-INABEL`, `FAB-TNALAK` (+ Piña and Jusi, shared with Barong) |
| Beaded Fabrics *(new)* | `FAB-BEADLACE`, `FAB-SEQUIN`, `FAB-BEADTULLE`, `FAB-BEADCHIFFON`, `FAB-BEADORGANZA` |

**Beaded fabrics:** take extra close-ups where the base fabric shows between the beads, and also photograph plain lace, tulle, chiffon and organza, so the scanner learns the difference. Handle beaded pieces gently and never press beads flat against a hard surface.

Piña and Jusi are photographed **once**, not once per category.

## 9. Checking your work
The developer runs `tools/ml/check_dataset.py` on the Drive folder. It reports:
- photos per fabric, piece, phone, light and distance, against the targets above
- badly named files, missing or broken photos, and exact duplicates
- fabrics that need more pieces or a better balance of light and distance

Run it after every photo session and fix what it flags.

## 10. Privacy and storage
- The photo set stays in the **research group's shared Google Drive**. It is never uploaded to GitHub or anywhere public.
- **No faces.** Delete or crop any photo where a face appears.
- Keep the label/receipt photos and the sample log, because the methodology chapter needs them.

## 11. What to expect (please read)
Phone photos can show the **type of fabric** (weave, sheen, texture) but often **cannot show the fiber** (silk vs polyester satin). That is why the app shows a fiber hint and asks users to check the care label.

Realistic accuracy on pieces the scanner has never seen is about **65–85%**, and lower for Piña / Piña-seda / Jusi. On photos of pieces it was trained on, it may score 85–95%, but that number is not the honest one. The thesis will report the honest number. More different pieces is the best way to raise it.
