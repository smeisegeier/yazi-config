#!/bin/bash

# Checks if a command exists
command_exists () {
    command -v "$1" >/dev/null 2>&1
}

# Checks for the existence of one or more commands.
# Usage: check_commands cmd1 [cmd2 cmd3 ...]
check_commands() {
    local missing=()
    for check_item in "$@"; do
        if ! command_exists "$check_item"; then
            missing+=("$check_item")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo "Error: The following required utilities are missing: ${missing[*]}" >&2
        return 1
    fi
    return 0
}

function get_os() {
  case "$(uname -s)" in
    Linux*)
      # Check for WSL environment on Linux
      if grep -qi microsoft /proc/version; then
        echo "windows"
      else
        echo "linux"
      fi
      ;;
    Darwin*)
      echo "macos"
      ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      echo "windows"
      ;;
    *)
      # Fallback for unknown OS
      echo "unknown"
      ;;
  esac
}

# Executes a command, pipes output to fzf, and extracts a field using awk.
# Usage: use_fzf "<command>" "<awk_pos>" "<fzf_prompt>"
function use_fzf() {
    local cmd="$1"
    local pos="$2"
    local prompt="${3:-Select option:}"
    local result
    
    if ! check_commands fzf awk; then return 1; fi

    result=$(
        eval "$cmd" 2>/dev/null | \
            fzf --prompt="$prompt" --preview-window=up:1 | \
            awk "{print \$$pos}"
    )

    # Check if the selection was canceled or empty
    if [ -z "$result" ]; then
        return 1
    fi

    # Print the result (the selected value)
    echo "$result"
}


# Pipes content to the appropriate clipboard utility based on OS_NAME.
# Assumes OS_NAME variable is set in the calling environment.
function to_clipboard() {
    # Check if input is piped
    if [ -t 0 ]; then
        echo "Error: to_clipboard expects content piped via stdin." >&2
        return 1
    fi
    
    local os_name="${OS_NAME:-$(get_os)}" # Use $OS_NAME if set, otherwise call get_os
    local clipboard_cmd=""

    case "$os_name" in
        macos)
            clipboard_cmd="pbcopy"
            ;;
        linux)
            clipboard_cmd="wl-copy"
            ;;
        windows)
            clipboard_cmd="clip.exe"
            ;;
    esac

    if [ -n "$clipboard_cmd" ] && command_exists "$clipboard_cmd"; then
        # Use 'cat' to read stdin and pipe to clipboard command
        cat | eval "$clipboard_cmd"
        echo "Content copied to clipboard via $clipboard_cmd." >&2
    else
        echo "Warning: Clipboard utility ('$clipboard_cmd') not found on $os_name. Content printed only." >&2
    fi
}