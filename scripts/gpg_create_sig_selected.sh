#!/bin/bash

source $YAZI_CONFIG_HOME/scripts/fzf.sh

# Ensure at least one argument is passed
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <file1> [file2] [...]"
    exit 1
fi

# Select a private key for signing using fzf
selected_key=$(get_gpg_signing_key)

if [ -z "$selected_key" ]; then
    echo "No key selected. Exiting."
    exit 1
fi

echo "Selected key: $selected_key"
echo ""

# Loop through all the passed files
for file in "$@"; do
    # Check if the file exists
    if [ ! -f "$file" ]; then
        echo "File '$file' not found, skipping."
        continue
    fi

    echo "Signing '$file' with key: $selected_key..."
    gpg --local-user "$selected_key" --output "${file}.sig" --armor --detach-sign "$file"

    # Check if gpg succeeded
    if [ $? -eq 0 ]; then
        echo "✓ Signed: $file -> ${file}.sig"
    else
        echo "✗ Failed to sign: $file"
    fi
done

echo ""
echo "Press any key to continue..."
read -n 1