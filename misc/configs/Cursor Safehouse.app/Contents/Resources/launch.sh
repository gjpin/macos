#!/bin/bash
set -euo pipefail

SAFEHOUSE="${HOME}/.local/bin/safehouse"
CURSOR_BIN="/Applications/Cursor.app/Contents/MacOS/Cursor"
SRC_DIR="${HOME}/src"

# Prefer native Apple Silicon for this process tree (avoids Cursor's Intel/Rosetta warning).
if [[ "$(uname -m)" != "arm64" ]]; then
  exec /usr/bin/arch -arm64 /bin/bash "$0" "$@"
fi

if [[ ! -x "$SAFEHOUSE" ]]; then
  osascript -e 'display alert "Cursor Safehouse" message "safehouse.sh not found or not executable at:\n~/local/bin/safehouse" as critical' >/dev/null 2>&1 || true
  exit 1
fi

if [[ ! -x "$CURSOR_BIN" ]]; then
  osascript -e 'display alert "Cursor Safehouse" message "Cursor.app not found at:\n/Applications/Cursor.app" as critical' >/dev/null 2>&1 || true
  exit 1
fi

if [[ -d "$SRC_DIR" ]]; then
  cd "$SRC_DIR"
fi

# Force arm64 for the sandbox wrapper and Cursor (universal binary).
exec /usr/bin/arch -arm64 "$SAFEHOUSE" \
  --enable=ssh \
  --add-dirs=~/src \
  -- "$CURSOR_BIN" --no-sandbox "$@"
