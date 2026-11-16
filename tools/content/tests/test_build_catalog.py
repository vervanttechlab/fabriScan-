"""Tests for build_catalog.py. Run: python -I -m unittest discover -s tools/content/tests"""
import datetime as dt
import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import build_catalog as bc  # noqa: E402
import make_template as mt  # noqa: E402

KEEP = ("FAB-PINA", "FAB-SATIN")


def filled_workbook():
    """The real template, trimmed to 2 fabrics and filled with test content."""
    wb = mt.build()

    def trim(ws, keep_col=1):
        for r in range(ws.max_row, 1, -1):
            v = ws.cell(r, keep_col).value
            if v and str(v).startswith("FAB-") and v not in KEEP:
                ws.delete_rows(r)

    for name in ("Fabrics", "Care", "Stains"):
        trim(wb[name])
    fab = wb["Fabrics"]
    cols = [c.value for c in fab[1]]
    for r in range(2, fab.max_row + 1):
        fid = fab.cell(r, 1).value
        vals = {
            "other_names": "Piña cloth" if fid == "FAB-PINA" else "",
            "fiber_1": "Pineapple-leaf fiber" if fid == "FAB-PINA" else "Polyester",
            "fiber_1_type": "natural" if fid == "FAB-PINA" else "synthetic",
            "fiber_2": "" if fid == "FAB-PINA" else "Silk",
            "fiber_2_type": "" if fid == "FAB-PINA" else "natural",
            "description": f"Test description of {fid}.",
            "identify_1": "Feature one", "identify_2": "Feature two", "identify_3": "Feature three",
            "reviewed_by": "AB", "reviewed_on": "2026-12-01",
        }
        for k, v in vals.items():
            fab.cell(r, cols.index(k) + 1, v)
    care = wb["Care"]
    for r in range(2, care.max_row + 1):
        sec = care.cell(r, 2).value
        care.cell(r, 3, "1. First step.\n2. Second step.")
        care.cell(r, 6, "S01")
        if sec == "Ironing":
            care.cell(r, 4, 1)
            care.cell(r, 5, "Low, up to 110 °C")
        else:
            care.cell(r, 4).value = None
            care.cell(r, 5).value = None
    st = wb["Stains"]
    for r in range(2, st.max_row + 1):
        st.cell(r, 3, "Blot.\nRinse." if st.cell(r, 2).value in ("Food & oil", "Sweat") else None)
        st.cell(r, 4).value = "S02" if st.cell(r, 3).value else None
    cit = wb["Citations"]
    cit.cell(2, 2, "Author, A. (2020). Fabric care. Publisher.")
    cit.cell(3, 2, "Org. (2021). Stains. Site. https://example.org")
    cit.cell(2, 4).value = None
    cats = wb["Categories"]
    for r in range(2, cats.max_row + 1):
        cats.cell(r, 4, "A category description.")
    img = wb["Images"]
    img.cell(2, 5).value = None  # the example row becomes a real row
    return wb


class BuildCatalogTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name)
        self.images = self.dir / "images"
        self.images.mkdir()
        self.labels = self.dir / "labels.txt"
        self.labels.write_text("FAB-PINA\nFAB-SATIN\nnot_fabric\n", encoding="utf-8")

    def tearDown(self):
        self.tmp.cleanup()

    def save(self, wb, name="c.xlsx"):
        p = self.dir / name
        wb.save(p)
        return p

    def run_build(self, wb, **kw):
        kw.setdefault("images_dir", self.images)
        kw.setdefault("labels_path", self.labels)
        return bc.build(self.save(wb), **kw)

    def test_blank_template_passes_structure_check(self):
        catalog, rep = bc.build(self.save(mt.build()), structure_only=True)
        self.assertEqual(rep.errors, [])
        self.assertIsNotNone(catalog)

    def test_blank_template_lists_row_level_problems(self):
        catalog, rep = self.run_build(mt.build())
        self.assertIsNone(catalog)
        self.assertIn("Care row 7 (FAB-PINASEDA, Washing): steps are empty", rep.errors)
        self.assertIn("Care row 7 (FAB-PINASEDA, Washing): no citation (add a source ID from the Citations sheet)",
                      rep.errors)
        self.assertTrue(any(e.startswith("Fabrics row 3 (FAB-PINASEDA): fiber_1 is empty") for e in rep.errors))

    def test_filled_file_builds_catalog_for_the_app(self):
        catalog, rep = self.run_build(filled_workbook(), today=dt.date(2026, 12, 1))
        self.assertEqual(rep.errors, [], rep.errors)
        self.assertEqual(catalog["contentVersion"], "2026.12.01+1")
        self.assertEqual(catalog["status"], "researcher content")
        pina = next(f for f in catalog["fabrics"] if f["id"] == "FAB-PINA")
        self.assertEqual(pina["aka"], ["Piña cloth"])
        self.assertEqual(pina["categoryIds"], ["barong", "gowns_filipiniana"])
        self.assertEqual(pina["care"]["washing"]["steps"], ["First step.", "Second step."])
        self.assertEqual(pina["care"]["ironing"]["setting"], {"dots": 1, "text": "Low, up to 110 °C"})
        self.assertEqual([s["stain"] for s in pina["care"]["stainRemoval"]["byStain"]], ["food", "sweat"])
        self.assertEqual({c["id"] for c in catalog["categories"]},
                         {"barong", "formal", "gowns_filipiniana", "beaded"})
        self.assertIn({"id": "food", "name": "Food & oil"}, catalog["stainTypes"])

    def test_missing_and_unknown_citations(self):
        wb = filled_workbook()
        wb["Care"].cell(4, 6).value = None
        wb["Care"].cell(5, 6, "S09")
        _, rep = self.run_build(wb)
        self.assertIn("Care row 4 (FAB-PINA, Ironing): no citation (add a source ID from the Citations sheet)",
                      rep.errors)
        self.assertIn("Care row 5 (FAB-PINA, Stain removal): citation S09 is not in the Citations sheet",
                      rep.errors)

    def test_ironing_needs_heat_level(self):
        wb = filled_workbook()
        wb["Care"].cell(4, 4).value = None
        _, rep = self.run_build(wb)
        self.assertIn("Care row 4 (FAB-PINA, Ironing): iron_dots is missing (0 = do not iron, 1 low, 2 medium, 3 high)",
                      rep.errors)

    def test_missing_section_and_bad_category(self):
        wb = filled_workbook()
        wb["Care"].delete_rows(6)  # FAB-PINA Storage
        wb["Fabrics"].cell(3, 4, "gowns")  # old category id
        _, rep = self.run_build(wb)
        self.assertIn("FAB-PINA: has no Storage row in the Care sheet", rep.errors)
        self.assertIn("Fabrics row 3 (FAB-SATIN): category 'gowns' is not in the Categories sheet", rep.errors)

    def test_placeholder_allowed_in_check_refused_in_release(self):
        wb = filled_workbook()
        wb["Fabrics"].cell(2, 12, "[PLACEHOLDER] write this")
        catalog, rep = self.run_build(wb)
        self.assertIsNotNone(catalog)
        self.assertTrue(catalog["status"].startswith("[PLACEHOLDER]"))
        (self.images / "FAB-PINA_main.jpg").write_bytes(b"x")
        catalog, rep = self.run_build(wb, release=True)
        self.assertIsNone(catalog)
        self.assertTrue(any(e.startswith("[PLACEHOLDER] text found") for e in rep.errors))

    def test_release_checks_photos_and_scanner_labels(self):
        wb = filled_workbook()
        self.labels.write_text("FAB-PINA\nFAB-LINEN\nnot_fabric\n", encoding="utf-8")
        _, rep = self.run_build(wb, release=True)
        self.assertIn("Image FAB-PINA_main.jpg not found in images/", rep.errors)
        self.assertIn("FAB-SATIN: no main photo listed in the Images sheet", rep.errors)
        self.assertIn("FAB-SATIN is not in the scanner's fabric list (assets/model/labels.txt)", rep.errors)
        self.assertIn("The scanner knows FAB-LINEN, but it is not in the Fabrics sheet", rep.errors)

    def test_version_increments_on_same_day(self):
        catalog, _ = self.run_build(filled_workbook(), today=dt.date(2026, 12, 1),
                                    previous_version="2026.12.01+3")
        self.assertEqual(catalog["contentVersion"], "2026.12.01+4")

    def test_cli_writes_catalog(self):
        out = self.dir / "catalog.json"
        code = bc.main([str(self.save(filled_workbook())), "--write", "--out", str(out),
                        "--images", str(self.images)])
        self.assertEqual(code, 0)
        data = json.loads(out.read_text(encoding="utf-8"))
        self.assertEqual(len(data["fabrics"]), 2)


if __name__ == "__main__":
    unittest.main()
