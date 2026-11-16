#!/usr/bin/env python3
"""FabriSCAN+ dataset checker.

Checks the researchers' photo folder against tools/ml/PHOTO_GUIDE.md and
docs/architecture/ml-plan.md section 2, then prints a short report they can act on.

Usage:
  python -I tools/ml/check_dataset.py <dataset_dir>
  python -I tools/ml/check_dataset.py <dataset_dir> --spike             # only the 5 week-1 fabrics
  python -I tools/ml/check_dataset.py <dataset_dir> --write-metadata    # (re)build metadata.csv from file names
  python -I tools/ml/check_dataset.py <dataset_dir> --report report.md  # also save a Markdown report
  python -I tools/ml/check_dataset.py <dataset_dir> --strict            # exit 1 if anything is below minimum

Standard library only. If Pillow is installed, it also verifies each JPEG fully and checks image size.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import re
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path

try:  # optional
    from PIL import Image  # type: ignore

    HAVE_PIL = True
except Exception:  # pragma: no cover - depends on environment
    HAVE_PIL = False

REPO = Path(__file__).resolve().parents[2]
DEFAULT_CATALOG = REPO / "docs" / "product" / "fabric-catalog.md"

NOT_FABRIC = "not_fabric"
SPIKE = ["FAB-PINA", "FAB-PINASEDA", "FAB-JUSI", "FAB-ORGANZA", "FAB-SATIN"]
LOOKALIKES = {"FAB-PINA", "FAB-PINASEDA", "FAB-JUSI", "FAB-ORGANZA"}
SHEER = {"FAB-ORGANZA", "FAB-PINA", "FAB-TULLE"}
LIGHTS = ("day", "indoor", "dim")
DISTANCES = ("close", "far")
BACKGROUNDS = ("onlight", "ondark")

# Targets from ml-plan.md section 2.1 (min, target)
SAMPLES = (3, 5)
SAMPLES_LOOKALIKE = (3, 6)
PHOTOS_PER_SAMPLE = (50, 60)
PHOTOS_PER_FABRIC = (150, 300)
NOT_FABRIC_PHOTOS = (300, 500)
NOT_FABRIC_SAMPLES = 5
SPIKE_SAMPLES, SPIKE_PHOTOS_PER_SAMPLE = 3, 50
LIGHT_MIN_SHARE = 0.20  # target is about 1/3 each
DIST_MIN_SHARE = 0.35  # target is about 1/2 each
BG_MIN_SHARE = 0.25  # sheer fabrics: both backgrounds
PHONES_PER_FABRIC = 2
PHONES_OVERALL = 3
MIN_SHORT_SIDE = 640  # pixels, only checked with Pillow

NAME_RE = re.compile(
    r"^(?P<fabric>FAB-[A-Z0-9]+|not_fabric)_(?P<sample>S\d{2,})_(?P<phone>phone[A-Za-z0-9]+)"
    r"_(?P<light>day|indoor|dim)_(?P<distance>close|far)(?:_(?P<background>onlight|ondark))?"
    r"_(?P<num>\d{3,})\.(?:jpg|jpeg)$",
    re.IGNORECASE,
)
IMAGE_EXT = {".jpg", ".jpeg", ".png", ".heic", ".heif", ".webp"}
META_COLS = ["file", "fabric_id", "sample_id", "phone", "light", "distance", "background", "notes"]


@dataclass
class Photo:
    rel: str
    fabric: str
    sample: str
    phone: str
    light: str
    distance: str
    background: str


@dataclass
class Result:
    photos: list[Photo] = field(default_factory=list)
    bad_names: list[str] = field(default_factory=list)
    wrong_folder: list[str] = field(default_factory=list)
    not_jpeg: list[str] = field(default_factory=list)
    broken: list[str] = field(default_factory=list)
    small: list[str] = field(default_factory=list)
    duplicates: list[list[str]] = field(default_factory=list)
    unknown_ids: set[str] = field(default_factory=set)
    meta_issues: list[str] = field(default_factory=list)
    fabric_rows: list[dict] = field(default_factory=list)
    problems: list[str] = field(default_factory=list)  # below-minimum findings


def load_catalog_ids(path: Path) -> list[str]:
    if not path.exists():
        return []
    ids: list[str] = []
    for m in re.finditer(r"\|\s*(FAB-[A-Z0-9]+)\s*\|", path.read_text(encoding="utf-8")):
        if m.group(1) not in ids:
            ids.append(m.group(1))
    return ids


def looks_like_jpeg(p: Path) -> bool:
    try:
        size = p.stat().st_size
        if size < 4:
            return False
        with p.open("rb") as f:
            head = f.read(2)
            f.seek(max(0, size - 4096))
            tail = f.read()
        return head == b"\xff\xd8" and b"\xff\xd9" in tail
    except OSError:
        return False


def check_image(p: Path) -> tuple[bool, tuple[int, int] | None]:
    """Return (ok, (w, h) or None)."""
    if not HAVE_PIL:
        return looks_like_jpeg(p), None
    try:
        with Image.open(p) as im:
            im.verify()
        with Image.open(p) as im:
            return im.format == "JPEG", im.size
    except Exception:
        return False, None


def sha1(p: Path) -> str:
    h = hashlib.sha1()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def scan(root: Path, catalog_ids: list[str]) -> Result:
    r = Result()
    known = set(catalog_ids) | {NOT_FABRIC}
    hashes: dict[str, list[str]] = defaultdict(list)
    for p in sorted(root.rglob("*")):
        if not p.is_file() or p.suffix.lower() not in IMAGE_EXT:
            continue
        rel = p.relative_to(root).as_posix()
        if p.suffix.lower() not in {".jpg", ".jpeg"}:
            r.not_jpeg.append(rel)
            continue
        m = NAME_RE.match(p.name)
        if not m:
            r.bad_names.append(rel)
            continue
        fabric = m["fabric"] if m["fabric"].lower() != NOT_FABRIC else NOT_FABRIC
        fabric = fabric if fabric == NOT_FABRIC else fabric.upper()
        sample = m["sample"].upper()
        parts = p.relative_to(root).parts
        if len(parts) != 3 or parts[0] != fabric or parts[1].upper() != sample:
            r.wrong_folder.append(f"{rel}  (expected {fabric}/{sample}/)")
        if fabric not in known:
            r.unknown_ids.add(fabric)
        ok, size = check_image(p)
        if not ok:
            r.broken.append(rel)
            continue
        if size and min(size) < MIN_SHORT_SIDE:
            r.small.append(f"{rel}  ({size[0]}x{size[1]})")
        hashes[sha1(p)].append(rel)
        r.photos.append(
            Photo(rel, fabric, sample, m["phone"], m["light"].lower(), m["distance"].lower(),
                  (m["background"] or "").lower())
        )
    r.duplicates = [v for v in hashes.values() if len(v) > 1]
    return r


def check_metadata(root: Path, r: Result) -> None:
    meta = root / "metadata.csv"
    if not meta.exists():
        r.meta_issues.append("metadata.csv not found (run with --write-metadata to create it from file names)")
        return
    with meta.open(newline="", encoding="utf-8-sig") as f:
        rows = list(csv.DictReader(f))
    if rows and set(META_COLS) - set(rows[0].keys()):
        r.meta_issues.append(f"metadata.csv is missing columns: {sorted(set(META_COLS) - set(rows[0].keys()))}")
        return
    by_file = {row["file"]: row for row in rows}
    on_disk = {ph.rel: ph for ph in r.photos}
    for rel in sorted(set(on_disk) - set(by_file)):
        r.meta_issues.append(f"no metadata row: {rel}")
    for rel in sorted(set(by_file) - set(on_disk)):
        r.meta_issues.append(f"row but no valid photo: {rel}")
    for rel, ph in on_disk.items():
        row = by_file.get(rel)
        if not row:
            continue
        for col, val in (("fabric_id", ph.fabric), ("sample_id", ph.sample), ("phone", ph.phone),
                         ("light", ph.light), ("distance", ph.distance), ("background", ph.background)):
            if (row.get(col) or "").strip() != val:
                r.meta_issues.append(f"{rel}: {col} is '{row.get(col)}', file name says '{val}'")


def write_metadata(root: Path, r: Result) -> Path:
    meta = root / "metadata.csv"
    notes: dict[str, str] = {}
    if meta.exists():
        with meta.open(newline="", encoding="utf-8-sig") as f:
            notes = {row.get("file", ""): row.get("notes", "") for row in csv.DictReader(f)}
    with meta.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(META_COLS)
        for ph in sorted(r.photos, key=lambda x: x.rel):
            w.writerow([ph.rel, ph.fabric, ph.sample, ph.phone, ph.light, ph.distance, ph.background,
                        notes.get(ph.rel, "")])
    return meta


def share(counter: Counter, keys, total: int) -> dict[str, float]:
    return {k: (counter[k] / total if total else 0.0) for k in keys}


def evaluate(r: Result, fabrics: list[str], spike: bool) -> None:
    by_fab: dict[str, list[Photo]] = defaultdict(list)
    for ph in r.photos:
        by_fab[ph.fabric].append(ph)
    all_phones = {ph.phone for ph in r.photos}
    if r.photos and len(all_phones) < PHONES_OVERALL and not spike:
        r.problems.append(f"Only {len(all_phones)} phone(s) used overall; use at least {PHONES_OVERALL}.")

    for fab in fabrics:
        photos = by_fab.get(fab, [])
        is_nf = fab == NOT_FABRIC
        per_sample = Counter(ph.sample for ph in photos)
        n, ns = len(photos), len(per_sample)
        notes: list[str] = []
        if spike:
            smin, stgt, pmin, ptgt = SPIKE_SAMPLES, SPIKE_SAMPLES, SPIKE_PHOTOS_PER_SAMPLE * SPIKE_SAMPLES, \
                SPIKE_PHOTOS_PER_SAMPLE * SPIKE_SAMPLES
        elif is_nf:
            smin, stgt = NOT_FABRIC_SAMPLES, NOT_FABRIC_SAMPLES
            pmin, ptgt = NOT_FABRIC_PHOTOS
        else:
            smin, stgt = SAMPLES_LOOKALIKE if fab in LOOKALIKES else SAMPLES
            pmin, ptgt = PHOTOS_PER_FABRIC
        below = False
        if n == 0:
            notes.append("no photos yet")
            below = True
        else:
            if ns < smin:
                notes.append(f"needs {smin - ns} more piece(s)")
                below = True
            elif ns < stgt:
                notes.append(f"{stgt - ns} more piece(s) to reach target")
            if n < pmin:
                notes.append(f"needs {pmin - n} more photos")
                below = True
            if not is_nf:
                per_min = SPIKE_PHOTOS_PER_SAMPLE if spike else PHOTOS_PER_SAMPLE[0]
                thin = [s for s, c in sorted(per_sample.items()) if c < per_min]
                if thin:
                    notes.append(f"under {per_min} photos: {', '.join(thin)}")
                    below = True
                lights = share(Counter(ph.light for ph in photos), LIGHTS, n)
                low = [k for k, v in lights.items() if v < LIGHT_MIN_SHARE]
                if low:
                    notes.append(f"more '{'/'.join(low)}' light")
                dists = share(Counter(ph.distance for ph in photos), DISTANCES, n)
                lowd = [k for k, v in dists.items() if v < DIST_MIN_SHARE]
                if lowd:
                    notes.append(f"more '{'/'.join(lowd)}' shots")
                phones = {ph.phone for ph in photos}
                if len(phones) < PHONES_PER_FABRIC:
                    notes.append(f"use {PHONES_PER_FABRIC}+ phones")
                if fab in SHEER:
                    bgs = share(Counter(ph.background for ph in photos), BACKGROUNDS, n)
                    lowb = [k for k, v in bgs.items() if v < BG_MIN_SHARE]
                    if lowb:
                        notes.append(f"sheer: more '{'/'.join(lowb)}' background")
        if below:
            r.problems.append(f"{fab}: {'; '.join(notes)}")
        status = "NEEDS MORE" if below else ("OK - target" if n >= ptgt and ns >= stgt else "OK - minimum")
        lights = Counter(ph.light for ph in photos)
        dists = Counter(ph.distance for ph in photos)
        r.fabric_rows.append({
            "fabric": fab, "pieces": ns, "photos": n, "phones": len({ph.phone for ph in photos}),
            "light": "/".join(str(lights[k]) for k in LIGHTS),
            "dist": "/".join(str(dists[k]) for k in DISTANCES),
            "status": status, "notes": "; ".join(notes),
        })


def render(r: Result, root: Path, spike: bool) -> str:
    out: list[str] = []
    title = "FabriSCAN+ dataset check" + (" (week-1 spike fabrics)" if spike else "")
    out += [f"# {title}", "", f"Folder: `{root}`", f"Valid photos: **{len(r.photos)}** · "
            f"Pieces: **{len({(p.fabric, p.sample) for p in r.photos})}** · "
            f"Phones: **{len({p.phone for p in r.photos})}**"
            + ("" if HAVE_PIL else " · (Pillow not installed: basic JPEG check only)"), ""]
    out += ["## Per fabric", "", "| Fabric | Pieces | Photos | Phones | Light day/indoor/dim | Close/far | Status | What to do |",
            "|---|---|---|---|---|---|---|---|"]
    for row in r.fabric_rows:
        out.append(f"| {row['fabric']} | {row['pieces']} | {row['photos']} | {row['phones']} | {row['light']} | "
                   f"{row['dist']} | {row['status']} | {row['notes'] or '-'} |")
    out.append("")

    def section(name: str, items, limit: int = 20, hint: str = "") -> None:
        if not items:
            return
        out.append(f"## {name} ({len(items)})")
        if hint:
            out.append(hint)
        out.append("")
        for it in list(items)[:limit]:
            out.append(f"- {' = '.join(it) if isinstance(it, list) else it}")
        if len(items) > limit:
            out.append(f"- ... and {len(items) - limit} more")
        out.append("")

    section("File names that don't follow the guide", r.bad_names,
            hint="Expected e.g. `FAB-PINA_S01_phoneA_day_close_001.jpg` (PHOTO_GUIDE.md section 5).")
    section("Photos in the wrong folder", r.wrong_folder)
    section("Not JPEG", r.not_jpeg, hint="Convert to JPEG (iPhone: Settings > Camera > Formats > Most Compatible).")
    section("Broken or unreadable photos", r.broken)
    section("Too small", r.small, hint=f"Short side under {MIN_SHORT_SIDE} px.")
    section("Exact duplicates (same photo twice)", r.duplicates)
    section("Fabric IDs not in fabric-catalog.md", sorted(r.unknown_ids))
    section("metadata.csv issues", r.meta_issues)
    if not any([r.problems, r.bad_names, r.wrong_folder, r.not_jpeg, r.broken, r.duplicates, r.unknown_ids]):
        out.append("**Everything checked is at or above the minimum.**")
    return "\n".join(out) + "\n"


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("dataset", type=Path)
    ap.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    ap.add_argument("--spike", action="store_true", help="check only the 5 week-1 spike fabrics")
    ap.add_argument("--write-metadata", action="store_true", help="(re)build metadata.csv from file names, keeping notes")
    ap.add_argument("--report", type=Path, help="also write the report to this Markdown file")
    ap.add_argument("--strict", action="store_true", help="exit 1 if any fabric is below minimum or files have errors")
    a = ap.parse_args(argv)

    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
    except Exception:
        pass
    if not a.dataset.is_dir():
        print(f"Not a folder: {a.dataset}", file=sys.stderr)
        return 2
    ids = load_catalog_ids(a.catalog)
    if not ids:
        print(f"Warning: no fabric IDs found in {a.catalog}", file=sys.stderr)
    fabrics = SPIKE if a.spike else ids + [NOT_FABRIC]

    r = scan(a.dataset, ids)
    if a.write_metadata:
        print(f"Wrote {write_metadata(a.dataset, r)}")
    check_metadata(a.dataset, r)
    evaluate(r, fabrics, a.spike)
    text = render(r, a.dataset, a.spike)
    print(text)
    if a.report:
        a.report.write_text(text, encoding="utf-8")
        print(f"Saved {a.report}")
    errors = r.bad_names or r.wrong_folder or r.not_jpeg or r.broken or r.duplicates or r.unknown_ids
    return 1 if a.strict and (r.problems or errors) else 0


if __name__ == "__main__":
    sys.exit(main())
