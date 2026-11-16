# ADR-006 — Content delivery: spreadsheet → validated JSON bundled in the app

**Status:** Accepted (2026-11-16) · **Traces to:** F4, F5, R3, R6, US-20, US-30, US-60, `fabric-catalog.md`

## Context
The researchers (who aren't developers) write the fabric descriptions, care text and citations. The content must work offline (N3), be easy to edit, and be checked for completeness: no placeholders and citations on every section.

## Options
1. JSON edited by hand in the repo: error-prone for non-developers.
2. **Spreadsheet (Google Sheets/Excel) → build script → validated JSON bundled in the app.**
3. Remote CMS or Firestore content: content can change without a new build, but needs a network and caching, and adds complexity.

## Decision
**Option 2.**
- The researchers edit `content/FabriSCAN_Content.xlsx` (or export it from Google Sheets). It has these sheets:
  - `Categories`
  - `Fabrics`
  - `Care` (one row per fabric per section)
  - `Stains` (one row per fabric per stain type)
  - `Citations` (APA 7)
  - `Images`
- `tools/content/build_catalog.py` converts it to `assets/content/catalog.json` with a `contentVersion` (date + increment). It **fails the build** if any of these is true:
  - a required field is missing;
  - any care section has no citation;
  - `[PLACEHOLDER]` text is present (when run in `--release` mode);
  - fabric IDs don't match `assets/model/labels.txt` (the `not_fabric` label is excluded from this check);
  - an image file is missing.
- The app loads `catalog.json` once at startup into memory (about 18 fabrics, so it's small).

**Later:** an optional Firestore `content/` override for updates between builds.

## Consequences
- Changing content means a new build but **no code change**, which meets the constraint.
- Spreadsheet column names become the contract. Template is in `tools/content/README.md`.
- The PRD's "single place to edit" for P4 is satisfied.
