---
name: progress
description: Project completion report — how close is this project to done, with evidence. Synthesizes git history, TODOs, specs/roadmap checklists, and test state into a status breakdown and estimate. Use when asked "how close are we to completion", "project status", "what's left", "where did we leave off".
---

# Progress

Answer first: a completion estimate and the single biggest remaining blocker. Then evidence.

## Procedure

1. **Gather (parallel):**
   - `git log --oneline -30` + commit dates → velocity and last-active date.
   - Grep `TODO|FIXME|HACK|unimplemented|not.?implemented` → open-work inventory.
   - Roadmap/spec/README checklists → declared scope (checked vs unchecked).
   - Run tests if cheap → pass rate; else count test files vs source modules.
   - Stub detection: empty function bodies, `pass`, `todo!()`, placeholder returns.
2. **Bucket every scope item:** DONE (verified working) / IN PROGRESS (code exists, incomplete) / NOT STARTED / UNKNOWN (can't verify cheaply). Never guess an item into DONE — unverified means UNKNOWN.
3. **Estimate** — percentage from bucket weights, explicitly labeled **inferred**. State what the estimate is sensitive to (e.g., "assumes specs list full scope").
4. **Report:**
   - Verdict line: "~N% complete; blocker: X."
   - Bucket table with counts and the items in each.
   - Top 5 remaining items, effort-ranked, with the recommended next single step.
   - Risk note: what wasn't verifiable and how that could move the number.

## Notes

- Abandoned projects: lead with "what state was this left in" before percentages.
- If scope is undeclared (no roadmap/specs), say so — offer /spec-sync or writing a roadmap as the real next step.
