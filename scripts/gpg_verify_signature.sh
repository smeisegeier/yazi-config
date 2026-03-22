#!/bin/bash

# Ensure exactly one argument is passed
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file.sig>"
    exit 1
fi

sig_file="$1"

# Check if the file exists
if [ ! -f "$sig_file" ]; then
    echo "File '$sig_file' not found."
    exit 1
fi

# Check if the file has .sig extension
if [[ "$sig_file" != *.sig ]]; then
    echo "File '$sig_file' must have .sig extension."
    exit 1
fi

# Derive the original file by removing .sig extension
orig_file="${sig_file%.sig}"

# Check if the original file exists
if [ ! -f "$orig_file" ]; then
    echo "Original file '$orig_file' not found."
    exit 1
fi

gpg --verify "$sig_file" "$orig_file"

echo "Press any key"
read -n 1