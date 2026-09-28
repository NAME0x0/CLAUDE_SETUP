---
name: deep-dive
description: Read-only repository audit — what the project is, how it actually works, whether it's feasible, and what needs attention next. Makes NO edits; ends in consultation. Use when asked to "go through this repo", "deep dive", "what is this project", "is this feasible/plausible", "be honest about this", or when assessing an abandoned or unfamiliar codebase.
---

# Deep Dive

Read-only audit. **Hard rule: no Edit, no Write, no state changes.** The deliverable is an assessment, and it ends with consultation — never with fixes.

## Procedure

1. **Survey** — directory tree, README/docs, manifests (package.json / Cargo.toml / pyproject), entry points, CI config, last 20 commits (`git log --oneline -20`). Establish: what does this claim to be, and when was it last alive?
2. **Claims vs reality** — every capability the docs/specs claim, verify against code: implemented, stubbed, or missing. Grep for TODO/FIXME/unimplemented/panic/pass-only functions. List discrepancies explicitly.
3. **Feasibility research** — for novel claims (especially AI/ML architectures): do NOT rely on training memory. Web-research current state of the art (`mcp__free-search__research` or WebSearch). Compare the project's ambition against what its resources (compute, data, deps) can actually deliver. Be honest — a kind "this cannot work as specced because X" beats polite vagueness.
4. **Risk ranking** — rank findings by (probability wrong × cost × detection delay). Lead with the finding that changes the project's direction, not the most interesting one.
5. **Report** — in this order:
   - One-paragraph verdict: what it is, its state, feasibility call.
   - Discrepancy list (spec says / code does).
   - Feasibility assessment with every claim labeled **verified** (checked here) / **inferred** / **assumed**.
   - Top 3–5 next steps, effort-ranked.
6. **Consult** — present findings via AskUserQuestion for direction (fix / rescope / archive / continue). Do not proceed to changes without an explicit answer.

## Notes

- If repo is large, delegate breadth search to the Explore agent; keep synthesis here.
- Honesty override: if the user asks "is this feasible", the answer they need may be "no" — say it with evidence, not hedging.
