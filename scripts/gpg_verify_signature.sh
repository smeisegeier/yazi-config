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

# Capture GPG output and check for signature status
gpg_output=$(gpg --verify "$sig_file" "$orig_file" 2>&1)
gpg_status=$?

echo "$gpg_output"

# Check for GOOD or BAD signature
if echo "$gpg_output" | grep -q "gpg: Good signature"; then
    echo -e "\033[0;32m✓ Signature VALID\033[0m"
elif echo "$gpg_output" | grep -q "gpg: BAD signature"; then
    echo -e "\033[0;31m✗ Signature INVALID\033[0m"
fi

echo "Press any key"
read -n 1