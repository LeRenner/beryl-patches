#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/patches"

echo "==> Removing Beryl patches"
echo

for patch_dir in "$PATCHES_DIR"/*; do
    [ -d "$patch_dir" ] || continue
    [ -f "$patch_dir/remove.sh" ] || continue

    patch_name="$(basename "$patch_dir")"

    echo "==> Removing: $patch_name"
    "$patch_dir/remove.sh"
    echo
done

echo "==> All patches removed."
