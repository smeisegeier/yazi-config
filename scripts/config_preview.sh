#!/usr/bin/env bash
# preview extensionless "config" files with bat, guessing the syntax from the content
# when bat has no path mapping for them (it already knows e.g. ~/.ssh/config, .git/config, ~/.aws/config)

file="$1"
lang=()

case "$file" in
  */.ssh/config|*/.git/config|*/git/config|*/.aws/config) ;;
  *)
    # first line that is neither blank nor a comment
    first=$(grep -m1 -vE '^[[:space:]]*($|#|;|//)' "$file" 2>/dev/null)
    if [[ "$first" =~ ^[[:space:]]*(\{|\[[[:space:]]*($|[\"\{\[0-9])) ]]; then
      lang=(-l json)
    elif grep -qiE '^[[:space:]]*(Host|Match|Include)[[:space:]]' "$file"; then
      lang=(-l "SSH Config")
    elif grep -qE '^[[:space:]]*\[[^]]+\][[:space:]]*$' "$file"; then
      lang=(-l ini)
    elif grep -qE '^[[:space:]]*-?[[:space:]]*[A-Za-z0-9_.-]+:([[:space:]]|$)' "$file"; then
      lang=(-l yaml)
    elif grep -qE '^[[:space:]]*[A-Za-z0-9_.-]+[[:space:]]*=' "$file"; then
      lang=(-l ini)
    fi
    ;;
esac

exec bat --color=always --style=numbers --theme=auto:system "${lang[@]}" "$file"
