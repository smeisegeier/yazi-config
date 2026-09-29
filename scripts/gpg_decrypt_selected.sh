#!/bin/bash

# Ensure at least one argument is passed
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <file1.gpg> [file2.pgp] [...]"
    exit 1
fi

# Loop through all the passed files
for file in "$@"; do
    # Check if the file exists
    if [ ! -f "$file" ]; then
        echo "File '$file' not found, skipping."
        continue
    fi

    # Derive the output filename by stripping a known encrypted-file extension.
    # If none matches, fall back to appending .decrypted so we never collide
    # with the input file.
    case "$file" in
        *.gpg) out="${file%.gpg}" ;;
        *.pgp) out="${file%.pgp}" ;;
        *.asc) out="${file%.asc}" ;;
        *)     out="${file}.decrypted" ;;
    esac

    # Safety net: never let the output path equal the input path, since that
    # would truncate the source file before gpg can read it.
    if [ "$out" = "$file" ]; then
        out="${file}.decrypted"
    fi

    # Decrypt to a temp file in the same directory first, so a failed or
    # partial decryption never touches the original encrypted file or
    # clobbers an existing output file.
    tmp_out="$(mktemp "${out}.XXXXXX")"

    echo "Decrypting '$file'..."
    gpg --decrypt --skip-verify --pinentry-mode loopback --verbose "$file" > "$tmp_out"
    status=$?

    if [ $status -eq 0 ] && [ -s "$tmp_out" ]; then
        mv -f "$tmp_out" "$out"
        echo "Decrypted: $file -> $out"
    else
        rm -f "$tmp_out"
        echo "Failed to decrypt: $file"
    fi
done
