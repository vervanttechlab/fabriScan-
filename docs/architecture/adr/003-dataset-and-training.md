# ADR-003 — Dataset & training pipeline

**Status:** Accepted, pending the client's fabric list (Q1–Q4) · **Traces to:** F3, PRD §9, US-61

## Context
The classifier needs a dataset from real physical samples. The researchers are textile experts, not ML engineers, so the process must be a checklist they can follow and a notebook they can run.

## Options
1. **Google Teachable Machine:** no code; exports TFLite. Little control over splits and metrics, and no confusion matrix per held-out physical sample.
2. **Keras notebook on Google Colab (free GPU):** full control, reproducible, and produces the metrics the thesis needs.
3. Paid AutoML (Vertex AI): costs money and does nothing extra for this project.

## Decision
- **Feasibility spike (week 1):** Teachable Machine with about 50 photos per fabric for 4–5 of the hardest fabrics (Piña, Piña-seda, Jusi, Organza, Satin). This tells us early whether the look-alikes can be separated at all.
- **Real pipeline:** a **Keras notebook on Colab**, versioned in `tools/ml/`.
- **Split by physical sample, not by photo.** Photos of the same piece of cloth must never appear in both the training set and the test set. Splitting by photo inflates accuracy and would not survive a defense.
- Full protocol, minimum counts and metrics: `ml-plan.md`.

## Consequences
- The researchers need **at least 3, ideally 5, different physical samples per fabric**. This is a client commitment (Q4).
- The fabric list must be frozen before final training (Q1–Q3).
- A labels file connects the model's output classes to the catalog. A content-validation script checks the two match exactly (ADR-006).
