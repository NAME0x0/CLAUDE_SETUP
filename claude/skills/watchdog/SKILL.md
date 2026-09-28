---
name: watchdog
description: Background quality watchdog — runs the project's tests and lint on an interval via /loop and reports only new failures or regressions against a baseline. Use when asked to "watch the tests", "watchdog", "keep tests green while I work", or during long refactoring sessions.
---

# Watchdog

Silent while green. Speaks only on regression.

## Setup (first run)

1. **Detect commands** — in priority order: `justfile` recipes, `package.json` scripts (`test`, `lint`), `cargo test` + `cargo clippy`, `pytest` + `ruff`, `go test ./...`. Confirm the detected pair with the user once.
2. **Baseline** — run both now. Record pass/fail per test and lint warning count to `.watchdog-baseline.json` (scratchpad if repo shouldn't be touched). Report the starting state once.

## Loop

Run via `/loop` (self-paced) or a fixed interval the user names:

1. Each wake: run tests + lint.
2. Diff against baseline: new failures, newly passing (update baseline), lint delta.
3. **Report only changes.** All green and unchanged → stay silent (or one-line heartbeat if the user asked for it).
4. New failure → report: test name, error output (quoted exactly), most recent commits/edits touching related files (`git diff --stat` since last wake) as suspects. Do NOT auto-fix — the user is mid-work; fixing under them causes conflicts.
5. Stop on "stop watchdog" or when the user starts /ship.

## Notes

- Prefer `watchexec`-style file-triggered runs over fixed intervals when watchexec is available; fall back to /loop cadence.
- Keep runs cheap: affected-file test filtering where the runner supports it.
