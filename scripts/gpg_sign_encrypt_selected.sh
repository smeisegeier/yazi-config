#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [-s] <file1> <file2> [...]"
    echo "  -s    Sign the files during encryption"
    exit 1
}

# Parse options
sign=false
while getopts "s" opt; do
    case $opt in
        s) sign=true ;;
        *) usage ;;
    esac
done
shift $((OPTIND -1))

# Ensure at least one file is passed
if [ "$#" -lt 1 ]; then
    usage
fi

# Get the list of available public keys
gpg_keys=$(gpg --list-keys --with-colons | awk -F: '/^pub/ {key=$5} /^uid/ {print key, $10}')

if [ -z "$gpg_keys" ]; then
    echo "No GPG public keys found in the keyring."
    exit 1
fi

# Select a public key for encryption
selected_pub_key=$(echo "$gpg_keys" | fzf --prompt="Select recipients public key to ENCRYPT with: " --preview="echo {}" --preview-window=up:1)
if [ -z "$selected_pub_key" ]; then
    echo "No key selected. Exiting."
    exit 1
fi
selected_pub_key_id=$(echo "$selected_pub_key" | awk '{print $1}')

# If signing is requested, select a private key
if [ "$sign" = true ]; then
    gpg_sec_keys=$(gpg --list-secret-keys --with-colons | awk -F: '/^sec/ {key=$5} /^uid/ {print key, $10}')
    if [ -z "$gpg_sec_keys" ]; then
        echo "No GPG secret keys found in the keyring."
        exit 1
    fi
    selected_sec_key=$(echo "$gpg_sec_keys" | fzf --prompt="Select own private key to SIGN with: " --preview="echo {}" --preview-window=up:1)
    if [ -z "$selected_sec_key" ]; then
        echo "No key selected for signing. Exiting."
        exit 1
    fi
    selected_sec_key_id=$(echo "$selected_sec_key" | awk '{print $1}')
fi

# Process each file
for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "File $file does not exist. Skipping."
        continue
    fi

    if [ "$sign" = true ]; then
        gpg --encrypt --sign --local-user "$selected_sec_key_id" --recipient "$selected_pub_key_id" --output "${file}.gpg" "$file"
    else
        gpg --encrypt --recipient "$selected_pub_key_id" --output "${file}.gpg" "$file"
    fi

    if [ $? -eq 0 ]; then
        echo "File '$file' processed successfully."
    else
        echo "Error processing '$file'."
    fi
done
