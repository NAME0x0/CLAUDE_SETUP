# CLAUDE_SETUP

A complete, portable Claude Code setup: global instructions, a reasoning manual,
settings and hooks, 73 skills, 10 plugins, 5 MCP servers, the gstack browser
toolkit, the fast CLI tools the instructions rely on, and Codex CLI as a
second executor. One command installs all of it on a new machine.

Nothing personal ships in this repo: no API keys, tokens, logins, memory,
chat history or machine-specific paths. Those are set up per user after install.

## Install

Run one command in a normal (non-admin) terminal.

**Windows** (PowerShell):

```powershell
irm https://raw.githubusercontent.com/NAME0x0/CLAUDE_SETUP/main/bootstrap.ps1 | iex
```

**macOS / Linux**:

```bash
curl -fsSL https://raw.githubusercontent.com/NAME0x0/CLAUDE_SETUP/main/bootstrap.sh | bash
```

The bootstrap downloads this repo to `~/.claude-setup` and runs the installer.
It installs Claude Code too if it is missing. Expect 5–15 minutes on a fresh
machine; most of that is package downloads and the gstack browser build.

**Or let Claude do it.** If Claude Code is already installed, start it and paste:

> Set up my machine from https://github.com/NAME0x0/CLAUDE_SETUP. Read its README and follow the "Instructions for Claude" section exactly.

### Finish by hand (about 5 minutes)

The installer prints this list at the end. These steps need you, because they
involve logging in or creating your own tokens:

1. Open a **new** terminal (PATH changed), run `claude` and log in.
2. In Claude Code, run `/mcp` and authenticate the **github** and **figma** servers.
3. Run `codex login`, then `/codex:setup` inside Claude Code to confirm it works.
4. For the **free-search** MCP server, get a free Puter token:
   `cd ~/.claude/mcp-servers/free-search && npm run get-token`, then save it as a
   user environment variable named `PUTER_AUTH_TOKEN`:
   - Windows: `[Environment]::SetEnvironmentVariable('PUTER_AUTH_TOKEN','<token>','User')`
   - macOS/Linux: add `export PUTER_AUTH_TOKEN=<token>` to `~/.zshrc` or `~/.bashrc`
5. Optional: install Rust (`rustup`) and run `rustup component add rust-analyzer`
   so the rust-analyzer plugin can work.

## What you get

**Instructions** (`~/.claude/`)
- `CLAUDE.md` — global rules: operating principles, response style, search conduct,
  token efficiency, workflow pipelines (which skill to use when), and a table of
  fast CLI tools to prefer over slow built-ins.
- `INSTRUCT.md` — the full reasoning manual the principles in `CLAUDE.md` condense.
- `~/.codex/AGENTS.md` — the same rules adapted for Codex CLI.

**Settings** (merged into `~/.claude/settings.json`, never blindly overwritten)
- Opus as the default model, extended thinking on, high effort (xhigh on Opus 5.5).
- A SessionStart hook that loads the **fable-gpt** workflow: Claude plans and
  reviews, Codex does heavy implementation, and Claude asks you which Codex model
  and effort to use before spending Codex quota.
- A status line showing user, directory, git state, model, context use, tokens,
  CPU/RAM and an ETA. The CPU/RAM part reads Windows counters, so it shows `?` on macOS/Linux.
- Pre-approved permissions for the codex and free-search MCP tools.

**Plugins** (installed from their marketplaces)
superpowers, frontend-design, claude-md-management, agent-sdk-dev,
rust-analyzer-lsp, huggingface-skills, vercel (all from the official
marketplace), caveman (terse responses), codex (OpenAI Codex bridge),
diagram-design.

**MCP servers** (user scope)
context7 (library docs), github, figma, codex (Codex as an MCP tool), and
free-search (Perplexity search through Puter, free with a Puter account).

**Skills**
- *Workflow*: `fable-gpt`, `deep-dive`, `progress`, `spec-sync`, `watchdog`, `karpathy-guidelines`
- *Code quality*: `code-review`, `lint-and-fix`, `test-runner`, `refactor-suggester`, `dead-code-purger`, `bug-reproducer`, `performance-profiler`, `logging-scaffolder`
- *Security and compliance*: `secrets-guardian`, `dependency-audit`, `license-compliance`, `cso`, `careful`, `guard`, `freeze`, `unfreeze`
- *Scaffolding and docs*: `repo-from-idea`, `feature-scaffold`, `ci-generator`, `docker-architect`, `environment-manager`, `database-migrator`, `mock-data-factory`, `schema-visualiser`, `api-spec-generator`, `readme-and-docs`, `changelog-automator`, `doc-convert`, `implement-paper`, `free-api-prototype`, `internationalisation-checker`
- *Design and frontend*: `design`, `design-to-ship`, `ui-ux-prototype`, `accessibility-auditor`, `tailwind-design-system`, `shadcn`, `react-spring-physics`, `code-to-canvas`, `logo-generator`
- *gstack suite* (browser QA, reviews, shipping): `gstack`, `qa`, `ship`, `land-and-deploy`, `canary`, `benchmark`, `autoplan`, `office-hours`, `plan-ceo-review`, `plan-eng-review`, `plan-design-review`, `design-review`, `design-consultation`, `design-shotgun`, `design-html`, `document-release`, `retro`, `learn`, `codex`, `connect-chrome`, `setup-browser-cookies`, `setup-deploy`, `gstack-upgrade`
- *Other*: `humanizer`, `llm-evaluation`, `rust-best-practices`, `find-skills`
- *Commands*: `/subagent-catalog:search`, `:list`, `:fetch`, `:invalidate` (browse the VoltAgent subagent catalog)

gstack's `browse`, `investigate`, `qa-only` and `review` skills are left out on
purpose; other skills above cover them. Running `/gstack-upgrade` may bring them
back, and you can delete them again from `~/.claude/skills/`.

**CLI tools** (scoop on Windows, Homebrew on macOS/Linux; tools already present are skipped)
ripgrep, ripgrep-all, fd, fzf, bat, eza, jq, yq, sd, ast-grep, delta,
difftastic, just, xh, choose, xsv (Windows only), miller, watchexec, mprocs,
pueue, procs, bottom, dust, gdu, duf, tokei, hyperfine, fclones, zoxide,
lazygit, atuin, direnv, mise, sccache, jqp, broot, cargo-binstall, starship,
less, bun, uv, pandoc, poppler, plus git, GitHub CLI and Node.js LTS.
On Homebrew, gdu installs as `gdu-go`.

## What is not included

- Secrets of any kind: API keys, OAuth logins, the Puter token, GitHub/Figma auth.
- Personal memory, chat history, session logs and usage stats.
- Project-specific permissions and MCP servers.
- The Anthropic document skills (docx, pptx, xlsx, pdf and others). They come
  with a claude.ai account and appear automatically once you log in.
- Plugins the original setup had installed but disabled.

## Installer options

Run the installer directly from `~/.claude-setup` to pass flags.

| Windows (`install.ps1`) | macOS/Linux (`install.sh`) | Skips |
|---|---|---|
| `-SkipTools` | `--skip-tools` | CLI tool installs |
| `-SkipClaudeInstall` | `--skip-claude-install` | Installing Claude Code |
| `-SkipGstack` | `--skip-gstack` | gstack clone and build |
| `-SkipPlugins` | `--skip-plugins` | Plugin marketplaces and plugins |
| `-SkipMcp` | `--skip-mcp` | MCP servers |
| `-SkipCodex` | `--skip-codex` | Codex CLI and `~/.codex/AGENTS.md` |

`CLAUDE_CONFIG_DIR` and `CODEX_HOME` are respected if you use them.

## Safety and re-running

- Every file or folder the installer replaces is copied first to
  `~/.claude/backups/claude-setup-<timestamp>/`. To undo, copy things back from there.
- `settings.json` is merged: your existing keys, permissions and hooks stay;
  this setup's values win only where both define the same setting.
- Skills with the same name as one of yours are replaced (and backed up). Skills
  with other names are untouched.
- MCP servers you already have under the same name are left as they are.
- `~/.codex/config.toml` is only created if missing.
- Re-running is safe; it converges to the same result.
- On Windows the installer enables git long paths only for its own process
  (via `GIT_CONFIG_*` variables), because one plugin marketplace has paths
  longer than 260 characters. Your git config is not changed.

## Instructions for Claude

You are setting up this environment on a new machine for the user. Follow these
steps in order, and report honestly what worked and what didn't.

1. **Check the platform.** Windows uses PowerShell and `install.ps1`; macOS and
   Linux use bash and `install.sh`. On Linux, Homebrew needs `build-essential`,
   `curl`, `file` and `git` first (`sudo apt install build-essential curl file git`
   on Debian/Ubuntu); ask the user to run that if they are missing, since it needs sudo.
2. **Get the repo.** If it is not already on disk, download it:
   - Windows: `irm https://raw.githubusercontent.com/NAME0x0/CLAUDE_SETUP/main/bootstrap.ps1 | iex`
   - macOS/Linux: `curl -fsSL https://raw.githubusercontent.com/NAME0x0/CLAUDE_SETUP/main/bootstrap.sh | bash`

   The bootstrap runs the installer immediately. If you already have a copy, run
   `./install.ps1` or `./install.sh` from its root instead. Because Claude Code is
   already running, you may pass `-SkipClaudeInstall` / `--skip-claude-install`.
3. **Run it with a long timeout** (15 minutes) or in the background. Do not run it
   as Administrator/root; scoop and Homebrew refuse or misbehave under elevation.
4. **Read the summary** at the end: the Warnings list and the "Finish by hand" list.
   For each warning, use the troubleshooting table below, fix the cause, and
   re-run only the affected part (the other steps are skipped with flags).
5. **Verify**, and show the user the results:
   - `claude plugin list` shows 10 plugins, all enabled.
   - `claude mcp list` shows context7, github, figma, codex and free-search.
     github and figma need login; free-search fails until `PUTER_AUTH_TOKEN` is set.
   - `~/.claude/skills/` contains 73 skill folders (more if the user had their own).
   - `jq . ~/.claude/settings.json` parses, and has `statusLine` and `hooks.SessionStart`.
   - A few tools answer: `rg --version`, `fd --version`, `jq --version`, `bun --version`.
6. **Hand over the manual steps.** Walk the user through each "Finish by hand"
   item. Never ask the user to paste a token or password into the chat; they
   should type tokens only into their own terminal or browser.
7. **Tell the user to restart Claude Code.** New skills, plugins, hooks and the
   status line load at session start. After restarting, the fable-gpt hook runs
   first and caveman mode is on (say "normal mode" to turn it off).

### Troubleshooting

| Symptom | Fix |
|---|---|
| `Filename too long` while adding a plugin marketplace (Windows) | The installer already sets git long paths for itself. If you add marketplaces by hand later, run `git config --global core.longpaths true` first. |
| Marketplace add fails with an SSH `Permission denied (publickey)` | Add it by HTTPS: `claude plugin marketplace add https://github.com/<owner>/<repo>.git` |
| `gstack skipped: 'bun' not found` | Install bun (`scoop install bun` / `brew install bun`), then re-run with every other step skipped, or run `cd ~/.claude/skills/gstack && ./setup --no-prefix`. |
| gstack setup fails on Windows launching Chromium | Node.js must be installed; gstack uses Node, not bun, to drive Playwright on Windows. |
| `scoop` refuses to install | Don't run as Administrator. The installer passes `-RunAsAdmin` when elevated, but a normal shell is better. |
| Tools installed but "command not found" | Open a new terminal; PATH updates only apply to new shells. |
| `npm install -g` permission error on Linux | Use Homebrew's node (`brew install node`) or configure an npm prefix in your home folder. |
| free-search shows as failed in `/mcp` | `PUTER_AUTH_TOKEN` is not set in the environment Claude Code was started from. |

## Repo layout

```
bootstrap.ps1 / bootstrap.sh   one-command download + install
install.ps1 / install.sh       the installers (Windows / macOS+Linux)
claude/
  CLAUDE.md  INSTRUCT.md       global instructions and reasoning manual
  settings.template.json       settings merged into ~/.claude/settings.json
  statusline-command.sh        status line script
  skills/                      bundled skills
  commands/subagent-catalog/   slash commands
  mcp-servers/free-search/     free-search MCP server (dependencies installed by npm)
codex/
  AGENTS.md                    Codex CLI rules
  config.example.toml          starter Codex config
manifest/
  plugins.json  mcp.json       marketplaces, plugins and MCP servers
  tools.json                   CLI tools per package manager
  remote-skills.json           skills fetched from their authors at install time
  merge-settings.jq            how settings are merged
```

## Credits

Several skills come from open-source projects, mainly
[gstack](https://github.com/garrytan/gstack) by Garry Tan. Sources and license
notices are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
