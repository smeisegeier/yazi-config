#!/usr/bin/env bash

# Path to your keymap
KEYMAP="${YAZI_CONFIG_HOME:-$HOME/.config/yazi}/keymap.toml"

# Skip bindings that are scoped (for = "...") to another OS
case "$(uname -s)" in
    Darwin*) OTHER_OS='for *= *"(windows|linux)"' ;;
    Linux*)  OTHER_OS='for *= *"(windows|macos)"' ;;
    *)       OTHER_OS='for *= *"(unix|macos|linux)"' ;;
esac

# 1. Extract, Filter, and Clean
# - The :a loop removes all "," and spaces between quotes inside [ ]
LIST=$(grep -E '^[[:space:]]*\{[^#]*on =' "$KEYMAP" | grep -vE "$OTHER_OS" | sed -E '
    :a
    s/(on = \[.*)"[[:space:]]*,[[:space:]]*"([^"]*".*\])/\1\2/
    ta
    s/^[[:space:]]*\{[[:space:]]*on = \[ "([^"]+)" \],[[:space:]]*run = "([^"]+)",[[:space:]]*desc = "([^"]+)".*/\1 | \3@@\2/p
    t done
    s/^[[:space:]]*\{[[:space:]]*on = \[ "([^"]+)" \],[[:space:]]*run = '"'"'([^'"'"']+)'"'"',[[:space:]]*desc = "([^"]+)".*/\1 | \3@@\2/p
    :done
    d
' | sed $'s/@@/\t/')

# 2. Safety check
if [[ -z "$LIST" ]]; then
    echo "❌ No active keymaps found."
    read -n 1 -s -r < /dev/tty
    exit 1
fi

# 3. Show in FZF
SELECTION=$(printf '%s\n' "$LIST" | fzf --ansi \
    --header "Keys         | Description                         " \
    --delimiter $'\t' \
    --with-nth 1)

# 4. Execute
if [[ -n "$SELECTION" ]]; then
    RAW_CMD=$(echo "$SELECTION" | cut -f2)
    
    # CASE A: Shell Commands (e.g., SSH Hash script)
    if [[ "$RAW_CMD" == "shell "* ]]; then
        CLEAN_CMD=$(echo "$RAW_CMD" | sed -E "s/^shell //; s/ --block$//; s/^['\"]//; s/['\"]$//")
        echo -e "\033[0;34m⚡ Executing Shell: $CLEAN_CMD\033[0m\n"
        eval "$CLEAN_CMD"
        echo -e "\n\033[0;90mPress any key to return to Yazi...\033[0m"
        read -n 1 -s -r < /dev/tty
    
    # CASE B: Plugin/Internal Commands (e.g., Zoxide)
    else
        # Split the string into words the way a shell would
        # This turns 'plugin zoxide' into ('plugin', 'zoxide')
        set -f
        eval "cmd_args=($RAW_CMD)"
        set +f
        
        # We use 'ya emit' to send the command back to Yazi
        # We don't use 'read' here so the window closes immediately
        ya emit "${cmd_args[@]}"
        exit 0
    fi
fi