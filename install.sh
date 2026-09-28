#!/usr/bin/env bash
# Installs the shared Claude Code setup on macOS or Linux: CLI tools (Homebrew),
# Claude Code, instructions, settings, skills, gstack, plugins, MCP servers and
# Codex CLI. Safe to re-run; anything replaced is copied first to
# ~/.claude/backups/claude-setup-<timestamp>/.
#
# Usage: ./install.sh [--skip-tools] [--skip-claude-install] [--skip-gstack]
#                     [--skip-plugins] [--skip-mcp] [--skip-codex]
#
# Written for bash 3.2 (stock macOS): no mapfile, no `set -u`.
set -o pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$CLAUDE_DIR/backups/claude-setup-$STAMP"

GSTACK_REPO="https://github.com/garrytan/gstack.git"
GSTACK_REF="7ea6ead9fa88ba439002a6dc1d7409649b45e9f5"
# gstack skills this setup deliberately leaves out (duplicates of other skills).
GSTACK_ARCHIVED="browse investigate qa-only review"

SKIP_TOOLS=0; SKIP_CLAUDE=0; SKIP_GSTACK=0; SKIP_PLUGINS=0; SKIP_MCP=0; SKIP_CODEX=0
for arg in "$@"; do
  case "$arg" in
    --skip-tools) SKIP_TOOLS=1 ;;
    --skip-claude-install) SKIP_CLAUDE=1 ;;
    --skip-gstack) SKIP_GSTACK=1 ;;
    --skip-plugins) SKIP_PLUGINS=1 ;;
    --skip-mcp) SKIP_MCP=1 ;;
    --skip-codex) SKIP_CODEX=1 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

case "$(uname -s)" in
  Darwin|Linux) ;;
  *) echo "On Windows run install.ps1 instead." >&2; exit 1 ;;
esac

WARNINGS=""
MANUAL=""
BACKED_UP=0

step() { printf '\n\033[36m==> %s\033[0m\n' "$*"; }
ok()   { printf '    \033[32mok\033[0m  %s\n' "$*"; }
info() { printf '        %s\n' "$*"; }
warn() { WARNINGS="$WARNINGS$*"$'\n'; printf '    \033[33m!!\033[0m  %s\n' "$*"; }
manual() { MANUAL="$MANUAL$*"$'\n'; }
have() { command -v "$1" >/dev/null 2>&1; }
# jq -r with CR stripped (a Windows jq emits CRLF).
jqr() { jq -r "$@" | tr -d '\r'; }

# Copies $1 into the backup folder, keeping its path relative to $2 (default
# CLAUDE_DIR) under label $3. The first backup of a path wins.
backup_path() {
  local p="$1" base="${2:-$CLAUDE_DIR}" label="${3:-claude}"
  [ -e "$p" ] || [ -L "$p" ] || return 0
  local dest="$BACKUP_DIR/$label/${p#"$base"/}"
  [ -e "$dest" ] && return 0
  mkdir -p "$(dirname "$dest")"
  if [ -L "$p" ]; then
    echo "$p -> $(readlink "$p")" >> "$BACKUP_DIR/links.txt"
  else
    cp -R "$p" "$dest"
  fi
  BACKED_UP=1
}

# Deletes a path; a symlink is unlinked, its target never touched.
remove_path() { if [ -L "$1" ]; then rm -f "$1"; else rm -rf "$1"; fi; }

copy_dir_replace() {
  backup_path "$2"
  remove_path "$2"
  mkdir -p "$(dirname "$2")"
  cp -R "$1" "$2"
}

ensure_brew_env() {
  have brew && return 0
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$b" ]; then eval "$("$b" shellenv)"; return 0; fi
  done
  return 1
}

require_jq() {
  have jq && return 0
  ensure_brew_env && brew install jq >/dev/null 2>&1
  have jq || { echo "jq is required. Install it (brew install jq / apt install jq) and re-run." >&2; exit 1; }
}

# ---------------------------------------------------------------- steps

install_tools() {
  step "CLI tools (Homebrew)"
  if ! ensure_brew_env; then
    info "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      || { warn "Homebrew install failed; CLI tools skipped"; return; }
    ensure_brew_env || { warn "brew not found after install; CLI tools skipped"; return; }
    manual "Add Homebrew to your shell profile:  echo 'eval \"\$($(command -v brew) shellenv)\"' >> ~/.zprofile  (or ~/.bashrc on Linux)"
  fi
  require_jq
  local formula bin all_ok=1
  export HOMEBREW_NO_AUTO_UPDATE=1
  brew update >/dev/null 2>&1 || true
  # Commands inside `while read` loops get </dev/null so they cannot eat the list.
  while IFS=$'\t' read -r formula bin; do
    have "$bin" && continue
    info "brew install $formula"
    brew install "$formula" </dev/null >/dev/null 2>&1 || warn "brew install $formula failed"
  done < <(jqr '.brew[] | [.formula, .bin] | @tsv' "$REPO/manifest/tools.json")
  while IFS=$'\t' read -r formula bin; do
    have "$bin" || { all_ok=0; warn "tool still missing: $bin ($formula)"; }
  done < <(jqr '.brew[] | [.formula, .bin] | @tsv' "$REPO/manifest/tools.json")
  [ "$all_ok" = 1 ] && ok "all tools available"
}

install_claude() {
  step "Claude Code"
  if have claude; then ok "claude already installed"; return; fi
  curl -fsSL https://claude.ai/install.sh | bash || true
  export PATH="$HOME/.local/bin:$PATH"
  have claude || { echo "Claude Code install failed. Install it manually, then re-run with --skip-claude-install." >&2; exit 1; }
  ok "claude installed"
}

install_settings() {
  local dest="$CLAUDE_DIR/settings.json" tmpl
  tmpl="$(mktemp)"
  jq --arg d "$CLAUDE_DIR" 'walk(if type == "string" then gsub("__CLAUDE_DIR_POSIX__"; $d) else . end)' \
    "$REPO/claude/settings.template.json" > "$tmpl"
  if [ ! -e "$dest" ]; then
    mv "$tmpl" "$dest"; ok "settings.json written"; return
  fi
  backup_path "$dest"
  local merged
  merged="$(mktemp)"
  if jq -s -f "$REPO/manifest/merge-settings.jq" "$dest" "$tmpl" > "$merged" 2>/dev/null; then
    mv "$merged" "$dest"
    ok "settings.json merged (your existing keys, permissions and hooks kept)"
  else
    mv "$tmpl" "$dest"
    warn "existing settings.json was not valid JSON; replaced with the template (old copy in $BACKUP_DIR)"
  fi
  rm -f "$tmpl" "$merged"
}

install_files() {
  step "Instructions, settings, status line, commands -> $CLAUDE_DIR"
  mkdir -p "$CLAUDE_DIR"
  local f d
  for f in CLAUDE.md INSTRUCT.md statusline-command.sh; do
    backup_path "$CLAUDE_DIR/$f"
    cp "$REPO/claude/$f" "$CLAUDE_DIR/$f"
    ok "$f"
  done
  chmod +x "$CLAUDE_DIR/statusline-command.sh"
  for d in "$REPO"/claude/commands/*/; do
    d="${d%/}"
    copy_dir_replace "$d" "$CLAUDE_DIR/commands/$(basename "$d")"
    ok "commands/$(basename "$d")"
  done
  install_settings
}

backup_existing_skills() {
  local d n
  for d in "$REPO"/claude/skills/*/; do
    d="${d%/}"; backup_path "$CLAUDE_DIR/skills/$(basename "$d")"
  done
  for n in $(jqr '.skills[].name' "$REPO/manifest/remote-skills.json") $GSTACK_ARCHIVED; do
    backup_path "$CLAUDE_DIR/skills/$n"
  done
}

install_gstack() {
  step "gstack (headless browser + QA/review/ship skills)"
  local b
  for b in git bun node; do
    have "$b" || { warn "gstack skipped: '$b' not found"; return; }
  done
  local dir="$CLAUDE_DIR/skills/gstack"
  if [ -d "$dir/.git" ]; then
    info "gstack already cloned; keeping its current version"
  else
    if [ -e "$dir" ] || [ -L "$dir" ]; then backup_path "$dir"; remove_path "$dir"; fi
    mkdir -p "$(dirname "$dir")"
    git clone --quiet --filter=blob:none "$GSTACK_REPO" "$dir" || { warn "git clone of gstack failed"; return; }
    git -C "$dir" -c advice.detachedHead=false checkout --quiet "$GSTACK_REF"
  fi
  info "Running gstack setup (bun install, browser build, Playwright Chromium). Takes a few minutes."
  if ! (cd "$dir" && ./setup --no-prefix); then
    warn "gstack setup failed. Retry later: cd ~/.claude/skills/gstack && ./setup --no-prefix"
    return
  fi
  "$dir/bin/gstack-config" set proactive true >/dev/null 2>&1 || true
  "$dir/bin/gstack-config" set auto_upgrade true >/dev/null 2>&1 || true
  local n
  for n in $GSTACK_ARCHIVED; do
    if [ -f "$CLAUDE_DIR/skills/$n/SKILL.md" ] && grep -q gstack "$CLAUDE_DIR/skills/$n/SKILL.md"; then
      remove_path "$CLAUDE_DIR/skills/$n"
    fi
  done
  ok "gstack installed"
}

install_skills() {
  step "Skills"
  mkdir -p "$CLAUDE_DIR/skills"
  local d count=0
  for d in "$REPO"/claude/skills/*/; do
    d="${d%/}"
    copy_dir_replace "$d" "$CLAUDE_DIR/skills/$(basename "$d")"
    count=$((count + 1))
  done
  ok "$count bundled skills"

  # Read field by field: `path` can be empty, and `read` with a tab IFS would
  # collapse the empty field and shift the rest.
  local m="$REPO/manifest/remote-skills.json" total i name repo ref path f stage failed
  total="$(jqr '.skills | length' "$m")"
  i=0
  while [ "$i" -lt "$total" ]; do
    name="$(jqr ".skills[$i].name" "$m")"
    repo="$(jqr ".skills[$i].repo" "$m")"
    ref="$(jqr ".skills[$i].ref" "$m")"
    path="$(jqr ".skills[$i].path" "$m")"
    stage="$(mktemp -d)"; failed=0
    for f in $(jqr ".skills[$i].files[]" "$m"); do
      curl -fsSL "https://raw.githubusercontent.com/$repo/$ref/$path$f" -o "$stage/$f" && [ -s "$stage/$f" ] || failed=1
    done
    if [ "$failed" = 0 ]; then
      copy_dir_replace "$stage" "$CLAUDE_DIR/skills/$name"
      ok "$name (fetched from github.com/$repo)"
    else
      warn "could not fetch skill $name"
    fi
    rm -rf "$stage"
    i=$((i + 1))
  done
}

install_plugins() {
  step "Plugins"
  have claude || { warn "claude not found; plugins skipped"; return; }
  local existing name repo p
  existing="$(claude plugin marketplace list 2>&1)"
  while IFS=$'\t' read -r name repo; do
    if printf '%s' "$existing" | grep -qF "$name"; then ok "marketplace $name (already added)"; continue; fi
    if claude plugin marketplace add "$repo" </dev/null >/dev/null 2>&1 \
      || claude plugin marketplace add "https://github.com/$repo.git" </dev/null >/dev/null 2>&1; then
      ok "marketplace $name"
    else
      warn "could not add marketplace $repo"
    fi
  done < <(jqr '.marketplaces[] | [.name, .repo] | @tsv' "$REPO/manifest/plugins.json")
  while read -r p; do
    if claude plugin install "$p" --scope user </dev/null >/dev/null 2>&1; then ok "$p"; else warn "plugin install $p failed (try: claude plugin install $p)"; fi
  done < <(jqr '.plugins[]' "$REPO/manifest/plugins.json")
}

install_mcp() {
  step "MCP servers"
  have claude || { warn "claude not found; MCP servers skipped"; return; }
  local fs="$CLAUDE_DIR/mcp-servers/free-search" f
  mkdir -p "$fs"
  for f in "$REPO"/claude/mcp-servers/free-search/*; do
    backup_path "$fs/$(basename "$f")"
    cp "$f" "$fs/"
  done
  if have npm; then
    (cd "$fs" && npm ci --omit=dev --no-audit --no-fund >/dev/null 2>&1) || warn "npm ci for free-search failed"
  else
    warn "npm not found; free-search dependencies not installed"
  fi

  local count i name transport url command args
  count="$(jqr '.servers | length' "$REPO/manifest/mcp.json")"
  i=0
  while [ "$i" -lt "$count" ]; do
    name="$(jqr ".servers[$i].name" "$REPO/manifest/mcp.json")"
    transport="$(jqr ".servers[$i].transport" "$REPO/manifest/mcp.json")"
    if claude mcp get "$name" >/dev/null 2>&1; then
      ok "$name (already configured, left as is)"
    elif [ "$transport" = "http" ]; then
      url="$(jqr ".servers[$i].url" "$REPO/manifest/mcp.json")"
      if claude mcp add --scope user --transport http "$name" "$url" >/dev/null 2>&1; then ok "$name"; else warn "claude mcp add $name failed"; fi
    else
      command="$(jqr ".servers[$i].command" "$REPO/manifest/mcp.json")"
      args=()
      while IFS= read -r a; do args+=("$a"); done < <(jqr --arg d "$CLAUDE_DIR" ".servers[$i].args[] | gsub(\"__CLAUDE_DIR_FWD__\"; \$d)" "$REPO/manifest/mcp.json")
      if claude mcp add --scope user "$name" -- "$command" "${args[@]}" >/dev/null 2>&1; then ok "$name"; else warn "claude mcp add $name failed"; fi
    fi
    i=$((i + 1))
  done

  if [ -z "${PUTER_AUTH_TOKEN:-}" ]; then
    manual "free-search MCP needs a free Puter token: (cd \"$fs\" && npm run get-token), then add  export PUTER_AUTH_TOKEN=<token>  to your shell profile and open a new terminal."
  fi
  manual "In Claude Code run /mcp and authenticate the github and figma servers."
}

install_codex() {
  step "Codex CLI (executor for the fable-gpt workflow)"
  if ! have codex; then
    if have npm; then
      npm install -g @openai/codex >/dev/null 2>&1 || warn "npm install -g @openai/codex failed (system Node may need sudo, or use brew's node)"
    else
      warn "npm not found; Codex CLI not installed"
    fi
  fi
  have codex && ok "codex available"
  mkdir -p "$CODEX_DIR"
  backup_path "$CODEX_DIR/AGENTS.md" "$CODEX_DIR" codex
  cp "$REPO/codex/AGENTS.md" "$CODEX_DIR/AGENTS.md"
  ok "AGENTS.md"
  if [ ! -e "$CODEX_DIR/config.toml" ]; then
    cp "$REPO/codex/config.example.toml" "$CODEX_DIR/config.toml"
    ok "config.toml (starter)"
  else
    info "config.toml exists; left unchanged"
  fi
  manual "Run  codex login  once, then inside Claude Code run /codex:setup to confirm the plugin sees it."
}

# ---------------------------------------------------------------- main

echo "Claude setup installer"
echo "  repo:   $REPO"
echo "  claude: $CLAUDE_DIR"
echo "  codex:  $CODEX_DIR"

export PATH="$HOME/.local/bin:$PATH"
[ "$SKIP_TOOLS" = 1 ] || install_tools
ensure_brew_env || true
require_jq
[ "$SKIP_CLAUDE" = 1 ] || install_claude
install_files
backup_existing_skills
[ "$SKIP_GSTACK" = 1 ] || install_gstack
install_skills
[ "$SKIP_PLUGINS" = 1 ] || install_plugins
[ "$SKIP_MCP" = 1 ] || install_mcp
[ "$SKIP_CODEX" = 1 ] || install_codex

MANUAL="Open a NEW terminal, run  claude  and log in."$'\n'"$MANUAL"
MANUAL="${MANUAL}Optional: for the rust-analyzer-lsp plugin install Rust (rustup) and run  rustup component add rust-analyzer."$'\n'

step "Done"
echo "    skills folder now holds $(find "$CLAUDE_DIR/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') skills"
[ "$BACKED_UP" = 1 ] && echo "    replaced files were backed up to $BACKUP_DIR"
if [ -n "$WARNINGS" ]; then
  printf '\n\033[33mWarnings:\033[0m\n'
  printf '%s' "$WARNINGS" | sed 's/^/  - /'
fi
printf '\nFinish by hand:\n'
printf '%s' "$MANUAL" | awk '{ printf "  %d. %s\n", NR, $0 }'
