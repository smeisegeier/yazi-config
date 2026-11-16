#!/usr/bin/env bash
# fetch origin for the repo in the current dir and show what changed

printf '\n--- [ Git Fetching Remote... ] ---\n'
git fetch origin && git diff HEAD..origin --stat
"$(dirname "$0")/pause.sh"
