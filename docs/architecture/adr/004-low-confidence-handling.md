# ADR-004 — Low-confidence & out-of-scope handling

**Status:** Accepted (2026-11-16) · **Traces to:** PRD §6, US-12–US-15, Q5, Q15

## Context
The PRD defines three result states: A Confident, B Unsure, C Can't identify. Raw softmax scores from a neural network tend to be overconfident, so the thresholds need to be calibrated. Users will also scan things that aren't fabric, or fabrics outside the catalog.

## Options
- Fixed thresholds on the raw softmax only (simple; overconfident).
- Thresholds after **temperature scaling** (one parameter, fitted on the validation set).
- Separate out-of-distribution detector (energy score / second model): more accurate, more work.
- Ask the user to "pick a category first" to narrow the classes: more accurate, but adds a step and hurts ease of use (TAM).

## Decision
1. Apply **temperature scaling** (temperature fitted on the validation set, stored in `model_meta.json`).
2. A pure-Dart **`DecisionPolicy`** maps the averaged 5-crop scores to a state:
   - `not_fabric` is the top class, **or** top-1 < `t_low` → **C**
   - top-1 ≥ `t_high` **and** (top-1 − top-2) ≥ `margin` → **A**
   - otherwise → **B**, showing the top 3 fabrics (the `not_fabric` class is never shown)
3. Defaults: `t_high = 0.80`, `t_low = 0.50`, `margin = 0.15`. These live in `model_meta.json`, are chosen on the validation set, and are checked on the test set. Reported in the thesis.
4. **No "pick category first" step** in the MVP. Revisit only if accuracy misses the target. If added later, it would be optional and filter the classes.
5. A separate out-of-distribution detector is **Later**; the `not_fabric` class plus `t_low` is enough for the MVP.

## Consequences
- The thresholds are data, not code, so they can be retuned without a code change.
- `DecisionPolicy` is 100% unit-testable with fixed score vectors.
