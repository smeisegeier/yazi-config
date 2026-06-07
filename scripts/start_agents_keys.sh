#!/bin/bash

source "$(dirname "$0")/utils.sh"

# --- Build combined key list ---

# GPG: check per-key if passphrase is cached via pinentry-mode error (no prompt)
gpg_entries=""
while IFS= read -r raw; do
    key_id=$(echo "$raw" | awk '{print $1}')
    uid=$(echo "$raw" | cut -d' ' -f2-)
    if gpg --clearsign --local-user "$key_id" --output /dev/null --batch --pinentry-mode error <<< "test" 2>/dev/null; then
        status="✔"
    else
        status="·"
    fi
    gpg_entries+="[GPG] $status $key_id $uid"$'\n'
done < <(gpg --list-secret-keys --with-colons 2>/dev/null | awk -F: '
    /^sec/ { key=$5 }
    /^uid/ { print key " " $10 }
')

# SSH: collect loaded fingerprints once, then compare per key file
ssh_entries=""
loaded_fps=$(ssh-add -l 2>/dev/null)
if [ -d "$HOME/.ssh" ]; then
    while IFS= read -r keyfile; do
        if head -1 "$keyfile" 2>/dev/null | grep -qE "PRIVATE KEY|BEGIN OPENSSH"; then
            comment=""
            if [ -f "${keyfile}.pub" ]; then
                comment=$(awk '{print $NF}' "${keyfile}.pub")
            fi
            fp=$(ssh-keygen -lf "$keyfile" 2>/dev/null | awk '{print $2}')
            if echo "$loaded_fps" | grep -qF "$fp"; then
                status="✔"
            else
                status="·"
            fi
            ssh_entries+="[SSH] $status ${keyfile}${comment:+ ($comment)}"$'\n'
        fi
    done < <(find "$HOME/.ssh" -maxdepth 1 -type f \
        ! -name "*.pub" ! -name "config" ! -name "known_hosts" \
        ! -name "authorized_keys" ! -name "*.old" ! -name "*.bak" \
        2>/dev/null | sort)
fi

# Merge and strip blank lines
all_entries=$(printf '%s\n%s' "$gpg_entries" "$ssh_entries" | sed '/^[[:space:]]*$/d')

if [ -z "$all_entries" ]; then
    echo "No GPG or SSH keys found."
    exit 1
fi

# --- fzf selection ---
selected=$(echo "$all_entries" | fzf \
    --prompt="Select key to authenticate: " \
    --header="✔ = cached in agent  · = not cached  |  [GPG] test-sign  [SSH] ssh-add" \
    --preview="echo {}" \
    --preview-window=up:2)

if [ -z "$selected" ]; then
    echo "Aborted."
    exit 0
fi

# --- Dispatch ---
if [[ "$selected" == \[GPG\]* ]]; then
    key_id=$(echo "$selected" | awk '{print $3}')
    echo -e "\n\033[0;34m[ GPG ] Signing test string with key $key_id...\033[0m"
    echo -e "\033[0;36m        Enter passphrase if prompted.\033[0m"
    gpg --clearsign --local-user "$key_id" --output /dev/null <<< "test"
    if [ $? -eq 0 ]; then
        fingerprint=$(gpg --with-colons --fingerprint "$key_id" 2>/dev/null | awk -F: '/^fpr/ {print $10; exit}')
        echo -e "\033[0;32m[ ✔ ] GPG key $key_id cached in agent\033[0m"
        echo -e "\033[0;33m      Fingerprint: $fingerprint\033[0m"
        echo "$fingerprint" | to_clipboard
        echo -e "\033[0;36m      Copied to clipboard.\033[0m"
    else
        echo -e "\033[0;31m[ ✗ ] GPG signing failed\033[0m"
    fi

elif [[ "$selected" == \[SSH\]* ]]; then
    key_path=$(echo "$selected" | sed 's/^\[SSH\] [✔·] //' | sed 's/ (.*//')
    echo -e "\n\033[0;34m[ SSH ] Adding $key_path to agent...\033[0m"
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)"
    fi
    ssh-add "$key_path"
    if [ $? -eq 0 ]; then
        fingerprint=$(ssh-keygen -lf "$key_path" 2>/dev/null | awk '{print $2}')
        echo -e "\033[0;32m[ ✔ ] SSH key loaded into agent\033[0m"
        echo -e "\033[0;33m      Fingerprint: $fingerprint\033[0m"
        echo "$fingerprint" | to_clipboard
        # echo -e "\033[0;36m      Copied to clipboard.\033[0m"
    else
        echo -e "\033[0;31m[ ✗ ] Failed to add SSH key\033[0m"
    fi
fi

echo -e "\nPress any key..."
read -n 1 < /dev/tty
