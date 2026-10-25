#!/usr/bin/env bash
# fetch origin for the repo in the current dir and show what changed

printf '\n--- [ Git Fetching Remote... ] ---\n'
git fetch origin && git diff HEAD..origin --stat
printf '\n\033[0;90mPress any key to return to Yazi...\033[0m\n'
read -n 1 < /dev/tty
