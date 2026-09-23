#!/bin/sh
set -eu

PATCH_NAME="tailscale-headscale"
TARGET="/usr/bin/gl_tailscale"
STATE_DIR="/var/lib/beryl-patches/$PATCH_NAME"
BACKUP="$STATE_DIR/gl_tailscale.orig"

echo "==> Patch: $PATCH_NAME"

if [ ! -f "$TARGET" ]; then
    echo "ERROR: Target does not exist:"
    echo "  $TARGET"
    exit 1
fi

if [ -f "$STATE_DIR/applied" ]; then
    echo "Patch is already marked as applied."
    exit 0
fi

mkdir -p "$STATE_DIR"

EXPECTED='timeout 10 /usr/sbin/tailscale up --reset --accept-routes $param --timeout 3s --accept-dns=false > /dev/null'
PATCHED='timeout 10 /usr/sbin/tailscale up --reset --login-server=https://headscale.pudim.xyz --accept-routes $param --timeout 3s --accept-dns=false > /dev/null'

if ! grep -Fq "$EXPECTED" "$TARGET"; then
    echo "ERROR: Expected GL.iNet Tailscale command was not found."
    echo
    echo "The firmware may have changed, or the patch is already"
    echo "applied in an unexpected form."
    echo
    echo "Refusing to modify the file."
    exit 1
fi

if [ ! -f "$BACKUP" ]; then
    echo "==> Creating original backup:"
    echo "    $BACKUP"
    cp -p "$TARGET" "$BACKUP"
else
    echo "==> Original backup already exists:"
    echo "    $BACKUP"
fi

echo "==> Applying Headscale control server"

awk -v expected="$EXPECTED" -v patched="$PATCHED" '
{
    if (index($0, expected) > 0) {
        sub(expected, patched)
    }
    print
}
' "$TARGET" > "$TARGET.tmp"

mv "$TARGET.tmp" "$TARGET"

if ! grep -Fq "$PATCHED" "$TARGET"; then
    echo "ERROR: Patch verification failed."
    echo "Restoring original file."
    cp -p "$BACKUP" "$TARGET"
    exit 1
fi

touch "$STATE_DIR/applied"

echo "==> Patch applied successfully."
