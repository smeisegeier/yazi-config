#!/bin/bash

# Ensure exactly one argument is passed
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_or_directory>"
    exit 1
fi

path="$1"

# Check if the file or directory exists
if [ ! -e "$path" ]; then
    echo "'$path' not found."
    exit 1
fi

# If it's a file, get its directory
if [ -f "$path" ]; then
    dir=$(dirname "$path")
elif [ -d "$path" ]; then
    dir="$path"
else
    echo "'$path' is not a valid file or directory."
    exit 1
fi

# Run ncdu on the directory
echo "Running ncdu on directory: $dir"
broot -dph "$dir"