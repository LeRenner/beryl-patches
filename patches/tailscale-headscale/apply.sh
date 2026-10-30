#!/bin/sh
set -eu

PATCH_NAME="tailscale-headscale"
TARGET="/usr/bin/gl_tailscale"
STATE_DIR="/var/lib/beryl-patches/$PATCH_NAME"
BACKUP="$STATE_DIR/gl_tailscale.orig"
PATCH_FILE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/files/gl_tailscale.patch"
FIRMWARE="/rom/usr/bin/gl_tailscale"
URL="https://headscale.pudim.xyz:32032"
OLD_URL="https://headscale.pudim.xyz"

echo "==> Applying patch: $PATCH_NAME"

[ -f "$TARGET" ] || {
    echo "ERROR: Target does not exist: $TARGET"
    exit 1
}

[ -f "$PATCH_FILE" ] || {
    echo "ERROR: Patch file does not exist: $PATCH_FILE"
    exit 1
}

mkdir -p "$STATE_DIR"

# A valid backup must be the original, unpatched vendor script.
backup_is_clean() {
    [ -f "$1" ] &&
    ! grep -Fq -- '--login-server=' "$1" &&
    ! grep -Fq -- '--advertise-routes=10.0.0.0/24' "$1" &&
    grep -Fq 'tailscale up --reset --accept-routes' "$1"
}

# Recover a polluted or missing backup from the read-only firmware image.
if ! backup_is_clean "$BACKUP"; then
    if backup_is_clean "$FIRMWARE"; then
        echo "==> Recovering clean backup from firmware image"
        cp -p "$FIRMWARE" "$BACKUP"
    else
        echo "ERROR: No trustworthy original backup is available."
        echo "Refusing to overwrite the existing backup or guess."
        exit 1
    fi
fi

# Already correct? Repair the marker and exit.
if grep -Fq -- "--login-server=$URL" "$TARGET" &&
   grep -Fq -- '--advertise-routes=10.0.0.0/24' "$TARGET"; then
    touch "$STATE_DIR/applied"
    echo "==> Patch is already correct; marker repaired."
    exit 0
fi

# Upgrade the previous patch in place.
if grep -Fq -- "--login-server=$OLD_URL " "$TARGET"; then
    echo "==> Updating existing Headscale patch to port 32032"
    sed -i "s|--login-server=$OLD_URL |--login-server=$URL |g" "$TARGET"

    if ! grep -Fq -- '--advertise-routes=10.0.0.0/24' "$TARGET"; then
        sed -i '/--login-server=https:\/\/headscale.pudim.xyz:32032/a\
        /usr/sbin/tailscale set --advertise-routes=10.0.0.0/24' "$TARGET"
    fi
else
    # Only apply the diff to a clean, unpatched target.
    if grep -Fq -- '--login-server=' "$TARGET"; then
        echo "ERROR: Target has an unexpected login-server setting."
        echo "Inspect $TARGET manually; refusing to overwrite it."
        exit 1
    fi

    echo "==> Checking patch applicability"
    patch --dry-run "$TARGET" < "$PATCH_FILE"

    echo "==> Applying patch"
    patch "$TARGET" < "$PATCH_FILE"
fi

# Verify the actual result before marking success.
if ! grep -Fq -- "--login-server=$URL " "$TARGET" ||
   ! grep -Fq -- '--advertise-routes=10.0.0.0/24' "$TARGET"; then
    echo "ERROR: Verification failed."
    echo "The target was not marked as successfully patched."
    exit 1
fi

touch "$STATE_DIR/applied"
echo "==> Patch applied and verified."
