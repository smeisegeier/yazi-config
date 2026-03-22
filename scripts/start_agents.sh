#!/bin/bash

# --- 1. Initial Status Check ---
echo -e "\033[0;34m--- Current Agent Status ---\033[0m"

# Check GPG Cached Passphrases
GPG_CACHED=$(gpg-connect-agent 'keyinfo --list' /bye | grep -c " 1 ")
echo -e "GPG Passphrases Cached: \033[0;33m$GPG_CACHED\033[0m"

# Check SSH Identities
if ssh-add -l > /dev/null 2>&1; then
    SSH_COUNT=$(ssh-add -l | wc -l | xargs)
    echo -e "SSH Identities Loaded:  \033[0;33m$SSH_COUNT\033[0m"
else
    echo -e "SSH Identities Loaded:  \033[0;31m0 (Agent Empty/Off)\033[0m"
fi

# --- 2. Interactive Prompt ---
echo -ne "\n\033[0;36mRefresh and Re-authenticate? (y/N): \033[0m"
read -n 1 -r REPLY < /dev/tty
echo # Move to a new line

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# --- 3. GPG Refresh ---
echo -e "\n\033[0;34m[ GPG ] Killing & Restarting Agent...\033[0m"
gpgconf --kill gpg-agent
gpg-connect-agent "UPDATESTARTUPTTY" /bye > /dev/null 2>&1

# Trigger test sign to link TTY and cache passphrase
echo "test" | gpg --clearsign --dry-run > /dev/null 2>&1

# --- 4. SSH Refresh ---
echo -e "\033[0;34m[ SSH ] Verifying Keys...\033[0m"
if ! ssh-add -l > /dev/null 2>&1; then
    echo "No identities. Please add your SSH key:"
    ssh-add
else
    ssh-add -l | awk '{print "Loaded: \033[0;33m" $3 "\033[0m"}'
fi

# --- 5. Final Success ---
echo -e "\n\033[0;32m[ ✔ ] Agents Synced and Verified\033[0m"
echo "Press any key to return to Yazi..."
read -n 1 < /dev/tty