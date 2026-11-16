"""Tests for tools/ml/check_dataset.py. Run: python -I -m unittest discover -s tools/ml/tests"""
import csv
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import check_dataset as cd  # noqa: E402

JPEG = b"\xff\xd8\xff\xe0" + b"\x00" * 64 + b"\xff\xd9"


def make(root: Path, fabric: str, sample: str, n: int, phones=("phoneA", "phoneB"), bg=False, start=0):
    d = root / fabric / sample
    d.mkdir(parents=True, exist_ok=True)
    for i in range(n):
        light = cd.LIGHTS[i % 3]
        dist = cd.DISTANCES[(i // 3) % 2]
        phone = phones[i % len(phones)]
        b = f"_{cd.BACKGROUNDS[i % 2]}" if bg else ""
        (d / f"{fabric}_{sample}_{phone}_{light}_{dist}{b}_{start + i:03d}.jpg").write_bytes(JPEG + bytes([i % 256, i // 256]) + fabric.encode() + sample.encode())


class CheckDatasetTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.ids = ["FAB-PINA", "FAB-SATIN"]

    def tearDown(self):
        self.tmp.cleanup()

    def run_check(self, fabrics, spike=False):
        r = cd.scan(self.root, self.ids)
        cd.check_metadata(self.root, r)
        cd.evaluate(r, fabrics, spike)
        return r

    def test_parses_valid_names_and_background(self):
        make(self.root, "FAB-PINA", "S01", 6, bg=True)
        r = cd.scan(self.root, self.ids)
        self.assertEqual(len(r.photos), 6)
        self.assertEqual({p.background for p in r.photos}, {"onlight", "ondark"})
        self.assertFalse(r.bad_names)

    def test_flags_bad_names_non_jpeg_broken_and_wrong_folder(self):
        d = self.root / "FAB-SATIN" / "S01"
        d.mkdir(parents=True)
        (d / "IMG_1234.jpg").write_bytes(JPEG)
        (d / "FAB-SATIN_S01_phoneA_day_close_001.heic").write_bytes(b"x")
        (d / "FAB-SATIN_S01_phoneA_day_close_002.jpg").write_bytes(b"not a jpeg")
        (d / "FAB-SATIN_S02_phoneA_day_close_003.jpg").write_bytes(JPEG)
        r = cd.scan(self.root, self.ids)
        self.assertEqual(len(r.bad_names), 1)
        self.assertEqual(len(r.not_jpeg), 1)
        self.assertEqual(len(r.broken), 1)
        self.assertEqual(len(r.wrong_folder), 1)

    def test_duplicates_and_unknown_ids(self):
        make(self.root, "FAB-SATIN", "S01", 1)
        src = next((self.root / "FAB-SATIN" / "S01").iterdir())
        (src.parent / "FAB-SATIN_S01_phoneA_day_close_999.jpg").write_bytes(src.read_bytes())
        make(self.root, "FAB-XYZ", "S01", 1)
        r = cd.scan(self.root, self.ids)
        self.assertEqual(len(r.duplicates), 1)
        self.assertEqual(r.unknown_ids, {"FAB-XYZ"})

    def test_below_minimum_is_a_problem(self):
        make(self.root, "FAB-SATIN", "S01", 60)
        r = self.run_check(["FAB-SATIN"])
        row = r.fabric_rows[0]
        self.assertEqual(row["status"], "NEEDS MORE")
        self.assertIn("needs 2 more piece(s)", row["notes"])

    def test_meets_target(self):
        for s in range(1, 6):
            make(self.root, "FAB-SATIN", f"S0{s}", 60, phones=("phoneA", "phoneB", "phoneC"))
        r = self.run_check(["FAB-SATIN"])
        self.assertEqual(r.fabric_rows[0]["status"], "OK - target")
        self.assertFalse(r.problems)

    def test_lookalike_needs_six_pieces_and_sheer_needs_both_backgrounds(self):
        for s in range(1, 6):
            make(self.root, "FAB-PINA", f"S0{s}", 60)  # no background token
        row = self.run_check(["FAB-PINA"]).fabric_rows[0]
        self.assertEqual(row["status"], "OK - minimum")
        self.assertIn("1 more piece(s) to reach target", row["notes"])
        self.assertIn("background", row["notes"])

    def test_spike_mode(self):
        for s in range(1, 4):
            make(self.root, "FAB-PINA", f"S0{s}", 50)
        r = self.run_check(["FAB-PINA"], spike=True)
        self.assertEqual(r.fabric_rows[0]["status"], "OK - target")

    def test_write_metadata_keeps_notes_and_detects_mismatch(self):
        make(self.root, "FAB-SATIN", "S01", 3)
        r = cd.scan(self.root, self.ids)
        meta = cd.write_metadata(self.root, r)
        rows = list(csv.DictReader(meta.read_text(encoding="utf-8").splitlines()))
        rows[0]["notes"] = "embroidered panel"
        rows[1]["light"] = "dim" if rows[1]["light"] != "dim" else "day"
        with meta.open("w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=cd.META_COLS)
            w.writeheader()
            w.writerows(rows)
        r2 = cd.scan(self.root, self.ids)
        cd.check_metadata(self.root, r2)
        self.assertEqual(len(r2.meta_issues), 1)
        cd.write_metadata(self.root, r2)
        rows2 = list(csv.DictReader(meta.read_text(encoding="utf-8").splitlines()))
        self.assertEqual(rows2[0]["notes"], "embroidered panel")

    def test_catalog_ids_from_repo(self):
        ids = cd.load_catalog_ids(cd.DEFAULT_CATALOG)
        self.assertEqual(len(ids), 23)
        self.assertIn("FAB-TNALAK", ids)
        self.assertIn("FAB-SEQUIN", ids)


if __name__ == "__main__":
    unittest.main()
