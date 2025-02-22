#!/bin/bash

# Ensure at least one argument is passed
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <file_or_folder> [...]"
    exit 1
fi

# Get the basename of the first file
first_file_basename=$(basename "$1")

# Select archive type using fzf, mentioning the basename of the first file
archive_type=$(echo -e "tar.gz\nzip" | fzf --prompt="[$first_file_basename .. ] Choose archive type: ")

# Exit if no selection is made
if [ -z "$archive_type" ]; then
    echo "No archive type selected. Exiting."
    exit 1
fi

# Determine archive name
if [ "$#" -eq 1 ]; then
    # Single file or folder: remove the extension and use basename
    base_name=$(basename "$1")
    archive_name="${base_name%.*}.${archive_type}"
else
    # Multiple files: ask for name, default to nothing (no default shown)
    echo -n "Enter archive name: "
    read -r user_input
    archive_name="${user_input}.${archive_type}"
fi

# Ensure relative paths for all input files
relative_paths=()
for item in "$@"; do
    # Use Python to emulate `realpath --relative-to` if available
    if command -v python3 &>/dev/null; then
        rel_path=$(python3 -c "import os; print(os.path.relpath('$item'))")
    else
        # Fallback: Use the item's basename
        rel_path=$(basename "$item")
    fi
    relative_paths+=("$rel_path")
done

# Create the archive
file_count=${#relative_paths[@]}
if [ "$archive_type" == "tar.gz" ]; then
    tar -czvf "$archive_name" "${relative_paths[@]}"
elif [ "$archive_type" == "zip" ]; then
    zip -r "$archive_name" "${relative_paths[@]}"
else
    echo "Unsupported archive type selected. Exiting."
    exit 1
fi

# Notify user
echo "$file_count files -> $archive_name"
