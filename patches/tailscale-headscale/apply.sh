#!/bin/sh

set -eu

PATCH_NAME="tailscale-headscale"
TARGET="/usr/bin/gl_tailscale"
STATE_DIR="/var/lib/beryl-patches/$PATCH_NAME"
BACKUP="$STATE_DIR/gl_tailscale.orig"

echo "==> Patch: $PATCH_NAME"

if [ ! -f "$TARGET" ]; then
echo "ERROR: $TARGET does not exist."
exit 1
fi

if [ -f "$STATE_DIR/applied" ]; then
echo "Patch is already applied."
exit 0
fi

mkdir -p "$STATE_DIR"

# Make sure we know exactly what we are patching.

if ! grep -Fq 
'tailscale up --reset --accept-routes $param --timeout 3s --accept-dns=false' 
"$TARGET"
then
echo "ERROR: Expected GL.iNet Tailscale command was not found."
echo
echo "The firmware may have changed."
echo "Refusing to modify the file."
exit 1
fi

echo "==> Backing up $TARGET"
cp -p "$TARGET" "$BACKUP"

echo "==> Applying Headscale control server"

sed -i 
's#tailscale up --reset --accept-routes $param --timeout 3s --accept-dns=false#tailscale up --reset --login-server=https://headscale.pudim.xyz --accept-routes $param --timeout 3s --accept-dns=false#' 
"$TARGET"

# Verify the modification actually happened.

if ! grep -Fq 
'tailscale up --reset --login-server=https://headscale.pudim.xyz --accept-routes $param --timeout 3s --accept-dns=false' 
"$TARGET"
then
echo "ERROR: Patch verification failed."
echo "Restoring backup."
cp -p "$BACKUP" "$TARGET"
exit 1
fi

touch "$STATE_DIR/applied"

echo "==> Patch applied successfully."
echo
echo "Modified:"
echo "  $TARGET"
echo
echo "Backup:"
echo "  $BACKUP"
