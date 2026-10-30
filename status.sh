#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/patches"
STATE_DIR="/var/lib/beryl-patches"

echo "Beryl patch status"
echo "=================="
echo

for patch_dir in "$PATCHES_DIR"/*; do
    [ -d "$patch_dir" ] || continue
    [ -f "$patch_dir/apply.sh" ] || continue

    name="$(basename "$patch_dir")"
    marker="$STATE_DIR/$name/applied"
    printf "%-30s " "$name"

    if [ "$name" = "tailscale-headscale" ]; then
        target="/usr/bin/gl_tailscale"

        if [ ! -f "$target" ]; then
            echo "TARGET MISSING"
        elif grep -Fq -- '--login-server=https://headscale.pudim.xyz:32032 ' "$target" &&
             grep -Fq -- '--advertise-routes=10.0.0.0/24' "$target"; then
            if [ -f "$marker" ]; then
                echo "APPLIED"
            else
                echo "PATCHED BUT UNMARKED"
            fi
        elif grep -Fq -- '--login-server=' "$target"; then
            echo "DRIFTED (unexpected control URL)"
        else
            echo "NOT APPLIED"
        fi
    elif [ -f "$marker" ]; then
        echo "MARKED APPLIED (not content-verified)"
    else
        echo "NOT APPLIED"
    fi
done
