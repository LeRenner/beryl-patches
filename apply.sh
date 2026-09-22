#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

echo "==> Applying Beryl patches"
echo

for patch in "$SCRIPT_DIR"/patches/*/apply.sh; do
[ -f "$patch" ] || continue

```
patch_name="$(basename "$(dirname "$patch")")"

echo "==> Applying: $patch_name"
"$patch"
echo
```

done

echo "==> All patches applied."
