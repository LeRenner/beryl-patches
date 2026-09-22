#!/bin/sh

set -eu

PATCH_NAME="tailscale-headscale"
TARGET="/usr/bin/gl_tailscale"
STATE_DIR="/var/lib/beryl-patches/$PATCH_NAME"
BACKUP="$STATE_DIR/gl_tailscale.orig"

echo "==> Removing patch: $PATCH_NAME"

if [ ! -f "$STATE_DIR/applied" ]; then
echo "Patch is not currently marked as applied."
exit 0
fi

if [ ! -f "$BACKUP" ]; then
echo "ERROR: Backup is missing:"
echo "  $BACKUP"
echo
echo "Refusing to modify $TARGET."
exit 1
fi

echo "==> Restoring original $TARGET"

cp -p "$BACKUP" "$TARGET"

rm -f "$STATE_DIR/applied"

echo "==> Patch removed successfully."
