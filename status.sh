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

```
patch_name="$(basename "$patch_dir")"

printf "%-30s " "$patch_name"

if [ -f "$STATE_DIR/$patch_name/applied" ]; then
    echo "APPLIED"
else
    echo "NOT APPLIED"
fi
```

done
