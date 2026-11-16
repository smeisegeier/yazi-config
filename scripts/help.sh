#!/usr/bin/env bash
# show the help page

glow "${YAZI_CONFIG_HOME:-$HOME/.config/yazi}/help.md"
"$(dirname "$0")/pause.sh"
