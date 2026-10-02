#!/bin/bash
# Hand the selected file over to the `y` shell wrapper and quit yazi, so the
# wrapper runs it in the real terminal after yazi has fully exited.
# (A blocking opener can't do this: yazi only processes `quit` once the
# opener's process has finished.)
# Usage: exec_selected.sh [-a] FILE   (-a: prompt for arguments before running)
ask=""
if [ "$1" = "-a" ]; then
    ask=1
    shift
fi
file="$1"
if [ -n "$YAZI_EXEC_FILE" ]; then
    # line 1: file, line 2 (optional): "args" -> wrapper prompts for arguments
    printf '%s\n%s' "$file" "${ask:+args}" > "$YAZI_EXEC_FILE"
    ya emit quit
elif [ -n "$ask" ]; then
    # Not started via `y`: let yazi prompt for the command line, then run inside yazi
    ya emit shell --block --interactive -- "$(printf '%q ' "$file")"
else
    # Not started via `y`: fall back to running it inside yazi
    ya emit shell --block -- "$(printf '%q' "$file")"
fi
