#!/bin/bash

# This script must be sourced in your shell startup file (e.g., ~/.zshrc or ~/.bashrc)
# Example: source /path/to/fzf.sh

source $HOME/.config/yazi/scripts/utils.sh

# OS_NAME=$(get_os)

# -----------------------------------------------------------------------------
# SSH Hash Selection Function
# Prints the hash of the selected SSH key to standard output AND copies it.
# -----------------------------------------------------------------------------
function get_ssh_hash() {
    # 1. Check basic utilities (ssh-add is checked implicitly by use_fzf)
    # if ! check_commands ssh-add; then
    #     return 1
    # fi

    # 2. Use the helper function to select and extract the hash (position 2)
    local selected
    selected=$(
        use_fzf "ssh-add -l" "2" "Select SSH Key Hash: "
    )

    # 3. Echo the hash, pipe it to the clipboard function, and then echo again
    # to ensure the final output is available for command substitution.
    echo "$selected" | to_clipboard

    # Print the selected hash to standard output
    echo "$selected"
}


function get_ps() {
    # if ! check_commands ps; then return 1; fi
    local selected
    selected=$(use_fzf "ps aux" "2" "select process: ")
    echo "$selected" | to_clipboard
    echo "$selected"
}

function get_recent_files() {
    # if ! check_commands find; then return 1; fi
    local selected
    selected=$(use_fzf "find . -type f -mtime -7 -print" "1" "Open Recent File: ")
    echo "$selected" | to_clipboard
    echo "$selected"
}

function get_gpg() {
    # if ! check_commands find; then return 1; fi
    local selected
    selected=$(use_fzf "gpg --list-secret-keys --with-colons | awk -F: '/^sec/ {key=\$5} /^uid/ {print key, \$10}'" "1" "Select GPG Key ID: ")
    echo "$selected" | to_clipboard
    echo "$selected"
}
function get_disk() {
    # if ! check_commands find; then return 1; fi
    local selected
    local os_name="${OS_NAME:-$(get_os)}" # Use $OS_NAME if set, otherwise call get_os
    DELIM=" --- "

    case "$os_name" in
        macos)
            selected=$(use_fzf "diskutil list | grep -E '^\s*([0-9]|Container)' | awk '{print \$4\"$DELIM\"\$5 \$6\"$DELIM\"\$NF}'" "4" "Select Disk Identifier: ")            
            ;;
        linux)
            selected=$(use_fzf "lsblk -l -o UUID,NAME,SIZE,MOUNTPOINT,FSTYPE,LABEL" "1" "Select Block Device UUID: ")
            ;;
        windows)
            selected=$(use_fzf "wmic diskdrive get Caption,Size,InterfaceType /value | findstr /R \"^Caption=.* ^Size=.*\" | awk -F= '{ORS=NR%2?\" \":\"\\n\"; print \$2}'" "1" "Select Disk Drive: ")
            ;;
    esac

    echo "$selected" | to_clipboard
    echo "$selected"
}


