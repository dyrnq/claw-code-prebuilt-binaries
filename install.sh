#!/usr/bin/env bash
set -euo pipefail

REPO="dyrnq/claw-code-prebuilt-binaries"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Detect platform
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS-$ARCH" in
  Linux-x86_64)   TARGET="x86_64-unknown-linux-gnu";   EXT="" ;;
  Linux-aarch64)  TARGET="aarch64-unknown-linux-gnu";  EXT="" ;;
  Linux-armv7*)   TARGET="armv7-unknown-linux-musleabihf"; EXT="" ;;
  Darwin-x86_64)  TARGET="x86_64-apple-darwin";        EXT="" ;;
  Darwin-arm64)   TARGET="aarch64-apple-darwin";       EXT="" ;;
  *)
    echo "Unsupported platform: $OS-$ARCH"
    echo "See https://github.com/$REPO/releases for all targets."
    exit 1
    ;;
esac

echo "→ Platform: $TARGET"

# Fetch latest release tag
echo "→ Fetching latest release..."
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$LATEST_TAG" ]; then
  echo "Error: could not determine latest release."
  exit 1
fi
echo "→ Latest: $LATEST_TAG"

# Download binary and checksum
BIN_NAME="claw-$TARGET"
DL_BASE="https://github.com/$REPO/releases/download/$LATEST_TAG"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "→ Downloading $BIN_NAME..."
curl -fsSL "$DL_BASE/$BIN_NAME.tar.zst" -o "$TMPDIR/$BIN_NAME.tar.zst"
curl -fsSL "$DL_BASE/sha256sums.txt"     -o "$TMPDIR/sha256sums.txt"

# Verify checksum
echo "→ Verifying checksum..."
cd "$TMPDIR"
tar -xf "$BIN_NAME.tar.zst"
grep "$BIN_NAME\$" sha256sums.txt | sha256sum -c -

# Install
echo "→ Installing to $INSTALL_DIR/claw..."
chmod +x "$BIN_NAME"
sudo mv "$BIN_NAME" "$INSTALL_DIR/claw"

echo "→ Done! claw installed at $INSTALL_DIR/claw"
claw --version 2>/dev/null || true
