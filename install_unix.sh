#!/bin/bash

# Determine the correct path based on OS
if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export_line='export YAZI_CONFIG_HOME="$HOME/.config/yazi"'
elif [[ "$OSTYPE" == "msys" ]]; then
    export_line='export YAZI_CONFIG_HOME="$APPDATA/yazi/config"'
fi   

y_function='function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}'

# Add the export if YAZI_CONFIG_HOME is not set
if ! grep -q "YAZI_CONFIG_HOME" ~/.zshrc 2>/dev/null; then
    echo -e "\n$export_line" >> ~/.zshrc
    echo "YAZI_CONFIG_HOME export added to ~/.zshrc"
fi

# Add the function if it's not already defined
if ! grep -q "function y()" ~/.zshrc 2>/dev/null; then
    echo -e "\n$y_function" >> ~/.zshrc
    echo "Yazi wrapper function added to ~/.zshrc"
fi   