#!/bin/bash

# This script must be sourced in your shell startup file (e.g., ~/.zshrc or ~/.bashrc)
# Example: source /path/to/fzf.sh

# A helper function to check if a command exists
command_exists () {
    command -v "$1" >/dev/null 2>&1
}

source ./utils.sh

# -----------------------------------------------------------------------------
# SSH Hash Selection Function
# Prints the hash of the selected SSH key to standard output.
# -----------------------------------------------------------------------------
function get_ssh_hash() {
    if ! command_exists ssh-add || ! command_exists fzf || ! command_exists awk; then
        echo "Error: 'ssh-add', 'fzf', or 'awk' is not installed." >&2
        return 1
    fi

    # List identities from ssh-agent, use fzf for interactive selection
    # and awk to extract the key hash (the second field)
    local selected_hash
    selected_hash=$(ssh-add -l 2>/dev/null | \
        fzf --prompt="Select SSH Key Hash: " --preview-window=up:1 | \
        awk '{print $2}')

    if [ -z "$selected_hash" ]; then
        # Key selection cancelled or no keys found
        return 1
    fi

    local OS_NAME
    OS_NAME=$(get_os)

    # 3. Determine the clipboard command based on OS_NAME
    case "$OS_NAME" in
        macos)
            clipboard_cmd="pbcopy"
            ;;
        linux)
            clipboard_cmd="wl-copy"
            ;;
        windows)
            clipboard_cmd="clip.exe"
            ;;
        *)
            echo "Warning: Unknown OS ('$os_name'). Hash will be printed, but not copied." >&2
            # Set to a non-existent command to skip piping
            clipboard_cmd=""
            ;;
    esac

    # 4. Echo the hash AND pipe it to the clipboard
    echo "$selected_hash" | {
        # Check if the determined clipboard command exists before running
        if [ -n "$clipboard_cmd" ] && command_exists "$(echo "$clipboard_cmd" | awk '{print $1}')"; then
            # Pipe to the clipboard command
            eval "$clipboard_cmd"
            echo "SSH Hash copied to clipboard." >&2
        else
            echo "Warning: Clipboard utility ('$clipboard_cmd') not found. Hash printed only." >&2
        fi
    }

    # Also echo the hash to stdout one final time (redundant if piped above, but ensures output)
    echo "$selected_hash"
}