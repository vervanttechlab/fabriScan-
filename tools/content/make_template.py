#!/usr/bin/env python3
"""Builds tools/content/FabriSCAN_Content.xlsx, the researchers' content template (ADR-006).

The sheet and column names are the contract with build_catalog.py. Change them only
together with an update to ADR-006 and tools/content/README.md.

Run: D:\\dev\\venv-tools\\Scripts\\python -I tools/content/make_template.py
"""
from __future__ import annotations

from pathlib import Path

from openpyxl import Workbook
from openpyxl.comments import Comment
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.worksheet.datavalidation import DataValidation

OUT = Path(__file__).resolve().parent / "FabriSCAN_Content.xlsx"
MAX_ROWS = 400  # rows covered by drop-downs

INDIGO = "2E3F8F"
CREAM = "FAF6EE"
EXAMPLE_FILL = PatternFill("solid", fgColor="FBE7C2")
HEADER_FILL = PatternFill("solid", fgColor=INDIGO)
NOTE_FILL = PatternFill("solid", fgColor="DDE1F7")
HEADER_FONT = Font(bold=True, color="FFFFFF")
THIN = Side(style="thin", color="D8CCB9")
WRAP = Alignment(wrap_text=True, vertical="top")

# CR-01 (2026-11-16): Gowns + Filipiniana merged, Beaded Fabrics added. Names still to confirm (Q20).
CATEGORIES = [
    ("barong", "Barong", 1),
    ("formal", "Formal wear", 2),
    ("gowns_filipiniana", "Gowns & Filipiniana", 3),
    ("beaded", "Beaded Fabrics", 4),
]
# Proposed list from docs/product/fabric-catalog.md (the researchers edit, add or delete rows).
FABRICS = [
    ("FAB-PINA", "Piña", "barong", "gowns_filipiniana"),
    ("FAB-PINASEDA", "Piña-seda", "barong", ""),
    ("FAB-JUSI", "Jusi", "barong", "gowns_filipiniana"),
    ("FAB-ORGANZA", "Organza", "barong", ""),
    ("FAB-COCOON", "Cocoon (gusot-mayaman)", "barong", ""),
    ("FAB-WOOL", "Wool suiting", "formal", ""),
    ("FAB-POLYVIS", "Poly-viscose", "formal", ""),
    ("FAB-COTTON", "Cotton", "formal", ""),
    ("FAB-LINEN", "Linen", "formal", ""),
    ("FAB-CREPE", "Crepe", "formal", ""),
    ("FAB-SATIN", "Satin", "gowns_filipiniana", ""),
    ("FAB-CHIFFON", "Chiffon", "gowns_filipiniana", ""),
    ("FAB-TULLE", "Tulle", "gowns_filipiniana", ""),
    ("FAB-LACE", "Lace", "gowns_filipiniana", ""),
    ("FAB-TAFFETA", "Taffeta", "gowns_filipiniana", ""),
    ("FAB-SINAMAY", "Sinamay", "gowns_filipiniana", ""),
    ("FAB-INABEL", "Inabel", "gowns_filipiniana", ""),
    ("FAB-TNALAK", "T'nalak", "gowns_filipiniana", ""),
    ("FAB-BEADLACE", "Beaded lace", "beaded", ""),
    ("FAB-SEQUIN", "Sequin fabric", "beaded", ""),
    ("FAB-BEADTULLE", "Beaded tulle", "beaded", ""),
    ("FAB-BEADCHIFFON", "Beaded chiffon", "beaded", ""),
    ("FAB-BEADORGANZA", "Beaded organza", "beaded", ""),
]
SECTIONS = ["Washing", "Drying", "Ironing", "Stain removal", "Storage"]
STAINS = ["Food & oil", "Sweat", "Make-up", "Ink"]
FIBER_TYPES = ["natural", "synthetic", "blend"]
IMAGE_KINDS = ["main photo", "drape photo", "category cover"]

# One complete example (Piña). Every example cell starts with [PLACEHOLDER] so the
# release check refuses it until the researchers replace it with their own content.
EX = "[PLACEHOLDER] EXAMPLE: "
EXAMPLE_FABRIC = {
    "other_names": EX + "Piña cloth",
    "fiber_1": EX + "Pineapple-leaf fiber",
    "fiber_1_type": "natural",
    "description": EX + "A fine, sheer cloth handwoven from pineapple-leaf fibers. It is light, slightly stiff, and has a soft natural sheen.",
    "identify_1": EX + "See-through when held up to light",
    "identify_2": EX + "Crisp, slightly stiff feel",
    "identify_3": EX + "Fine, slightly uneven threads",
}
EXAMPLE_CARE = {
    "Washing": (EX + "Hand wash only, in cool water (below 30 °C).\nAdd a few drops of mild, pH-neutral soap.\nSwish gently for 2–3 minutes. Do not rub, twist or wring.\nRinse twice in clean, cool water.", "", "", "S01"),
    "Drying": (EX + "Roll the garment in a clean towel and press to remove water.\nHang on a padded hanger or lay flat, in the shade.\nKeep out of direct sun.", "", "", "S01"),
    "Ironing": (EX + "Iron while the fabric is still slightly damp.\nIron on the reverse side, with a thin cotton press cloth on top.\nPress and lift. Do not slide the iron over embroidery.", 1, EX + "Low, up to 110 °C, with a press cloth", "S01, S02"),
    "Stain removal": (EX + "Act quickly and blot; never rub.\nTest any method on a hidden seam first.", "", "", "S02"),
    "Storage": (EX + "Store only when clean and fully dry.\nWrap in acid-free tissue or a clean cotton cloth.\nKeep away from damp. Add silica gel packs.", "", "", "S01"),
}
EXAMPLE_STAINS = {
    "Food & oil": EX + "Blot with a clean, dry cloth.\nSprinkle cornstarch on oil. Wait 15 minutes, then brush it off.\nDab with cool water and one drop of mild soap.",
    "Sweat": EX + "Mix 1 tablespoon of white vinegar in 1 litre of cool water.\nSoak the area for 15 minutes.\nRinse well in cool water.",
}
EXAMPLE_CITATIONS = [
    ("S01", EX + "Author, A. A. (Year). Title of the book or article. Publisher or Journal Name, volume(issue), pages. https://doi.org/...", "", EX + "Replace with a real APA 7 reference"),
    ("S02", EX + "Organization Name. (Year). Title of the web page. Site Name. https://...", "", ""),
]


def header(ws, cols, widths, notes=None):
    ws.append(cols)
    for i, c in enumerate(ws[1], start=1):
        c.fill = HEADER_FILL
        c.font = HEADER_FONT
        c.alignment = Alignment(wrap_text=True, vertical="center")
        ws.column_dimensions[c.column_letter].width = widths[i - 1]
        if notes and cols[i - 1] in notes:
            c.comment = Comment(notes[cols[i - 1]], "FabriSCAN+")
    ws.row_dimensions[1].height = 34
    ws.freeze_panes = "B2"


def style_rows(ws, first, last, fill=None):
    for row in ws.iter_rows(min_row=first, max_row=last):
        for c in row:
            c.alignment = WRAP
            c.border = Border(bottom=THIN)
            if fill:
                c.fill = fill


def dropdown(ws, formula, col, prompt):
    dv = DataValidation(type="list", formula1=formula, allow_blank=True, showDropDown=False)
    dv.promptTitle = "Choose from the list"
    dv.prompt = prompt
    dv.showInputMessage = True
    dv.errorTitle = "Not in the list"
    dv.error = "Please pick a value from the drop-down list."
    ws.add_data_validation(dv)
    dv.add(f"{col}2:{col}{MAX_ROWS}")


def build() -> Workbook:
    wb = Workbook()

    # ---------------- Instructions
    ws = wb.active
    ws.title = "Instructions"
    ws.column_dimensions["A"].width = 110
    lines = [
        ("FabriSCAN+ Content Template", Font(bold=True, size=18, color=INDIGO)),
        ("Fill in this one file with every fabric's name, how to identify it, its textile care, and the sources. The app reads it directly, so please keep the sheet and column names as they are.", None),
        ("", None),
        ("HOW TO FILL IT IN", Font(bold=True, color=INDIGO)),
        ("1. Categories: check the 4 category names. Edit the name or description if needed. Do not change the category_id column.", None),
        ("2. Fabrics: one row per fabric. The proposed list is already filled in. Edit names, delete fabrics you won't include, or add rows for new ones (make a new fabric_id like FAB-NAME, capital letters, no spaces).", None),
        ("   A fabric in two categories (e.g. Piña in Barong and in Gowns & Filipiniana) is ONE row with category_1 and category_2. Its care guide is written once.", None),
        ("   fiber_1 / fiber_2 / fiber_3: what it is made of. If a fabric comes in several fibers (e.g. silk or polyester satin), list each one.", None),
        ("   identify_1 to identify_3: three short things a person can see or feel to check the fabric (e.g. 'See-through when held up to light').", None),
        ("3. Care: one row per fabric per section (Washing, Drying, Ironing, Stain removal, Storage). The rows are already there; fill in the 'steps' cell.", None),
        ("   Write one step per line (press Alt+Enter for a new line inside a cell). Short, plain sentences. The app numbers the steps.", None),
        ("   Ironing rows also need iron_dots (0 = do not iron, 1 = low, 2 = medium, 3 = high) and iron_setting (e.g. 'Low, up to 110 °C, with a press cloth').", None),
        ("   For multi-fiber fabrics, write steps that are safe for the most delicate fiber.", None),
        ("   Beaded fabrics: the steps must protect the beads and sequins too (e.g. no ironing directly on beads, how to store heavy pieces).", None),
        ("4. Stains: one row per fabric per stain type (Food & oil, Sweat, Make-up, Ink). Leave a row empty if you have no advice for that stain. You can add other stain types.", None),
        ("5. Citations: every care section needs at least one source. Give each source an ID (S01, S02, ...) and the full APA 7 reference. Then type the IDs in the citation_ids column of Care and Stains (e.g. 'S01, S04').", None),
        ("6. Images: list the photo files you will send (see the Images sheet).", None),
        ("7. Fill in reviewed_by (initials) and reviewed_on (date) on each fabric when a second researcher has checked it.", None),
        ("", None),
        ("THE EXAMPLE", Font(bold=True, color=INDIGO)),
        ("Piña is filled in as an example (yellow rows). Its text starts with [PLACEHOLDER] EXAMPLE. Replace it with your own content. The app will refuse to build a test version while any [PLACEHOLDER] text is left.", None),
        ("", None),
        ("WHEN YOU ARE DONE", Font(bold=True, color=INDIGO)),
        ("Send this file (and the photos) to the developer. A checker reads it and lists anything missing, e.g. 'Care row 14 (FAB-PINA, Ironing): no citation'. Fix those and send it again.", None),
        ("Questions about a column? See the notes on each column header (hover over the header cell) or tools/content/README.md.", None),
    ]
    for text, font in lines:
        ws.append([text])
        c = ws.cell(ws.max_row, 1)
        c.alignment = Alignment(wrap_text=True, vertical="top")
        if font:
            c.font = font

    # ---------------- Categories
    ws = wb.create_sheet("Categories")
    header(ws, ["category_id", "name", "order", "description"], [22, 28, 8, 70], {
        "category_id": "Fixed ID used by the app. Do not change.",
        "name": "Name shown in the app (Q20: confirm 'Gowns & Filipiniana').",
        "description": "One sentence shown under the category name in Browse.",
    })
    for cid, name, order in CATEGORIES:
        ws.append([cid, name, order, "[PLACEHOLDER] One sentence describing this category."])
    style_rows(ws, 2, ws.max_row)

    # ---------------- Fabrics
    ws = wb.create_sheet("Fabrics")
    cols = ["fabric_id", "name", "other_names", "category_1", "category_2",
            "fiber_1", "fiber_1_type", "fiber_2", "fiber_2_type", "fiber_3", "fiber_3_type",
            "description", "identify_1", "identify_2", "identify_3", "reviewed_by", "reviewed_on", "notes"]
    header(ws, cols, [18, 22, 22, 20, 20, 22, 12, 22, 12, 22, 12, 50, 30, 30, 30, 12, 13, 30], {
        "fabric_id": "Stable ID, e.g. FAB-PINA. Capital letters, no spaces. Must match the scanner's fabric list.",
        "other_names": "Other local or trade names, separated by commas, e.g. 'Piña cloth'.",
        "category_2": "Only if the fabric is also in a second category.",
        "fiber_1": "What it is made of ('san gawa'). If several versions exist, use fiber_2 and fiber_3.",
        "description": "1–3 sentences: how it looks, how it feels, where it is used.",
        "identify_1": "Something a person can see or feel to check the fabric.",
        "reviewed_on": "Date checked, e.g. 2026-12-01.",
    })
    for fid, name, c1, c2 in FABRICS:
        row = {c: "" for c in cols} | {"fabric_id": fid, "name": name, "category_1": c1, "category_2": c2}
        if fid == "FAB-PINA":
            row |= EXAMPLE_FABRIC
        ws.append([row[c] for c in cols])
    style_rows(ws, 2, ws.max_row)
    style_rows(ws, 2, 2, EXAMPLE_FILL)
    dropdown(ws, "=Categories!$A$2:$A$20", "D", "Pick the category_id.")
    dropdown(ws, "=Categories!$A$2:$A$20", "E", "Optional second category.")
    for col in ("G", "I", "K"):
        dropdown(ws, '"' + ",".join(FIBER_TYPES) + '"', col, "natural, synthetic or blend")

    # ---------------- Care
    ws = wb.create_sheet("Care")
    cols = ["fabric_id", "section", "steps", "iron_dots", "iron_setting", "citation_ids", "notes"]
    header(ws, cols, [18, 15, 70, 10, 34, 16, 30], {
        "steps": "One step per line (Alt+Enter). Short, plain sentences. The app numbers them.",
        "iron_dots": "Ironing rows only: 0 = do not iron, 1 = low, 2 = medium, 3 = high.",
        "iron_setting": "Ironing rows only, e.g. 'Low, up to 110 °C, with a press cloth'.",
        "citation_ids": "Source IDs from the Citations sheet, e.g. 'S01, S04'. At least one per row.",
    })
    for fid, *_ in FABRICS:
        for sec in SECTIONS:
            if fid == "FAB-PINA":
                steps, dots, setting, cites = EXAMPLE_CARE[sec]
                ws.append([fid, sec, steps, dots, setting, cites, ""])
            else:
                ws.append([fid, sec, "", "", "", "", ""])
    style_rows(ws, 2, ws.max_row)
    style_rows(ws, 2, 6, EXAMPLE_FILL)
    dropdown(ws, "=Fabrics!$A$2:$A$200", "A", "Pick the fabric_id.")
    dropdown(ws, '"' + ",".join(SECTIONS) + '"', "B", "One of the 5 care sections.")
    dropdown(ws, '"0,1,2,3"', "D", "0 = do not iron, 1 = low, 2 = medium, 3 = high")

    # ---------------- Stains
    ws = wb.create_sheet("Stains")
    cols = ["fabric_id", "stain_type", "steps", "citation_ids", "notes"]
    header(ws, cols, [18, 15, 70, 16, 30], {
        "stain_type": "Food & oil, Sweat, Make-up, Ink. You may type another stain type.",
        "steps": "One step per line (Alt+Enter). Leave empty if there is no advice for this stain.",
        "citation_ids": "Required when steps are filled in.",
    })
    for fid, *_ in FABRICS:
        for stain in STAINS:
            steps = EXAMPLE_STAINS.get(stain, "") if fid == "FAB-PINA" else ""
            ws.append([fid, stain, steps, "S02" if steps else "", ""])
    style_rows(ws, 2, ws.max_row)
    style_rows(ws, 2, 5, EXAMPLE_FILL)
    dropdown(ws, "=Fabrics!$A$2:$A$200", "A", "Pick the fabric_id.")

    # ---------------- Citations
    ws = wb.create_sheet("Citations")
    header(ws, ["citation_id", "apa_reference", "url_or_doi", "notes"], [12, 90, 40, 30], {
        "citation_id": "Short ID: S01, S02, ...",
        "apa_reference": "Full reference in APA 7, as in the thesis.",
    })
    for row in EXAMPLE_CITATIONS:
        ws.append(list(row))
    style_rows(ws, 2, ws.max_row, EXAMPLE_FILL)

    # ---------------- Images
    ws = wb.create_sheet("Images")
    header(ws, ["fabric_id", "file_name", "kind", "photographer", "notes"], [18, 34, 16, 16, 40], {
        "file_name": "e.g. FAB-PINA_main.jpg. Square, at least 1080 px, JPEG.",
        "kind": "main photo (required for each fabric), drape photo (optional), category cover (4 total).",
        "photographer": "Initials only.",
    })
    ws.append(["FAB-PINA", "FAB-PINA_main.jpg", "main photo", "", "[PLACEHOLDER] EXAMPLE row"])
    style_rows(ws, 2, 2, EXAMPLE_FILL)
    dropdown(ws, '"' + ",".join(IMAGE_KINDS) + '"', "C", "main photo, drape photo or category cover")
    ws.append([])
    ws.append(["Photo rules: fabric close-up that fills the frame, natural light, no flash glare, no people's faces. Square, at least 1080 × 1080 px, JPEG. Category covers: 16:9, at least 1280 px wide."])
    ws.cell(ws.max_row, 1).fill = NOTE_FILL
    ws.merge_cells(start_row=ws.max_row, start_column=1, end_row=ws.max_row, end_column=5)
    ws.cell(ws.max_row, 1).alignment = WRAP
    ws.row_dimensions[ws.max_row].height = 32

    for s in wb.worksheets:
        s.sheet_properties.tabColor = INDIGO if s.title == "Instructions" else "8C7A68"
    return wb


if __name__ == "__main__":
    build().save(OUT)
    print(f"wrote {OUT}")
