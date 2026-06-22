#!/usr/bin/env sh
set -eu

PLATFORM_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
INSTALL_DIR=${1:-"$HOME/.local/bin"}

mkdir -p "$INSTALL_DIR"
cp "$PLATFORM_DIR/codex-auth-profile.py" "$INSTALL_DIR/codex-auth-profile.py"
cp "$PLATFORM_DIR/codex-auth-profile" "$INSTALL_DIR/codex-auth-profile"
chmod +x "$INSTALL_DIR/codex-auth-profile.py" "$INSTALL_DIR/codex-auth-profile"

echo "Installed Unix codex-auth-profile to: $INSTALL_DIR"
echo "Make sure this directory is on PATH, for example:"
echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
echo "Then run:"
echo "  codex-auth-profile --help"
