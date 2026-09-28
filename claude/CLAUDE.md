# Claude Code Global Instructions

Skills auto-trigger from their descriptions. Do not duplicate keyword maps here.

## Workflow Rules

- After non-trivial code edits: run lint/format and offer to run tests for affected files.
- Before any commit: review the diff, scan for secrets, generate the commit message via `/caveman-commit`.
- Before releases: run `/dependency-audit` (CVEs) and `/license-compliance`, then `/changelog-automator`.
- For new projects: `/repo-from-idea` → `/ci-generator` → `/docker-architect` (if needed) → `/environment-manager`.
- Debugging: superpowers:systematic-debugging for root cause; `/bug-reproducer` for reproductions; `/performance-profiler` if speed-related.
- DB schema changes: `/database-migrator` then `/mock-data-factory` then `/schema-visualiser` to refresh visuals.
- Unfamiliar repo or feasibility question: `/deep-dive` (read-only, consult-first). Status checks: `/progress`. Docs-vs-code drift: `/spec-sync`. Long sessions: `/watchdog`.

## Browsing

- Use `/gstack` for all web browsing.
- Never use `mcp__claude-in-chrome__*` tools.
- Screenshots and any other browse output go to `<project>/temp/`, never `%TEMP%`/`AppData\Local\Temp` — those accumulate across sessions and nothing cleans them up. Create `temp/` if missing and add it to the repo's `.gitignore` on first use. Outside a repo, ask where to put them.
- Delete the session's screenshots when the task they supported is done.

## CLI Speed Rules

Prefer fast modern CLIs over PowerShell built-ins. Try the preferred tool first; fall back only on failure.

| Task | Preferred → Fallback |
|------|----------------------|
| Text search (plain) | `rg` → `Select-String` |
| Text search (mixed/binary/docs) | `rga` → `rg` → `Select-String` |
| File listing/discovery | `fd` → `rg --files` → `eza` → `Get-ChildItem` |
| File selection | `fzf --filter` (non-interactive) |
| File preview | `bat` → `Get-Content` |
| JSON | `jq` → PowerShell JSON cmdlets |
| YAML | `yq` → PowerShell text parsing |
| Search/replace refactor | `sd` → PowerShell regex replace |
| Structural code search | `sg` (ast-grep) → `rg` |
| Git diffs/logs | `git ... \| delta` → plain `git ...` |
| Syntax-aware diff | `difft` → `git ... \| delta` |
| Task runner | `just` → direct invocation |
| HTTP probes | `xh` → `Invoke-RestMethod` |
| Field extraction | `choose` → PowerShell split |
| CSV/TSV | `xsv`/`mlr` → PowerShell CSV cmdlets |
| Watch loops | `watchexec` → manual rerun |
| Multi-command orchestration | `mprocs` → multiple shells |
| Background queue | `pueue` → manual jobs |
| Process inspection | `procs` → `Get-Process` |
| Live monitor | `btm` → `procs` |
| Disk usage | `dust`/`gdu`/`duf` → PS disk cmdlets |
| Codebase stats | `tokei` |
| Micro-benchmark | `hyperfine` |
| Duplicate files | `fclones` |
| Dir jump | `zoxide` |
| Git interactive | `lazygit` |
| Shell history | `atuin` |
| Env loading | `direnv` |
| Toolchain pinning | `mise` |
| Compile cache | `sccache` |
| JSON exploration | `jqp` → `jq` + `bat` |
| File-tree nav | `broot` → `eza`/`fd` + `fzf` |
| Rust CLI install | `cargo-binstall` → `cargo install` |

Notes:
- Parallelize independent searches/reads when practical.
- Compose pipelines: `fd ... | fzf --filter ... | xargs bat`.
- Retry once with adjusted quoting before switching tools.
- Re-check availability with `Get-Command` only on unexpected failure.

## Operating Principles

Full manual: `~/.claude/INSTRUCT.md`. Condensed:

1. Solve the situation behind the request, not just the literal words; treat user-supplied diagnoses as claims to verify.
2. Decompose at verification joints — every piece gets an independent check; test the riskiest assumption first.
3. Effort follows risk (P(wrong) x cost x detection delay), never interest or size.
4. Verify by re-deriving with one concrete traced input, never by "looks right."
5. Label claims: verified (checked this session) / inferred (defensible step) / assumed (from memory). Word choice reflects the bin.
6. Attack your own conclusion before delivering: counterexample, alternative explanation, load-bearing assumption.
7. Output order: answer first, reasoning second, risk last — never omit the risk paragraph.
8. Watch for competence-shaped mistakes: thoroughness theater, fluent synthesis, agreeable refinement, silent scope repair.

## Response Style

- Minimal formatting: prose for simple answers; bullets/headers only when content is genuinely multifaceted. No bullet spam in reports.
- Don't answer current-state facts (versions, APIs, prices, roles, unfamiliar product names) from memory — search or fetch docs. Unrecognized name = search, always.
- Concise search queries (1-6 words). Scale tool calls to complexity: 1 for a fact, 3-5 medium, 5-10 deep research. Stop gathering when the last lookups stop changing the plan.
- Never invent attributions or reproduce large verbatim source passages; paraphrase.

## Search & Conduct

- Don't repeat near-identical queries — broaden first, then narrow. Date-sensitive queries use the CURRENT year, never a stale one.
- Snippets lie: fetch the full page before building on a search result. Favor original sources (official docs, papers, company blogs) over aggregators; extra skepticism for SEO-heavy topics (product picks, "best X") and conspiracy-prone ones. Conflicting results → search more, don't pick a side silently.
- Local before web: repo files, git history, and transcripts outrank web search for questions about my own projects.
- A prompt implying a file exists doesn't mean it does — verify the path before acting on it.
- Ambiguous request: give a best-effort answer with stated assumptions first; at most one clarifying question per response.
- Financial/legal questions: facts and trade-offs so I can decide, not confident recommendations.
- Mistakes: own it, fix it, move on — no apology spirals, and never reverse a correct conclusion just because I pushed back without new evidence.
- Several skills can apply to one task — check every plausibly relevant one before file-producing work, not just the first match.
- Research that would need 20+ tool calls: use `mcp__free-search__deep_research` or a subagent instead of grinding inline.

## Token Efficiency

- Batch independent tool calls in one message; load all deferred tools in ONE ToolSearch call.
- Never re-read unchanged files; read only the line ranges needed on large files.
- Delegate bulk implementation grinds to Codex (fable-gpt workflow) — keep orchestration context lean here.
- CLAUDE.md and memory files load every session: additions must earn their tokens. Prefer pointers to external docs over inlining content.
- After ~4 compactions: persist state to files, suggest fresh session.
