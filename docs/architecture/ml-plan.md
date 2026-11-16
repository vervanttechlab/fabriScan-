# FabriSCAN+ — ML Plan (dataset, training, evaluation)

**Status:** DRAFT until the fabric list (Q1–Q3) and dataset owner (Q4) are confirmed · 2026-11-16
**Decisions:** ADR-002 (on-device classifier), ADR-003 (pipeline), ADR-004 (thresholds)

---

## 1. Classes
- One class per **unique fabric ID** in `fabric-catalog.md` (currently 18), plus **`not_fabric`**, for **19 classes** in total.
- Fiber versions (e.g. silk vs polyester satin) are **one class**.
- The order of classes is fixed in `labels.txt`. It must match `catalog.json`, and the content validator checks this.

## 2. Dataset protocol (for the researchers)

### 2.1 Physical samples
| | Minimum | Target |
|---|---|---|
| Different physical samples per fabric (different source, colour or batch) | 3 | **5** (and **≥ 6 for Piña, Piña-seda, Jusi, Organza**) |
| Photos per sample | 50 | 60–80 |
| Photos per fabric (total) | 150 | **300+** |
| `not_fabric` photos (floors, walls, skin, paper, plastic, phone screens, food) | 300 | 500 |

Include variety on purpose: different colours of the same fabric, plain and printed or embroidered pieces (e.g. a barong body vs its embroidered panel), and **fabric on real garments** as well as flat swatches.

### 2.2 Capture checklist (print this)
- [ ] **Phones:** at least 3 different phones (≥ 2 Android, including a budget one, + 1 iPhone if available)
- [ ] **Lighting:** for each sample, ~⅓ in daylight near a window, ~⅓ under indoor LED/fluorescent light, ~⅓ in mixed or dim light. **No flash.**
- [ ] **Distance:** ~half at 10–15 cm (close texture), ~half at 25–30 cm (drape/sheen)
- [ ] **Angles:** straight on, about 30° tilted, and a folded or draped view
- [ ] **Background:** fabric fills at least 80% of the frame. If it's sheer (organza, piña, tulle), shoot it over **both** a light and a dark background
- [ ] **Focus:** retake blurry shots. Keep a few slightly soft ones (real users take them)
- [ ] Default camera app, no filters, JPEG

### 2.3 File naming & folders
```text
dataset/
  FAB-PINA/
    S01/  FAB-PINA_S01_phoneA_day_close_001.jpg ...
    S02/
  ...
  not_fabric/
    S01/ ...
dataset/metadata.csv   # file, fabric_id, sample_id, phone, light, distance, background, notes
```
`sample_id` is **the split key**: one row per physical piece of cloth. Keep a photo log of each physical sample (where it was bought or sourced, and its claimed fiber content) for the thesis methodology chapter.

## 3. Splits (by physical sample, never by photo)
For each fabric:
- **Test:** 1 sample (2 if the fabric has ≥ 6). Kept aside until the final evaluation.
- **Validation:** 1 sample. Used to tune training settings, temperature and thresholds.
- **Train:** the remaining samples.

The split is recorded in `tools/ml/splits.csv` and versioned. **Never reshuffle after you've seen the test results.**

## 4. Training (Keras on Google Colab, free GPU)
Notebook: `tools/ml/train_fabric_classifier.ipynb` (step-by-step, runnable from top to bottom).
1. Load the dataset from Google Drive and apply `splits.csv`.
2. **Backbones to compare:** EfficientNet-Lite0 and MobileNetV3-Large (ImageNet weights), input 224×224.
3. **Augmentation (train only):**
   - random crop of 60–100% of the area, then resize
   - horizontal and vertical flip, rotation ±20°
   - brightness/contrast ±20%, slight hue/saturation jitter
   - slight Gaussian blur
   - *No heavy colour changes*: colour can be a clue (natural piña is ecru).
4. **Stage 1:** freeze the backbone and train the classifier head (≈ 15 epochs, Adam 1e-3, label smoothing 0.1, class weights if classes are unbalanced).
5. **Stage 2:** unfreeze the top ~30% of the backbone and fine-tune (≈ 20 epochs, 1e-5, stop early on validation loss).
6. **Calibration:** fit the temperature T on the validation set, then pick `t_high`, `t_low` and `margin` on the validation set (ADR-004). Goal: state A has ≥ 95% precision on the validation set.
7. **Export:** TFLite float16, plus `labels.txt` and `model_meta.json`. Also try an int8 version: keep it only if accuracy drops by ≤ 1 point.
8. **Check on the phone:** run the test images through the same Dart preprocessing used in the app (`tools/ml/parity_check`). The app's scores must match the notebook's within ±0.02.

**Week-1 feasibility spike (before the full dataset):** Teachable Machine with ~50 photos per fabric of Piña, Piña-seda, Jusi, Organza and Satin, using one sample held out. If held-out accuracy on this trio is below ~50%, tell the PM immediately (options: more samples, close-up "macro" capture guidance, or merging look-alikes into one "Piña / Piña-seda" result that shows both care guides).

## 5. Evaluation (what goes in the thesis)
All numbers are on the **test set of unseen physical samples**, unless a number is labelled "seen-sample".

| Metric | Target (proposed, Q18) |
|---|---|
| Top-1 accuracy (overall) | ≥ 75% |
| Top-3 accuracy (overall) | ≥ 90% |
| Top-1 accuracy per category | ≥ 70% (documented exceptions for look-alikes) |
| State A precision (when the app says "High match", how often it's right) | ≥ 95% |
| `not_fabric` recall | ≥ 90% |
| How often each state appears (A / B / C) | reported |
| Inference latency (p50/p95) on the reference devices | p95 ≤ 2.5 s mid-range, ≤ 5 s budget |

Also report:
- per-class precision, recall and F1
- the **confusion matrix** (19×19, as a figure)
- a reliability diagram before and after calibration
- example failure cases

The notebook generates `tools/ml/reports/<modelVersion>/` with all figures and a `summary.md`.

## 6. Model updates
1. Add photos or samples; keep the test samples fixed (unless new *test* samples are added, which counts as a new test-set version).
2. Retrain → evaluate → **gate: the new model must not be worse than the current one** on test top-1 or state-A precision.
3. Increase `modelVersion` (`fc-YYYYMMDD-N`), copy the 3 asset files to `assets/model/`, update the content validator, and make a new app build.
4. History records keep the `model_version` that produced them.

## 7. Dataset ethics & storage
- Photos are of fabric only, with no people's faces. Crop or remove any photo where a face appears.
- The dataset is stored in a shared Google Drive owned by the research group. It is **not** committed to git; only `splits.csv`, `metadata.csv` and the reports are versioned.
