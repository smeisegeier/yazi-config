#!/bin/bash
# Tell yazi to quit, then exec the selected file so it takes over the
# real terminal directly (not a process spawned under yazi).
file="$1"
ya emit quit
exec "$file"
