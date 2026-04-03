#!/bin/zsh

# Path to your keymap
KEYMAP="$HOME/.config/yazi/keymap.toml"

# 1. Extract, Filter, and Clean
# - The :a loop removes all "," and spaces between quotes inside [ ]
LIST=$(grep -E '^[[:space:]]*\{[^#]*on =' "$KEYMAP" | sed -E '
    :a
    s/(on = \[.*)"[[:space:]]*,[[:space:]]*"([^"]*".*\])/\1\2/
    ta
    s/^[[:space:]]*\{[[:space:]]*on = \[ "([^"]+)" \],[[:space:]]*run = "([^"]+)",[[:space:]]*desc = "([^"]+)".*/\1 | \3 | \2/p
    d
')

# 2. Safety check
if [[ -z "$LIST" ]]; then
    echo "❌ No active keymaps found."
    read -k 1 < /dev/tty
    exit 1
fi

# 3. Show in FZF
SELECTION=$(echo "$LIST" | fzf --ansi \
    --header "Keys         | Description                         " \
    --delimiter " \| " \
    --with-nth 1,2)

# 4. Execute
if [[ -n "$SELECTION" ]]; then
    RAW_CMD=$(echo "$SELECTION" | sed 's/^.* | .* | //')
    
    # CASE A: Shell Commands (e.g., SSH Hash script)
    if [[ "$RAW_CMD" =~ "^shell " ]]; then
        CLEAN_CMD=$(echo "$RAW_CMD" | sed -E "s/^shell //; s/ --block$//; s/^['\"]//; s/['\"]$//")
        echo -e "\033[0;34m⚡ Executing Shell: $CLEAN_CMD\033[0m\n"
        eval "$CLEAN_CMD"
        echo -e "\n\033[0;90mPress any key to return to Yazi...\033[0m"
        read -k 1 < /dev/tty
    
    # CASE B: Plugin/Internal Commands (e.g., Zoxide)
    else
        # Use Zsh (z) flag to split the string into a proper array
        # This turns 'plugin zoxide' into ('plugin', 'zoxide')
        local -a cmd_args
        cmd_args=(${(z)RAW_CMD})
        
        # We use 'ya emit' to send the command back to Yazi
        # We don't use 'read' here so the window closes immediately
        ya emit "${cmd_args[@]}"
        exit 0
    fi
fi