---
name: fable-gpt
description: Use at the start of every session in this workspace, and whenever a task involves heavy implementation, debugging, test fixing, refactoring, or multi-file code edits — before writing implementation code directly.
---

# Fable-GPT — Orchestrator/Executor Workflow

## Overview

Two-brain split. **You (the Claude orchestrator — works the same whether you are
Fable 5, Opus 4.8, or any other Claude model)**: planning, repo understanding,
architecture decisions, task decomposition, final review. **Codex = executor**:
heavy implementation under your direction. You own correctness; Codex owns keystrokes.

## Role Split

| Work | Who |
|---|---|
| Planning, architecture, task decomposition | Orchestrator (you) |
| Repo understanding, research, spec writing | Orchestrator |
| Heavy implementation, multi-file edits | Codex via `/codex:rescue` |
| Debugging grinds, test fixing, refactoring | Codex via `/codex:rescue` |
| Final review, acceptance, commit | Orchestrator — always |

Small edits (one file, few lines, config tweaks): do directly. Delegation
overhead must be smaller than the task.

## Model & effort — ASK FIRST (Codex quota is limited)

Before the FIRST Codex delegation of a session, ask the user via AskUserQuestion
(never assume — Codex usage is metered and must not be burned silently):

1. **Codex model** — e.g. `gpt-5.5-codex` (strongest, most quota) vs
   `gpt-5.1-codex` / `-mini` (cheaper for routine grinds). Recommend based on
   task difficulty, but the user decides.
2. **Reasoning effort** — `xhigh` / `high` / `medium` / `low`. Recommend the
   lowest effort the task can tolerate; xhigh only for genuinely hard work.

Remember the answer for the rest of the session; re-ask only if task difficulty
changes class (trivial grind → hard debugging, or vice versa) or the user asks
to switch. If the user gave model+effort in their message, use that — no question.

## Delegating

1. Delegate via the `codex:rescue` skill (or `codex:codex-rescue` agent for
   background runs), passing the user-chosen model and effort
   (`-m <model>`, `model_reasoning_effort=<effort>`).
2. One focused task per delegation: exact files, exact acceptance criteria,
   exact constraints. Never "improve the codebase".
3. Long-horizon work: pair with a goal/task list; give Codex one rung at a time.
4. Parallel Codex subagents are allowed for independent tasks (user runs a
   high-quota plan); never two agents on the same files. Warn before parallel
   runs — they multiply quota burn.

## Acceptance — MANDATORY inspection

After Codex finishes, inspect before accepting:

1. Read the diff yourself (`git diff` / files changed) — every hunk.
2. Run the project's tests/lint yourself; do not trust Codex's claim that they pass.
3. Check the change matches YOUR spec, not Codex's reinterpretation of it.
4. Reject and re-delegate with a tighter brief, or fix by hand — never patch
   blind over a Codex change you don't understand.

**No exceptions:**
- Not because "Codex said tests pass"
- Not because "it's a big diff and reviewing takes long"
- Not because "Codex is usually right"
- Not because the session is almost over

| Excuse | Reality |
|---|---|
| "Codex output looks clean" | Looking ≠ reading. Read every hunk. |
| "Its tests passed" | Its claim. Run them yourself. |
| "Re-review wastes the speed gain" | One bad accepted diff costs more than every review combined. |

## Context hygiene

- After ~4 compactions, context rot sets in: summarize state, persist decisions
  to files/memory, suggest the user clear and continue fresh (handoff-style
  summary in a file if no handoff skill installed).
