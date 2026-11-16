#!/usr/bin/env bash
# shared "Press any key..." prompt at the end of blocking commands;
# erases the prompt line afterwards so the next output starts on a clean line

printf '\n\033[0;90mPress any key...\033[0m'
read -n 1 -s -r < /dev/tty
printf '\r\033[2K'
