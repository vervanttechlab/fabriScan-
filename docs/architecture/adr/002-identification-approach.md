# ADR-002 — Fabric identification: on-device image classifier

**Status:** Accepted (2026-11-16) · **Traces to:** R2, F3, N2, N3, N4, PRD §9

## Context
The app identifies about 18 modern dress fabrics from a phone photo. Requirements: offline is preferred (Q6), no per-scan cost (free app), guest photos never leave the phone (N4), result within 5 s (N2), and a **method that can be defended in the thesis**, with reproducible accuracy figures and a confusion matrix.

## Options
| Criterion | (a) On-device classifier (transfer learning → TFLite) | (b) Cloud vision / multimodal LLM API | (c) Hybrid |
|---|---|---|---|
| Accuracy on look-alikes (piña vs jusi) | Learns from the researchers' own samples; best chance on *these* fabrics | General knowledge; weak on regional fabrics; results vary | Best in theory |
| Offline | ✅ | ❌ | Partly |
| Cost per scan | ₱0 | About ₱0.30–₱1.50 per scan, plus a backend to hide the API key | Both |
| Privacy | Photo stays on the phone | Photo is uploaded to a third party | Mixed |
| Latency | About 0.1–0.5 s inference | 2–8 s, depends on the network | — |
| Thesis defensibility | Clear method (dataset → training → test-set metrics) | "We asked an API". Hard to explain why it got something wrong | Complex to explain |
| Effort | Dataset + training (the researchers can do this) | Low code effort, but needs a backend | Highest |

## Decision
**(a) On-device classifier.** Transfer learning from an ImageNet-pretrained **EfficientNet-Lite0 or MobileNetV3-Large** (the better scorer in `ml-plan.md` wins), exported as **TFLite (float16)**, about 5–10 MB, bundled with the app.

The classes are the **fabric IDs plus one `not_fabric` class**. Fiber versions (silk vs polyester satin) are **not** separate classes; the result shows every version from the catalog (PRD §6, US-15).

To make results steadier, each scan runs the model on **5 crops of the photo** (center plus 4 corners) and averages the scores. This costs well under 1 s on a mid-range phone.

**Re-evaluate the hybrid option (c) Later**, only if on-device accuracy misses the PRD target after the dataset is complete.

## Consequences
- Accuracy depends entirely on the dataset the researchers collect (ADR-003). This is project risk #1.
- A model update means a new app build (the model ships with the app). That's acceptable for a thesis; remote model download is Later.
- No server is involved in scanning, so a demo can't fail because of the network.
