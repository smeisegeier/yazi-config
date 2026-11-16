#!/bin/bash

echo "dir: $(pwd)"
read -e -p '$ ' cmd

if [ -n "$cmd" ]; then
    eval "$cmd"
fi

"$(dirname "$0")/pause.sh"
