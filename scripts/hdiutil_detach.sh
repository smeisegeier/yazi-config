#!/usr/bin/env bash
# detach the disk image (e.g. a .sparsebundle) at $1, wherever its volume is mounted

image="$(cd "$1" 2>/dev/null && pwd -P || echo "$1")"
image="${image%/}"

# hdiutil info lists one block per image: image-path/image-alias lines, then its /dev/diskN lines;
# the first /dev line of the matching block is the whole disk, detaching it unmounts all its volumes
disk=$(hdiutil info | awk -v img="$(echo "$image" | tr '[:upper:]' '[:lower:]')" '
    /^=+$/ { hit = 0; next }
    /^image-(path|alias)/ { sub(/^[^:]*: /, ""); if (tolower($0) == img) hit = 1; next }
    hit && /^\/dev\// { print $1; exit }
')

if [[ -z "$disk" ]]; then
    echo -e "\033[0;33m[ ! ] Not attached: $image\033[0m"
elif hdiutil detach "$disk"; then
    echo -e "\033[0;32m[ ✔ ] Detached $disk\033[0m"
else
    echo -e "\033[0;31m[ ✘ ] Detach failed\033[0m"
fi

"$(dirname "$0")/pause.sh"
