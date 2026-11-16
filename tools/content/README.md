# FabriSCAN+ content: how to fill in `FabriSCAN_Content.xlsx`

**For the researchers.** This one Excel file holds everything the app shows about fabrics: names, how to identify them, textile care, and sources. The app reads it directly (ADR-006), so the care guides in the app are exactly what you write here.

> **Please keep the sheet names and column names exactly as they are.** You can edit, add and delete rows freely.

---

## The sheets

### 1. Categories
The 4 categories after the client change of 2026-11-16: Barong, Formal wear, Gowns & Filipiniana, Beaded Fabrics.

| Column | What to write |
|---|---|
| `category_id` | **Don't change.** The app uses it. |
| `name` | The name shown in the app. |
| `order` | Order on the screen (1–4). |
| `description` | One sentence shown under the name in Browse. |

### 2. Fabrics (one row per fabric)
The proposed list is filled in. Delete the fabrics you won't include, and add rows for new ones.

| Column | What to write | Example |
|---|---|---|
| `fabric_id` | Stable ID: `FAB-` + name in capital letters, no spaces. Don't change it once photos are taken. | `FAB-PINA` |
| `name` | Name shown in the app. | Piña |
| `other_names` | Other local or trade names, comma-separated. | Piña cloth |
| `category_1`, `category_2` | Pick from the list. Use `category_2` only if the fabric is in two categories. The care guide is still written **once**. | `barong`, `gowns_filipiniana` |
| `fiber_1` … `fiber_3` | What it's made of ("san gawa"). If it comes in several fibers, list each one. | Silk / Polyester |
| `fiber_N_type` | `natural`, `synthetic` or `blend`. | natural |
| `description` | 1–3 sentences: look, feel, where it's used. | |
| `identify_1` … `identify_3` | Three short things a person can **see or feel** to check the fabric. | See-through when held up to light |
| `reviewed_by`, `reviewed_on` | Initials and date of the researcher who checked the row. | AB, 2026-12-01 |

### 3. Care (one row per fabric per section)
Five rows per fabric are ready: **Washing, Drying, Ironing, Stain removal, Storage**.

| Column | What to write |
|---|---|
| `steps` | **One step per line** (Alt+Enter makes a new line inside a cell). Short, plain sentences, about Grade 8 reading level. The app numbers them. |
| `iron_dots` | Ironing rows only: `0` do not iron, `1` low, `2` medium, `3` high (as on care labels). |
| `iron_setting` | Ironing rows only, e.g. "Low, up to 110 °C, with a press cloth". |
| `citation_ids` | Source IDs from the Citations sheet, e.g. `S01, S04`. **Every row needs at least one.** |

Rules:
- If a fabric comes in several fibers (silk or polyester satin), the steps must be **safe for the most delicate one**. The app also tells users to check the garment label.
- **Beaded fabrics:** the steps must protect the beads and sequins too (for example, no ironing directly on beads, how to store heavy pieces).
- The app always adds this line to every care guide, so you don't need to write it: *"This is general guidance. Always follow the garment's care label if it differs."*

### 4. Stains (one row per fabric per stain type)
Rows for **Food & oil, Sweat, Make-up, Ink** are ready. Leave a row empty if there's no advice for that stain. You may add other stain types. When `steps` is filled in, `citation_ids` is required.

### 5. Citations
| Column | What to write |
|---|---|
| `citation_id` | `S01`, `S02`, … |
| `apa_reference` | Full APA 7 reference, as in the thesis. |
| `url_or_doi` | Link or DOI if available. |

Users see the sources under each care section in the app ("Sources").

### 6. Images
List the photos you'll send with the file.
- **Main photo** for each fabric (required): fabric close-up that fills the frame, natural light, no flash glare, square, at least 1080 × 1080 px, JPEG. Name it `FAB-ID_main.jpg` (e.g. `FAB-PINA_main.jpg`).
- **Drape photo** (optional): `FAB-ID_drape.jpg`.
- **Category covers** (4): 16:9, at least 1280 px wide.
- **No people's faces** in any photo.

These are the photos shown in the app. They are **separate** from the training photos for the scanner (`tools/ml/PHOTO_GUIDE.md`).

---

## The example (yellow rows)
Piña is filled in as an example so you can see the format. Every example cell starts with **`[PLACEHOLDER] EXAMPLE:`**. Replace it with your own content and remove the marker. The text is sample wording only and not checked advice.

## Sending it
Send the file and the photos to the developer, for example over Messenger or a shared Google Drive folder. A checker reads the file and sends back a list of anything to fix, row by row.

## What the checker reports (and how to fix it)
| Message | Meaning | Fix |
|---|---|---|
| `Fabrics row 7 (FAB-SATIN): description is empty` | A required cell is blank. | Fill it in. |
| `Care row 14 (FAB-PINA, Ironing): no citation` | Every care section needs a source. | Add a source ID in `citation_ids`. |
| `Care row 20 (FAB-JUSI, Washing): citation S09 is not in the Citations sheet` | The ID was typed but never defined. | Add S09 to Citations, or fix the typo. |
| `Care row 31 (FAB-LACE, Ironing): iron_dots is missing` | Ironing rows need a heat level. | Pick 0–3. |
| `FAB-SEQUIN: has no Washing row` | One of the 5 sections is missing. | Add the row. |
| `FAB-TULLE: no category` | Every fabric needs at least one category. | Pick `category_1`. |
| `[PLACEHOLDER] text found in Fabrics row 2` | Example or unfinished text is still there. Test builds are refused. | Replace it with your content. |
| `FAB-ABACA is not in the scanner's fabric list` | The fabric list and the scanner don't match. | Tell the developer; the scanner's list must be updated too. |
| `Image FAB-PINA_main.jpg not found` / `too large` | The photo is missing, or over 400 KB after compression. | Send the photo; the developer can compress it. |

---

## For developers
- The template is generated by `make_template.py` (run with `D:\dev\venv-tools\Scripts\python -I tools/content/make_template.py`). The sheet and column names are the contract with `build_catalog.py` (ADR-006); change them only with an ADR update.
- `build_catalog.py` checks the file and converts it to `assets/content/catalog.json` (needs `openpyxl` only):
  - `python -I tools/content/build_catalog.py FILE.xlsx`: full check, report only (sample text allowed, reported)
  - `... FILE.xlsx --write`: check, then write `catalog.json` if there are no problems
  - `... FILE.xlsx --release`: strict check before a TAM build (no `[PLACEHOLDER]`, every fabric has a main photo in `tools/content/images/`, fabric IDs match `assets/model/labels.txt`)
  - `... --structure`: sheets, columns and IDs only (CI, runs on the blank template)
  - `--report out.md` saves the report so it can be sent back to the researchers.
- Contract test: `test/fixtures/catalog_from_xlsx.json` is a builder output that `test/features/catalog/catalog_contract_test.dart` parses with the app's own model. Regenerate it when the output format changes.
- Tests: `python -I -m unittest discover -s tools/content/tests`.
- `dev_sample/make_dev_catalog.mjs` builds the development sample catalog from the prototype's data. Never ship it: its `status` contains `[PLACEHOLDER]`.
