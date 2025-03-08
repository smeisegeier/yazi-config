#!/bin/bash

# Ensure at least one file is passed
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <file1> <file2> [...]"
    exit 1
fi

# Get the list of available public keys with details (key ID, user name, email, and comment)
gpg_keys=$(gpg --list-keys --with-colons | awk -F: '/^pub/ {key=$5} /^uid/ {print key, $10}')

# If no keys found, exit
if [ -z "$gpg_keys" ]; then
    echo "No GPG keys found in the keyring."
    exit 1
fi

# Use fzf to select a GPG key from the list, showing both the key ID and the associated user name
selected_key=$(echo "$gpg_keys" | fzf --prompt="Select GPG key to encrypt with: " --preview="echo {}" --preview-window=up:1)

# If no key was selected, exit
if [ -z "$selected_key" ]; then
    echo "No key selected. Exiting."
    exit 1
fi

# Extract the selected key ID from the chosen entry (the first part before the space)
selected_key_id=$(echo "$selected_key" | awk '{print $1}')

# Encrypt each passed file using the selected GPG key
for file in "$@"; do
    # Check if file exists
    if [ ! -f "$file" ]; then
        echo "File $file does not exist. Skipping."
        continue
    fi

    # Encrypt the file using GPG with the selected public key
    gpg --encrypt --recipient "$selected_key_id" --output "${file}.gpg" "$file"

    if [ $? -eq 0 ]; then
        echo "File '$file' encrypted successfully."
    else
        echo "Error encrypting '$file'."
    fi
done
