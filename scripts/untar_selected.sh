#!/bin/bash

# Check if at least one file argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <archive1.tar.gz> [archive2.zip] [archive3.7z] ..."
    exit 1
fi

# Skip macOS AppleDouble (._*) and resource fork entries
tar_excludes=(--exclude "._*" --no-xattrs)
# --no-mac-metadata only exists in bsdtar (macOS), GNU tar (Linux) rejects it
if tar --version 2>/dev/null | grep -q bsdtar; then
    tar_excludes+=(--no-mac-metadata)
fi
zip_excludes=("__MACOSX/*" "._*" "*/._*")
sevenzip_excludes=('-xr!._*' '-xr!__MACOSX')

# 7-Zip is 7zz on macOS (Homebrew), 7z on most Linux distros
sevenzip=$(command -v 7zz || command -v 7z)

# Loop through all arguments
for archive in "$@"; do
    # Check if the file exists
    if [ ! -f "$archive" ]; then
        echo "Skipping '$archive': File does not exist."
        continue
    fi

    # Pick extractor and strip the archive extension(s) for the folder name
    name=$(basename "$archive")
    shopt -s nocasematch
    case "$name" in
        *.tar.gz|*.tar.bz2|*.tar.xz|*.tar.zst)
            tool=tar; folder="${name%.tar.*}" ;;
        *.tgz|*.tbz|*.tbz2|*.txz|*.tar)
            tool=tar; folder="${name%.*}" ;;
        *.zip)
            tool=zip; folder="${name%.*}" ;;
        *.*)
            tool=7z; folder="${name%.*}" ;;
        *)
            echo "Skipping '$archive': Unsupported file type."
            continue ;;
    esac
    shopt -u nocasematch

    if [ "$tool" == "7z" ] && [ -z "$sevenzip" ]; then
        echo "Skipping '$archive': 7zz/7z not installed."
        continue
    fi

    echo "Processing '$archive'..."

    # Extract into a temporary directory next to the archive
    dest_dir=$(dirname "$archive")
    tmp_dir=$(mktemp -d "$dest_dir/.extract.XXXXXX")

    case "$tool" in
        tar) tar -xvf "$archive" "${tar_excludes[@]}" -C "$tmp_dir" ;;
        zip) unzip "$archive" -d "$tmp_dir" -x "${zip_excludes[@]}" ;;
        7z)  "$sevenzip" x -y -o"$tmp_dir" "$archive" "${sevenzip_excludes[@]}" ;;
    esac
    if [ $? -ne 0 ]; then
        echo "Error: extracting '$archive' failed."
        rm -rf "$tmp_dir"
        continue
    fi

    # Single top-level entry: move it up, otherwise wrap everything in a folder
    entries=()
    for e in "$tmp_dir"/* "$tmp_dir"/.[!.]*; do
        [ -e "$e" ] && entries+=("$e")
    done
    if [ ${#entries[@]} -eq 1 ] && [ ! -e "$dest_dir/$(basename "${entries[0]}")" ]; then
        mv "${entries[0]}" "$dest_dir/"
        rm -rf "$tmp_dir"
    else
        target="$dest_dir/$folder"
        if [ -e "$target" ]; then
            target="$target-$(date +%Y%m%d%H%M%S)"
        fi
        mv "$tmp_dir" "$target"
    fi

    echo "Extraction of '$archive' completed."
done
