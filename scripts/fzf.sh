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


function get_log() {
    # if ! check_commands find; then return 1; fi
    local selected
    local os_name="${OS_NAME:-$(get_os)}" # Use $OS_NAME if set, otherwise call get_os
    DELIM=" --- "

    case "$os_name" in
        macos)
            selected=$(use_fzf "START_TIME=\$(date +'%Y-%m-%d 00:00:00'); END_TIME=\$(date +'%Y-%m-%d %H:%M:%S'); log show --start \"\$START_TIME\" --end \"\$END_TIME\" --info --debug --last 1d --predicate 'messageType == 17' | awk '{print \$0}'" "1" "Select Today's Critical Fault Log: ")
            ;;
        linux)
            selected=$(use_fzf "journalctl --since today --priority=3 --no-pager --output cat" "1" "Select Today's Critical Log: ")
            ;;
        windows)
            selected=$(use_fzf "powershell -Command \"Get-WinEvent -LogName System -MaxEvents 500 | Where-Object { \$\_.TimeCreated -ge (Get-Date).AddDays(-1) } | Select-Object TimeCreated,LevelDisplayName,Message | Format-List | Out-String -Stream\"" "1" "Select Recent System Event: ")
            ;;
    esac

    echo "$selected" | to_clipboard
    echo "$selected"
}

function get_installs() {
    # This assumes 'get_os', 'to_clipboard', and 'check_commands' are defined
    local os_name="${OS_NAME:-$(get_os)}"
    local package_list_command=""
    local install_command_prefix=""
    local preview_command="" # Variable to hold the $4 argument
    local selected_package=""
    local final_command_string=""
    local awk_pos="1"        # Package name is typically the first field

    # --- Setup Package Manager Commands ---

    case "$os_name" in
        macos)
            if ! command -v brew &> /dev/null; then echo "Error: brew not found." >&2; return 1; fi
            package_list_command="brew formulae"
            install_command_prefix="brew install"
            preview_command="brew info {}" # Preview command for Homebrew
            ;;
        linux)
            if ! command -v paru &> /dev/null; then echo "Error: paru not found." >&2; return 1; fi
            package_list_command="paru -Slq"
            install_command_prefix="paru -S"
            preview_command="paru -Si {}" # Preview command for Paru
            ;;
        *)
            echo "Error: Unsupported package manager for OS: $os_name" >&2
            return 1
            ;;
    esac

    # --- Execute fzf and Selection ---
    
    # New call: $1: list_cmd, $2: awk_pos, $3: prompt, $4: preview_cmd
    selected_package=$(use_fzf \
        "$package_list_command" \
        "$awk_pos" \
        "Select package(s) to install with $install_command_prefix: " \
        "$preview_command") # This is the new $4 argument

    # Check return status of use_fzf
    if [ $? -ne 0 ]; then
        echo "Selection cancelled or failed. Aborting." >&2
        return 0
    fi

    # 2. Construct the final command string
    final_command_string=$(echo "$selected_package" | xargs -r echo "$install_command_prefix")

    # 3. Output the result
    echo "Command copied to clipboard: $final_command_string"
    echo "$final_command_string" | to_clipboard
    echo "$final_command_string"
}