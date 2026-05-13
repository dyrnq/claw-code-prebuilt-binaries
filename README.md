# claw-code Prebuilt Binaries

Prebuilt cross-platform binaries of [ultraworkers/claw-code](https://github.com/ultraworkers/claw-code).

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/dyrnq/claw-code-prebuilt-binaries/main/install.sh | bash
```

Or step by step:

```bash
# Detect platform
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS-$ARCH" in
  Linux-x86_64)   TARGET="x86_64-unknown-linux-gnu" ;;
  Linux-aarch64)  TARGET="aarch64-unknown-linux-gnu" ;;
  Linux-armv7*)   TARGET="armv7-unknown-linux-musleabihf" ;;
  Darwin-x86_64)  TARGET="x86_64-apple-darwin" ;;
  Darwin-arm64)   TARGET="aarch64-apple-darwin" ;;
  *) echo "Unsupported platform: $OS-$ARCH"; exit 1 ;;
esac

# Download latest release
REPO="dyrnq/claw-code-prebuilt-binaries"
curl -fsSL "https://github.com/$REPO/releases/latest/download/claw-$TARGET.tar.zst" -o claw.tar.zst
tar -xf claw.tar.zst
chmod +x claw
sudo mv claw /usr/local/bin/
claw --version
```

## Supported Targets

| Target                           | Platform                   |
| -------------------------------- | -------------------------- |
| `x86_64-unknown-linux-gnu`       | Linux x86_64 (glibc)       |
| `x86_64-unknown-linux-musl`      | Linux x86_64 (static musl) |
| `aarch64-unknown-linux-musl`     | Linux ARM64 (static musl)  |
| `aarch64-unknown-linux-gnu`      | Linux ARM64 (glibc)        |
| `armv7-unknown-linux-musleabihf` | Linux ARMv7 (static musl)  |
| `x86_64-apple-darwin`            | macOS Intel                |
| `aarch64-apple-darwin`           | macOS Apple Silicon        |
| `x86_64-pc-windows-msvc`         | Windows x86_64             |

Each target provides 4 formats: raw binary, `.tar.gz`, `.tar.xz`, `.tar.zst`, plus `sha256sums.txt`.

## How It Works

Two workflows collaborate to poll upstream and ship releases:

```
sync.yml (every 30 min)
  │
  ├─ git ls-remote checks upstream HEAD
  ├─ If changed → writes ref → commits → pushes
  ├─ Tags: vYYYYMMDDHHmm-<short_sha>
  ├─ gh release create
  └─ gh workflow run --ref triggers release.yml

release.yml
  │
  ├─ Reads ref → checks out upstream source
  ├─ Cross-compiles 8 targets
  └─ Compresses + gh release upload to Release
```

## Manual Trigger

- Go to **Actions → Sync Upstream → Run workflow**, or
- Push a `v*` tag to trigger the build-and-release workflow.

## Pinning an Upstream Commit

Edit `ref` and push a `v*` tag:

```bash
echo "abc123def456..." > ref
git add ref && git commit -m "chore: pin upstream"
git tag v$(date +%Y%m%d%H%M)-abc123d
git push --follow-tags
```
