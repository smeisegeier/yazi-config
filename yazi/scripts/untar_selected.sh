#!/bin/bash

# Check if at least one file argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <archive1.tar.gz> [archive2.zip] ..."
    exit 1
fi

# Loop through all arguments
for archive in "$@"; do
    # Get the file extension and base name
    extension="${archive##*.}"
    base_name="${archive%.*}"

    # Determine the folder name to extract into
    if [[ "$extension" == "gz" || "$extension" == "tar" ]]; then
        folder="${base_name%.*}"  # Remove .tar.gz
    elif [ "$extension" == "zip" ]; then
        folder="${base_name}"  # Remove .zip
    else
        echo "Skipping '$archive': Unsupported file type."
        continue
    fi

    # Check if the file exists
    if [ ! -f "$archive" ]; then
        echo "Skipping '$archive': File does not exist."
        continue
    fi

    echo "Processing '$archive'..."

    # Create a temporary directory to inspect the archive
    tmp_dir=$(mktemp -d)

    if [[ "$extension" == "gz" || "$extension" == "tar" ]]; then
        # Inspect tar.gz archive
        tar -tzf "$archive" > "$tmp_dir/filelist" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "Error: '$archive' is not a valid tar.gz file."
            rm -rf "$tmp_dir"
            continue
        fi
    elif [ "$extension" == "zip" ]; then
        # Inspect zip archive
        unzip -l "$archive" > "$tmp_dir/filelist" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "Error: '$archive' is not a valid zip file."
            rm -rf "$tmp_dir"
            continue
        fi
    fi

    # Check if the archive contains a single top-level folder
    if [[ "$extension" == "gz" || "$extension" == "tar" ]]; then
        top_level_folder=$(awk -F/ 'NF==1 {print $1}' "$tmp_dir/filelist" | sort -u)
    elif [ "$extension" == "zip" ]; then
        top_level_folder=$(awk '/^[ ]+[0-9]/ {print $NF}' "$tmp_dir/filelist" | awk -F/ 'NF==1 {print $1}' | sort -u)
    fi

    num_top_level=$(echo "$top_level_folder" | wc -l)

    # Handle extraction based on the archive structure
    if [ "$num_top_level" -eq 1 ]; then
        # Archive already contains a top-level folder
        if [[ "$extension" == "gz" || "$extension" == "tar" ]]; then
            tar -xzvf "$archive"
        elif [ "$extension" == "zip" ]; then
            unzip "$archive"
        fi
    else
        # Extract the archive into a new folder
        mkdir -p "$folder"
        if [[ "$extension" == "gz" || "$extension" == "tar" ]]; then
            tar -xzvf "$archive" -C "$folder"
        elif [ "$extension" == "zip" ]; then
            unzip "$archive" -d "$folder"
        fi
    fi

    # Cleanup
    rm -rf "$tmp_dir"
    echo "Extraction of '$archive' completed."
done
