#!/bin/bash

# Ensure at least one argument is passed
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <file1.gpg> [file2.gpg] [...]"
    exit 1
fi

# Loop through all the passed files
for file in "$@"; do
    # Check if the file exists
    if [ ! -f "$file" ]; then
        echo "File '$file' not found, skipping."
        continue
    fi

    # Decrypt the file
    echo "Decrypting '$file'..."
    gpg --decrypt --verbose "$file" > "${file%.gpg}"  # Decrypt and save as original filename without .gpg extension

    # Check if gpg succeeded
    if [ $? -eq 0 ]; then
        echo "Decrypted: $file"
    else
        echo "Failed to decrypt: $file"
    fi
done
