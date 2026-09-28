#!/usr/bin/env bash
# One-command install for macOS / Linux:
#   curl -fsSL https://raw.githubusercontent.com/NAME0x0/CLAUDE_SETUP/main/bootstrap.sh | bash
# With installer flags:
#   curl -fsSL https://raw.githubusercontent.com/NAME0x0/CLAUDE_SETUP/main/bootstrap.sh | bash -s -- --skip-gstack
#
# Downloads the repo (no git needed) to ~/.claude-setup, then runs install.sh.
set -euo pipefail

DEST="${CLAUDE_SETUP_DIR:-$HOME/.claude-setup}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "Downloading NAME0x0/CLAUDE_SETUP..."
curl -fsSL https://github.com/NAME0x0/CLAUDE_SETUP/archive/refs/heads/main.tar.gz | tar -xz -C "$WORK"
if [ -f "$DEST/install.sh" ]; then
  rm -rf "$DEST"
elif [ -e "$DEST" ]; then
  echo "$DEST exists and is not a CLAUDE_SETUP copy. Set CLAUDE_SETUP_DIR to another folder." >&2
  exit 1
fi
mv "$WORK/CLAUDE_SETUP-main" "$DEST"

exec bash "$DEST/install.sh" "$@"
