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

    echo "signing '$file'..."
    gpg --output "${file}.sig" --armor --detach-sign "$file" # Sign and save the signature with .sig extension

    # Check if gpg succeeded
    if [ $? -eq 0 ]; then
        echo "Signed: $file"
    else
        echo "Failed to sign: $file"
    fi
done
