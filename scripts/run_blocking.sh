#!/bin/bash

echo "dir: $(pwd)"
read -e -p '$ ' cmd

if [ -n "$cmd" ]; then
    eval "$cmd"
fi

echo
read -n 1 -s -r -p "Press any key to continue..."
echo
