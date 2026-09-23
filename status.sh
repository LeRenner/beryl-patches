#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

echo "Beryl patch status"
echo "=================="
echo

for patch in "$SCRIPT_DIR"/patches/*/apply.sh; do
[ -f "$patch" ] || continue

```
patch_name="$(basename "$(dirname "$patch")")"

printf "%-30s " "$patch_name"

if [ -f "/var/lib/beryl-patches/$patch_name/applied" ]; then
    echo "APPLIED"
else
    echo "NOT APPLIED"
fi
```

done
