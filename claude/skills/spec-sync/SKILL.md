---
name: spec-sync
description: Diff specs/docs against actual code and report discrepancies — spec claims not implemented, code not documented, contradictions, stale docs. Loopable via /loop or /schedule for recurring automated runs. Use when asked to "check the specs", "spec sync", "find discrepancies", or "does the code match the docs".
---

# Spec Sync

Compare what the documents promise against what the code does. Report; fix only on request.

## Procedure

1. **Locate spec sources** — `specs/`, `docs/`, `README.md`, `ARCHITECTURE.md`, design docs, `*.md` with requirement language ("must", "shall", "will support").
2. **Extract testable claims** — each claim gets an ID, the source file:line, and a check strategy (grep for the API, read the module, run the test).
3. **Verify each claim** against code. Classify: `IMPLEMENTED` / `PARTIAL` (stubbed, TODO'd) / `MISSING` / `CONTRADICTS` (code does something else) / `UNDOCUMENTED` (code feature absent from specs).
4. **Report** — table: claim | source | status | evidence (file:line). Severity-sorted: CONTRADICTS first (these mislead), then MISSING, PARTIAL, UNDOCUMENTED. End with counts and a one-line drift verdict.

## Loop mode (automation)

- Persist state to `.spec-sync-state.json` in the repo root (claim IDs + last status + content hashes of spec files).
- On repeat runs: re-check only claims whose spec or implementing files changed since last state; report **deltas only** (new drift, resolved drift).
- Recurring: `/loop 30m /spec-sync` during active spec work, or a nightly `/schedule` routine for long-running projects.
- Never edit specs or code in loop mode — report only.
