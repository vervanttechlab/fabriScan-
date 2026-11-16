#!/usr/bin/env python3
"""FabriSCAN+ content checker and builder (ADR-006).

Reads the researchers' FabriSCAN_Content.xlsx, checks every row, and writes
assets/content/catalog.json for the app.

  python -I tools/content/build_catalog.py [FILE.xlsx]               full check, report only
  python -I tools/content/build_catalog.py FILE.xlsx --write         check, then write catalog.json if clean
  python -I tools/content/build_catalog.py FILE.xlsx --release       strict: no [PLACEHOLDER], photos and
                                                                     scanner labels must match (TAM builds)
  python -I tools/content/build_catalog.py --structure               sheets/columns/IDs only (CI)
  python -I tools/content/build_catalog.py FILE.xlsx --report out.md also save the report as Markdown

Messages name the sheet and Excel row so the researchers can fix them directly,
e.g. "Care row 14 (FAB-PINA, Ironing): no citation".
Requires: openpyxl.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

from openpyxl import load_workbook

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
DEFAULT_XLSX = HERE / "FabriSCAN_Content.xlsx"
DEFAULT_OUT = REPO / "assets" / "content" / "catalog.json"
DEFAULT_IMAGES = HERE / "images"
LABELS = REPO / "assets" / "model" / "labels.txt"
PLACEHOLDER = "[PLACEHOLDER]"
MAX_IMAGE_KB = 400

# The contract with make_template.py (ADR-006). Change only with an ADR update.
COLUMNS = {
    "Categories": ["category_id", "name", "order", "description"],
    "Fabrics": ["fabric_id", "name", "other_names", "category_1", "category_2",
                "fiber_1", "fiber_1_type", "fiber_2", "fiber_2_type", "fiber_3", "fiber_3_type",
                "description", "identify_1", "identify_2", "identify_3", "reviewed_by", "reviewed_on", "notes"],
    "Care": ["fabric_id", "section", "steps", "iron_dots", "iron_setting", "citation_ids", "notes"],
    "Stains": ["fabric_id", "stain_type", "steps", "citation_ids", "notes"],
    "Citations": ["citation_id", "apa_reference", "url_or_doi", "notes"],
    "Images": ["fabric_id", "file_name", "kind", "photographer", "notes"],
}
SECTIONS = {"Washing": "washing", "Drying": "drying", "Ironing": "ironing",
            "Stain removal": "stainRemoval", "Storage": "storage"}
STAIN_IDS = {"food & oil": "food", "sweat": "sweat", "make-up": "makeup", "makeup": "makeup", "ink": "ink"}
FIBER_TYPES = {"natural", "synthetic", "blend"}
FABRIC_ID = re.compile(r"^FAB-[A-Z0-9]+$")
CITE_ID = re.compile(r"^[A-Za-z0-9_-]+$")


@dataclass
class Report:
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    placeholders: list[str] = field(default_factory=list)

    def err(self, msg: str) -> None:
        self.errors.append(msg)

    def warn(self, msg: str) -> None:
        self.warnings.append(msg)


def text(v) -> str:
    if v is None:
        return ""
    if isinstance(v, float) and v.is_integer():
        v = int(v)
    if isinstance(v, (dt.date, dt.datetime)):
        return v.strftime("%Y-%m-%d")
    return str(v).strip()


def lines(v) -> list[str]:
    """One step per line; strips '1.', '2)', '-' and '•' that people type by habit."""
    out = []
    for raw in text(v).replace("\r", "").split("\n"):
        s = re.sub(r"^\s*(?:\d+[.)]|[-•*])\s*", "", raw).strip()
        if s:
            out.append(s)
    return out


def split_ids(v) -> list[str]:
    return [x.strip() for x in re.split(r"[,;/ ]+", text(v)) if x.strip()]


def read_sheet(wb, name: str, rep: Report) -> list[tuple[int, dict]]:
    if name not in wb.sheetnames:
        rep.err(f"Sheet '{name}' is missing. Please keep all sheets from the template.")
        return []
    ws = wb[name]
    header = [text(c.value) for c in next(ws.iter_rows(min_row=1, max_row=1))]
    missing = [c for c in COLUMNS[name] if c not in header]
    if missing:
        rep.err(f"{name}: missing column(s) {', '.join(missing)}. Please don't rename or delete columns.")
        return []
    idx = {h: i for i, h in enumerate(header)}
    rows = []
    for n, row in enumerate(ws.iter_rows(min_row=2, values_only=True), start=2):
        rec = {c: (row[idx[c]] if idx[c] < len(row) else None) for c in COLUMNS[name]}
        if all(text(v) == "" for v in rec.values()):
            continue
        # Free-text notes under a table (Images sheet) are not data rows.
        if name == "Images" and not text(rec["fabric_id"]).startswith(("FAB-",)) and not text(rec["file_name"]):
            continue
        rows.append((n, rec))
        for k, v in rec.items():
            if PLACEHOLDER in text(v):
                rep.placeholders.append(f"{name} row {n}, {k}")
    return rows


def build(xlsx: Path, *, release: bool = False, structure_only: bool = False,
          images_dir: Path = DEFAULT_IMAGES, labels_path: Path = LABELS,
          previous_version: str | None = None, today: dt.date | None = None) -> tuple[dict | None, Report]:
    rep = Report()
    try:
        wb = load_workbook(xlsx, data_only=True)
    except Exception as e:  # noqa: BLE001 - report any unreadable file plainly
        rep.err(f"Can't open {xlsx.name}: {e}")
        return None, rep
    sheets = {name: read_sheet(wb, name, rep) for name in COLUMNS}
    if rep.errors:
        return None, rep

    # ---- Categories
    cats: dict[str, dict] = {}
    for n, r in sheets["Categories"]:
        cid = text(r["category_id"])
        where = f"Categories row {n}"
        if not cid:
            rep.err(f"{where}: category_id is empty")
            continue
        if cid in cats:
            rep.err(f"{where}: category_id '{cid}' is used twice")
        try:
            order = int(float(text(r["order"]) or "0"))
        except ValueError:
            rep.err(f"{where} ({cid}): order must be a number")
            order = 0
        cats[cid] = {"id": cid, "name": text(r["name"]), "order": order,
                     "description": text(r["description"]), "_row": n}
    if not cats:
        rep.err("Categories: no categories found")

    # ---- Fabrics
    fabrics: dict[str, dict] = {}
    for n, r in sheets["Fabrics"]:
        fid = text(r["fabric_id"])
        where = f"Fabrics row {n}" + (f" ({fid})" if fid else "")
        if not FABRIC_ID.match(fid):
            rep.err(f"{where}: fabric_id must look like FAB-NAME (capital letters, no spaces)")
            continue
        if fid in fabrics:
            rep.err(f"{where}: fabric_id is used twice")
            continue
        cat_ids = [c for c in (text(r["category_1"]), text(r["category_2"])) if c]
        for c in cat_ids:
            if c not in cats:
                rep.err(f"{where}: category '{c}' is not in the Categories sheet")
        fibers = []
        for k in (1, 2, 3):
            f, t = text(r[f"fiber_{k}"]), text(r[f"fiber_{k}_type"]).lower()
            if f and t not in FIBER_TYPES:
                rep.err(f"{where}: fiber_{k}_type must be natural, synthetic or blend")
            elif not f and t:
                rep.warn(f"{where}: fiber_{k}_type is set but fiber_{k} is empty")
            if f:
                fibers.append({"fiber": f, "type": t if t in FIBER_TYPES else "natural", "note": ""})
        feats = [text(r[f"identify_{k}"]) for k in (1, 2, 3) if text(r[f"identify_{k}"])]
        fabrics[fid] = {
            "id": fid, "name": text(r["name"]),
            "aka": [a.strip() for a in text(r["other_names"]).split(",") if a.strip()],
            "categoryIds": cat_ids, "fiberContent": fibers,
            "description": text(r["description"]), "identifyingFeatures": feats,
            "images": [], "care": {}, "reviewedBy": text(r["reviewed_by"]),
            "reviewedOn": text(r["reviewed_on"]), "_row": n,
        }
        if structure_only:
            continue
        if not fabrics[fid]["name"]:
            rep.err(f"{where}: name is empty")
        if not cat_ids:
            rep.err(f"{where}: no category (pick category_1)")
        if not fibers:
            rep.err(f"{where}: fiber_1 is empty (what is it made of?)")
        if not fabrics[fid]["description"]:
            rep.err(f"{where}: description is empty")
        if not feats:
            rep.err(f"{where}: identify_1 is empty (how to recognize it)")
        elif len(feats) < 3:
            rep.warn(f"{where}: only {len(feats)} of 3 'identify' points filled in")
        if not fabrics[fid]["reviewedBy"]:
            rep.warn(f"{where}: reviewed_by is empty (not yet checked by a second researcher)")
    if not fabrics and not rep.errors:
        rep.err("Fabrics: no fabrics found")

    # ---- Citations
    cites: dict[str, str] = {}
    for n, r in sheets["Citations"]:
        cid, apa = text(r["citation_id"]), text(r["apa_reference"])
        where = f"Citations row {n}" + (f" ({cid})" if cid else "")
        if not cid or not CITE_ID.match(cid):
            rep.err(f"{where}: citation_id must be a short ID like S01")
            continue
        if cid in cites:
            rep.err(f"{where}: citation_id is used twice")
        if not apa and not structure_only:
            rep.err(f"{where}: apa_reference is empty")
        cites[cid] = apa

    def check_cites(where: str, ids: list[str]) -> list[str]:
        if not ids:
            rep.err(f"{where}: no citation (add a source ID from the Citations sheet)")
        for c in ids:
            if c not in cites:
                rep.err(f"{where}: citation {c} is not in the Citations sheet")
        return ids

    # ---- Care
    seen: dict[tuple[str, str], int] = {}
    for n, r in sheets["Care"]:
        fid, sec = text(r["fabric_id"]), text(r["section"])
        where = f"Care row {n} ({fid or '?'}, {sec or '?'})"
        if fid not in fabrics:
            rep.err(f"{where}: fabric_id is not in the Fabrics sheet")
            continue
        if sec not in SECTIONS:
            rep.err(f"{where}: section must be one of {', '.join(SECTIONS)}")
            continue
        if (fid, sec) in seen:
            rep.err(f"{where}: {sec} appears twice for this fabric (also row {seen[(fid, sec)]})")
            continue
        seen[(fid, sec)] = n
        entry = {"steps": lines(r["steps"]), "citationIds": split_ids(r["citation_ids"])}
        if not structure_only:
            if not entry["steps"] and sec != "Stain removal":
                rep.err(f"{where}: steps are empty")
            check_cites(where, entry["citationIds"])
            if sec == "Ironing":
                dots_raw, setting = text(r["iron_dots"]), text(r["iron_setting"])
                if dots_raw not in {"0", "1", "2", "3"}:
                    rep.err(f"{where}: iron_dots is missing (0 = do not iron, 1 low, 2 medium, 3 high)")
                if not setting:
                    rep.err(f"{where}: iron_setting is empty (e.g. 'Low, up to 110 °C')")
                if dots_raw in {"0", "1", "2", "3"}:
                    entry["setting"] = {"dots": int(dots_raw), "text": setting}
            for s in entry["steps"]:
                if len(s) > 220:
                    rep.warn(f"{where}: a step is very long ({len(s)} characters); shorter steps are easier to follow")
        fabrics[fid]["care"][SECTIONS[sec]] = entry

    # ---- Stains
    stain_names: dict[str, str] = {}
    for n, r in sheets["Stains"]:
        fid, stain = text(r["fabric_id"]), text(r["stain_type"])
        where = f"Stains row {n} ({fid or '?'}, {stain or '?'})"
        if fid not in fabrics:
            rep.err(f"{where}: fabric_id is not in the Fabrics sheet")
            continue
        steps = lines(r["steps"])
        if not steps:
            continue  # empty row = no advice for this stain
        if not stain:
            rep.err(f"{where}: stain_type is empty")
            continue
        sid = STAIN_IDS.get(stain.lower()) or re.sub(r"[^a-z0-9]+", "-", stain.lower()).strip("-")
        stain_names.setdefault(sid, stain)
        ids = split_ids(r["citation_ids"])
        if not structure_only:
            check_cites(where, ids)
        care = fabrics[fid]["care"].setdefault("stainRemoval", {"steps": [], "citationIds": []})
        care.setdefault("byStain", []).append({"stain": sid, "steps": steps, "citationIds": ids})

    # ---- Completeness per fabric
    if not structure_only:
        for fid, f in fabrics.items():
            for sec, key in SECTIONS.items():
                if key not in f["care"]:
                    rep.err(f"{fid}: has no {sec} row in the Care sheet")
            sr = f["care"].get("stainRemoval")
            if sr is not None and not sr["steps"] and not sr.get("byStain"):
                rep.err(f"{fid}: Stain removal has no steps and no stain-type advice (Stains sheet)")
            for k, sec in f["care"].items():
                sec.setdefault("citationIds", [])
            f["care"].setdefault("stainRemoval", {"steps": [], "citationIds": []}).setdefault("byStain", [])

    # ---- Images
    for n, r in sheets["Images"]:
        fid, name, kind = text(r["fabric_id"]), text(r["file_name"]), text(r["kind"]).lower()
        where = f"Images row {n} ({name or '?'})"
        if PLACEHOLDER in text(r["notes"]):
            continue
        if fid and fid not in fabrics and kind != "category cover":
            rep.err(f"{where}: fabric_id {fid} is not in the Fabrics sheet")
            continue
        if not name:
            continue
        path = images_dir / name
        if not path.exists():
            (rep.err if release else rep.warn)(f"Image {name} not found in {images_dir.name}/")
        elif path.stat().st_size > MAX_IMAGE_KB * 1024:
            rep.warn(f"Image {name} is {path.stat().st_size // 1024} KB; it will be compressed to stay under {MAX_IMAGE_KB} KB")
        if fid in fabrics and kind in {"main photo", "drape photo"}:
            asset = f"assets/content/images/{name}"
            if kind == "main photo":
                fabrics[fid]["images"].insert(0, asset)
            else:
                fabrics[fid]["images"].append(asset)
    if release:
        for fid, f in fabrics.items():
            if not f["images"]:
                rep.err(f"{fid}: no main photo listed in the Images sheet")

    # ---- Scanner labels must match the fabric list
    if release and not structure_only:
        if labels_path.exists():
            labels = {l.strip() for l in labels_path.read_text(encoding="utf-8").splitlines() if l.strip()}
            labels.discard("not_fabric")
            for fid in sorted(set(fabrics) - labels):
                rep.err(f"{fid} is not in the scanner's fabric list (assets/model/labels.txt)")
            for fid in sorted(labels - set(fabrics)):
                rep.err(f"The scanner knows {fid}, but it is not in the Fabrics sheet")
        else:
            rep.err("assets/model/labels.txt is missing (the scanner's fabric list)")

    # ---- Placeholder text
    if rep.placeholders:
        msg = f"[PLACEHOLDER] text found in {len(rep.placeholders)} cell(s), e.g. {rep.placeholders[0]}"
        (rep.err if release else rep.warn)(msg + ("" if release else ". Allowed now; a TAM build refuses it."))

    for cid, c in cats.items():
        if not structure_only and not c["name"]:
            rep.err(f"Categories row {c['_row']} ({cid}): name is empty")
        if not structure_only and not any(cid in f["categoryIds"] for f in fabrics.values()):
            rep.warn(f"Category {c['name'] or cid} has no fabrics")

    if rep.errors:
        return None, rep

    today = today or dt.date.today()
    base = today.strftime("%Y.%m.%d")
    inc = 1
    if previous_version and previous_version.startswith(base + "+"):
        try:
            inc = int(previous_version.split("+", 1)[1]) + 1
        except ValueError:
            inc = 1
    categories = sorted(cats.values(), key=lambda c: c["order"])
    for c in categories:
        first = next((f["id"] for f in fabrics.values() if c["id"] in f["categoryIds"]), None)
        c["coverFabricId"] = first
        c.pop("_row", None)
    for f in fabrics.values():
        f.pop("_row", None)
    known = {"food": "Food & oil", "sweat": "Sweat", "makeup": "Make-up", "ink": "Ink"}
    catalog = {
        "contentVersion": f"{base}+{inc}",
        "status": (f"{PLACEHOLDER} Contains sample or unfinished text. Not for TAM builds."
                   if rep.placeholders else "researcher content"),
        "categories": categories,
        "stainTypes": [{"id": k, "name": known.get(k, v)} for k, v in stain_names.items()],
        "fabrics": list(fabrics.values()),
        "citations": [{"id": k, "apa": v} for k, v in cites.items()],
    }
    return catalog, rep


def render(rep: Report, xlsx: Path, mode: str, catalog: dict | None) -> str:
    out = [f"# FabriSCAN+ content check ({mode})", "", f"File: `{xlsx.name}`", ""]
    if catalog:
        n = len(catalog["fabrics"])
        out.append(f"**OK: {n} fabrics, {len(catalog['categories'])} categories, "
                   f"{len(catalog['citations'])} sources.** Content version {catalog['contentVersion']}.")
    else:
        out.append(f"**{len(rep.errors)} problem(s) to fix** before the app can use this file.")
    if rep.errors:
        out += ["", "## Please fix", ""] + [f"{i}. {e}" for i, e in enumerate(rep.errors, 1)]
    if rep.warnings:
        out += ["", "## Worth checking", ""] + [f"- {w}" for w in rep.warnings]
    return "\n".join(out) + "\n"


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("xlsx", nargs="?", type=Path, default=DEFAULT_XLSX)
    ap.add_argument("--write", action="store_true", help="write catalog.json when there are no problems")
    ap.add_argument("--release", action="store_true", help="strict TAM-build check (implies --write)")
    ap.add_argument("--structure", action="store_true", help="only sheets, columns and IDs (CI)")
    ap.add_argument("--check", action="store_true", help="report only (default)")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--images", type=Path, default=DEFAULT_IMAGES)
    ap.add_argument("--report", type=Path)
    a = ap.parse_args(argv)
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
    except Exception:  # noqa: BLE001
        pass

    previous = None
    if a.out.exists():
        try:
            previous = json.loads(a.out.read_text(encoding="utf-8")).get("contentVersion")
        except (OSError, ValueError):
            previous = None
    mode = "structure" if a.structure else "release" if a.release else "check"
    catalog, rep = build(a.xlsx, release=a.release, structure_only=a.structure,
                         images_dir=a.images, previous_version=previous)
    text_report = render(rep, a.xlsx, mode, catalog)
    print(text_report)
    if a.report:
        a.report.write_text(text_report, encoding="utf-8")
    if catalog and (a.write or a.release) and not a.structure:
        a.out.parent.mkdir(parents=True, exist_ok=True)
        a.out.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"Wrote {a.out}")
    return 0 if catalog else 1


if __name__ == "__main__":
    sys.exit(main())
