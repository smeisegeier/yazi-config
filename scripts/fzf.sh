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
    # ps aux -r | head -n 31  
    # ps aux -m | head -n 31  

    # if ! check_commands ps; then return 1; fi
    local selected
    selected=$(use_fzf "ps aux" "2" "select process: ")
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
            selected=$(use_fzf " ")
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

function get_lock() {
    # if ! check_commands find; then return 1; fi

    # * check if a filename argument was provided
    if [ -z "$1" ]; then
        echo "Error: Filename argument is missing." >&2
        return 1
    fi

    local target_file="$1" # Store the argument in a local variable    local selected
    local selected
    local os_name="${OS_NAME:-$(get_os)}" # Use $OS_NAME if set, otherwise call get_os
    DELIM=" --- "

    case "$os_name" in
        macos)
            selected=$(use_fzf "lsof \"$target_file\"" "2" "Select File Lock: ")
            ;;
    esac

    echo "$selected" | to_clipboard
    echo "$selected"
}



function get_packages_available() {
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
        "Select package(s): " \
        "$preview_command") # This is the new $4 argument

    # Check return status of use_fzf
    if [ $? -ne 0 ]; then
        echo "Selection cancelled or failed. Aborting." >&2
        return 0
    fi

    # 2. Construct the final command string
    final_command_string=$(echo "$selected_package" | xargs -r echo "$install_command_prefix")

    # 3. Output the result
    echo "Item copied to clipboard: $selected_package"
    # echo "Command copied to clipboard: $final_command_string"
    echo "$selected_package" | to_clipboard
    echo "$selected_package"
}



# function get_packages_installed() {
#     # This assumes 'get_os', 'to_clipboard', and 'check_commands' are defined
#     local os_name="${OS_NAME:-$(get_os)}"
#     local package_list_command=""       # The command to list INSTALLED packages
#     local install_command_prefix=""     # The command prefix (e.g., install/remove)
#     local preview_command=""            # Variable to hold the $4 argument
#     local selected_package=""
#     local final_command_string=""
#     local awk_pos="1"                   # Package name is typically the first field
    
#     # We are now REMOVING packages, so the prompt and command prefix change
#     local prompt_text="Select installed package(s): "
#     local remove_command_prefix=""

#     # --- Setup Package Manager Commands ---

#     case "$os_name" in
#         macos)
#             if ! command -v brew &> /dev/null; then echo "Error: brew not found." >&2; return 1; fi
            
#             # 💡 CHANGE 1: Use 'brew list' to show installed packages
#             package_list_command="brew list"
            
#             # 💡 CHANGE 2: Update prefix to 'uninstall'
#             remove_command_prefix="brew uninstall"
            
#             # Preview remains 'info' as it shows details on installed/uninstalled packages
#             preview_command="brew info {}"
#             ;;
#         linux)
#             if ! command -v paru &> /dev/null; then echo "Error: paru not found." >&2; return 1; fi
            
#             # 💡 CHANGE 1: Use 'paru -Qq' (or 'pacman -Qq') to list installed packages quietly
#             package_list_command="paru -Qq"
            
#             # 💡 CHANGE 2: Update prefix to 'remove'
#             remove_command_prefix="paru -R" 
            
#             # Preview remains 'Si' for showing info
#             preview_command="paru -Si {}"
#             ;;
#         *)
#             echo "Error: Unsupported package manager for OS: $os_name" >&2
#             return 1
#             ;;
#     esac

#     # --- Execute fzf and Selection ---
    
#     # New call: $1: list_cmd, $2: awk_pos, $3: prompt, $4: preview_cmd
#     selected_package=$(use_fzf \
#         "$package_list_command" \
#         "$awk_pos" \
#         "$prompt_text" \
#         "$preview_command")

#     # Check return status of use_fzf
#     if [ $? -ne 0 ]; then
#         echo "Selection cancelled or failed. Aborting." >&2
#         return 0
#     fi

#     # 2. Construct the final command string
#     # final_command_string=$(echo "$selected_package" | xargs -r echo "$remove_command_prefix")

#     # 3. Output the result
#     echo "Selected package(s) copied to clipboard."
#     # echo "Command copied to clipboard: $final_command_string"
#     echo "$selected_package" | to_clipboard
#     echo "$selected_package"
# }



function get_packages_installed() {
    local os_name="${OS_NAME:-$(get_os)}"
    local package_list_command=""       # The command to list INSTALLED packages
    local preview_command=""            # Holds the plain text package info command
    local selected_package=""
    local awk_pos="1"                   
    
    local prompt_text="Select installed package(s) for info/removal: "

    # --- Setup Package Manager Commands ---

    case "$os_name" in
        macos)
            if ! command -v brew &> /dev/null; then echo "Error: brew not found." >&2; return 1; fi
            
            # List command suppresses stderr to prevent fzf cancellation
            package_list_command="brew list 2>/dev/null"
            
            # 💡 SIMPLIFIED PREVIEW: Direct command, suppressing errors
            preview_command="brew info {} 2>/dev/null"
            # preview_command='sh -c "brew info \"{}\" 2>/dev/null | grep -i --color=always \"Version\""'
            # preview_command='sh -c "brew info \"{}\" 2>/dev/null | grep -i --color=always \"^Version|^Installed|^Conflicts\""'
            # preview_command='sh -c "brew info \"{}\" 2>/dev/null | awk \x27{print \"\x1b[1;37m\" \$0 \"\x1b[0m\"}\x27"'
            ;;
        linux)
            # Check for paru (Arch-based)
            if command -v paru &> /dev/null; then
                package_list_command="paru -Qq"
                
                # 💡 SIMPLIFIED PREVIEW: Direct command, suppressing errors
                preview_command="paru -Si {} 2>/dev/null"
            
            # Check for apt (Debian/Ubuntu-based)
            elif command -v apt &> /dev/null; then
                package_list_command="dpkg-query -W -f='${Package}\n' 2>/dev/null"
                
                # 💡 SIMPLIFIED PREVIEW: Direct command, suppressing errors
                preview_command="apt show {} 2>/dev/null"
            else
                echo "Error: Neither paru nor apt found." >&2; return 1
            fi
            ;;
        *)
            echo "Error: Unsupported OS or package manager not installed." >&2; return 1
            ;;
    esac

    # --- Execute fzf and Selection ---
    
    selected_package=$(use_fzf \
        "$package_list_command" \
        "$awk_pos" \
        "$prompt_text" \
        "$preview_command")

    if [ $? -ne 0 ]; then
        echo "Selection cancelled or failed. Aborting." >&2; return 0
    fi

    # --- Output Result: Only Package Name(s) ---
    echo "Selected package(s) copied to clipboard."
    echo "$selected_package" | to_clipboard
    echo "$selected_package"
}
function get_commands() {
    local selected
    local os_name="${OS_NAME:-$(get_os)}"
    local history_file=""
    local list_command=""
    local preview_command="" # Omitted
    local prompt_text="Select command(s) from history: "

    # 💡 FIX: Force the current session's history to be written to the file
    # for Bash and Zsh compatibility before attempting to read it.
    # This command may fail in Fish/Nushell but shouldn't halt execution.
    history -w 2>/dev/null 

    case "$os_name" in
        macos|linux)
            # 1. Determine Shell/History File
            if [ -n "$ZSH_VERSION" ]; then
                history_file="${HISTFILE:-$HOME/.zsh_history}"
                # Zsh history has timestamps: : 1678888888:0;command
                list_command="cat \"$history_file\" | awk -F';' '{print \$2}'"
            elif [ -n "$BASH_VERSION" ]; then
                history_file="${HISTFILE:-$HOME/.bash_history}"
                list_command="cat \"$history_file\""
            elif [ -n "$FISH_VERSION" ] || command -v fish &> /dev/null && [ -d "$HOME/.config/fish" ]; then
                # Check for Fish shell.
                history_file="$HOME/.local/share/fish/fish_history"
                # Fish history lines start with 'cmd: ', so we filter them out and clean up the output
                list_command="cat \"$history_file\" | grep '^cmd: ' | sed 's/^cmd: //'" 
            elif command -v nu &> /dev/null && [ -d "$HOME/.local/share/nushell" ]; then
                # Nushell history location
                history_file="$HOME/.local/share/nushell/history.txt"
                list_command="cat \"$history_file\""
            else
                echo "Error: Unsupported or unrecognized shell (Bash, Zsh, Fish, or Nushell history not found)." >&2
                return 1
            fi

            # Check if the determined history file exists
            if [ ! -f "$history_file" ]; then
                echo "Error: History file not found at $history_file" >&2
                return 1
            fi
            
            # Preview Command is omitted
            ;;

        windows)
            # Windows PowerShell history location
            history_file="$HOME\\AppData\\Roaming\\Microsoft\\Windows\\PowerShell\\PSReadline\\ConsoleHost_history.txt"
            
            if [ -f "$history_file" ]; then
                list_command="cat \"$history_file\""
            else
                echo "Error: PowerShell history file not found." >&2
                return 1
            fi
            ;;

        *)
            echo "Error: Unsupported OS: $os_name" >&2
            return 1
            ;;
    esac

    # Execute fzf (using list_command, awk_pos=1, prompt, preview_command="")
    selected=$(use_fzf "$list_command" "1" "$prompt_text" "$preview_command")

    # Check return status of use_fzf
    if [ $? -ne 0 ]; then
        echo "Selection cancelled. Aborting." >&2
        return 0
    fi

    # Output the result
    echo "$selected" | to_clipboard
    echo "$selected"
}