#!/bin/sh
set -eu

PATCH_NAME="tailscale-headscale"
TARGET="/usr/bin/gl_tailscale"
STATE_DIR="/var/lib/beryl-patches/$PATCH_NAME"
BACKUP="$STATE_DIR/gl_tailscale.orig"
PATCH_FILE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/files/gl_tailscale.patch"

echo "==> Patch: $PATCH_NAME"

if [ ! -f "$TARGET" ]; then
    echo "ERROR: Target does not exist:"
    echo "  $TARGET"
    exit 1
fi

if [ ! -f "$PATCH_FILE" ]; then
    echo "ERROR: Patch file does not exist:"
    echo "  $PATCH_FILE"
    exit 1
fi

if [ -f "$STATE_DIR/applied" ]; then
    echo "Patch is already marked as applied."
    exit 0
fi

mkdir -p "$STATE_DIR"

if [ ! -f "$BACKUP" ]; then
    echo "==> Creating original backup:"
    echo "    $BACKUP"
    cp -p "$TARGET" "$BACKUP"
else
    echo "==> Original backup already exists:"
    echo "    $BACKUP"
fi

echo "==> Applying patch"

patch --dry-run "$TARGET" < "$PATCH_FILE"

patch "$TARGET" < "$PATCH_FILE"

echo "==> Verifying patch"

if ! grep -Fq 'tailscale up --reset --login-server=https://headscale.pudim.xyz' "$TARGET"; then
    echo "ERROR: Patch verification failed."
    echo "Restoring original file."
    cp -p "$BACKUP" "$TARGET"
    exit 1
fi

touch "$STATE_DIR/applied"

echo "==> Patch applied successfully."
