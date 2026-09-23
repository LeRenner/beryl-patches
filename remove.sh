#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

echo "==> Removing Beryl patches"
echo

for patch in $(find "$SCRIPT_DIR/patches" 
-mindepth 2 
-maxdepth 2 
-name remove.sh 
| sort -r); do

```
patch_name="$(basename "$(dirname "$patch")")"

echo "==> Removing: $patch_name"
"$patch"
echo
```

done

echo "==> All patches removed."
