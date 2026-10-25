#!/usr/bin/env bash
# show the help page

glow "${YAZI_CONFIG_HOME:-$HOME/.config/yazi}/help.md"
printf '\n\033[0;90mPress any key...\033[0m\n'
read -n 1 < /dev/tty
