#!/usr/bin/env bash
# dex2jar-manager.sh — Download, install, and update dex2jar from GitHub releases
# Usage:
#   ./dex2jar-manager.sh install    — fresh install (skip if already installed)
#   ./dex2jar-manager.sh update     — check for newer release and update in-place if outdated
#   source dex2jar-manager.sh && update_dex2jar   — call update from another script
set -euo pipefail

REPO="ThexXTURBOXx/dex2jar"
INSTALL_DIR="$HOME/.local/share/dex2jar"
VERSION_FILE="$INSTALL_DIR/.version"
BIN_DIR="$HOME/.local/bin"

info()  { echo "[INFO] $*"; }
ok()    { echo "[OK] $*"; }
fail()  { echo "[FAIL] $*" >&2; }

download() {
  local url="$1" dest="$2"
  if command -v curl &>/dev/null; then
    curl -fsSL -o "$dest" "$url"
  elif command -v wget &>/dev/null; then
    wget -q -O "$dest" "$url"
  else
    fail "Neither curl nor wget available."
    return 1
  fi
}

# Fetch the latest release tag from GitHub. Prints the tag, e.g. "v2.4.35".
fetch_latest_tag() {
  curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | head -1 | sed 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/'
}

# Returns 0 (success) if installed, 1 otherwise.
is_installed() {
  [[ -f "$VERSION_FILE" ]]
}

# Print the currently installed version tag, or nothing.
installed_version() {
  if is_installed; then cat "$VERSION_FILE"; fi
}

# Add PATH entry to ~/.zshrc.d/dex2jar if not already present.
ensure_path() {
  local dir="$HOME/.zshrc.d"
  local file="$dir/dex2jar"
  local line='export PATH="$HOME/.local/bin:$PATH"'
  mkdir -p "$dir"
  if ! grep -qF "$line" "$file" 2>/dev/null; then
    echo "$line" >> "$file"
    info "Added to $file"
    info "Run 'source $file' or start a new shell to apply."
  fi
}

# Download and extract the given tag, symlink tools, write version file.
_do_install() {
  local tag="$1"
  local version="${tag#v}"

  local url="https://github.com/$REPO/releases/download/${tag}/dex-tools-${version}.zip"
  info "Downloading dex2jar $version..."

  local tmp_zip
  tmp_zip=$(mktemp /tmp/dex2jar-XXXXXX.zip)

  if ! download "$url" "$tmp_zip"; then
    url="https://github.com/$REPO/releases/download/${tag}/dex-tools-v${version}.zip"
    download "$url" "$tmp_zip" || {
      fail "Download failed: $url"
      fail "Get it manually: https://github.com/$REPO/releases/latest"
      return 1
    }
  fi

  rm -rf "$INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  unzip -qo "$tmp_zip" -d "$INSTALL_DIR"
  rm -f "$tmp_zip"

  # Find bin directory (archive may have a top-level folder)
  local bin_dir=""
  if [[ -f "$INSTALL_DIR/d2j-dex2jar.sh" ]]; then
    bin_dir="$INSTALL_DIR"
  else
    bin_dir=$(find "$INSTALL_DIR" -name "d2j-dex2jar.sh" -exec dirname {} \; | head -1)
  fi

  if [[ -z "$bin_dir" ]]; then
    fail "Could not find d2j-dex2jar.sh in the extracted archive."
    return 1
  fi

  chmod +x "$bin_dir"/*.sh 2>/dev/null || true

  # Symlink into ~/.local/bin
  mkdir -p "$BIN_DIR"
  for script in "$bin_dir"/d2j-*.sh; do
    local name
    name=$(basename "$script" .sh)
    ln -sf "$script" "$BIN_DIR/$name"
  done

  # Record version
  echo "$tag" > "$VERSION_FILE"

  export PATH="$BIN_DIR:$PATH"
  ensure_path

  ok "dex2jar $version installed to $INSTALL_DIR"
  return 0
}

# ------------------------------------------------------------------
# Public API — callable when sourced
# ------------------------------------------------------------------

# Install dex2jar (no-op if already installed).
install_dex2jar() {
  if is_installed; then
    ok "dex2jar already installed ($(installed_version))"
    return 0
  fi

  info "Fetching latest dex2jar release..."
  local tag
  tag=$(fetch_latest_tag)
  if [[ -z "$tag" ]]; then
    fail "Could not reach GitHub API to determine latest release."
    return 1
  fi

  _do_install "$tag"
}

# Update dex2jar if a newer release is available. Exits 0 if up-to-date
# or updated successfully; exits 1 on error.
update_dex2jar() {
  if ! is_installed; then
    info "dex2jar not installed — installing fresh."
    install_dex2jar
    return $?
  fi

  local current latest
  current=$(installed_version)
  info "Installed version: $current"

  latest=$(fetch_latest_tag)
  if [[ -z "$latest" ]]; then
    info "Could not reach GitHub API to check for updates."
    return 0
  fi

  if [[ "$current" == "$latest" ]]; then
    ok "dex2jar is up-to-date ($current)"
    return 0
  fi

  info "Newer version available: $latest (current: $current)"
  _do_install "$latest"
}

# ------------------------------------------------------------------
# Direct invocation
# ------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  case "${1:-install}" in
    install) install_dex2jar ;;
    update)  update_dex2jar ;;
    -h|--help)
      echo "Usage: $0 {install|update}"
      echo "  install  — install dex2jar (skip if already installed)"
      echo "  update   — check for newer release, update in-place if outdated"
      ;;
    *)
      fail "Unknown command: $1"
      echo "Usage: $0 {install|update}"
      exit 1
      ;;
  esac
fi
