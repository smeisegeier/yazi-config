#!/bin/bash
# install_unix.sh - set up this yazi config on macOS or Linux
# usage:  bash install_unix.sh   (works from the cloned repo or as a standalone download)

# 0. unix only, windows has its own installer
if [[ "$OSTYPE" == "darwin"* ]]; then
    os="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    os="linux"
else
    echo "Unsupported OS ($OSTYPE). On Windows use install_windows.ps1."
    exit 1
fi

cfg="$HOME/.config/yazi"

# 1. dependencies (vscode is assumed to be installed already)
if [[ "$os" == "macos" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # make brew usable in this session (apple silicon or intel prefix)
        for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
            [ -x "$b" ] && eval "$("$b" shellenv)" && break
        done
    fi
    brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide imagemagick broot nushell ouch ncdu \
        nbpreview rich-cli glow mactag librsvg ffmpegthumbnailer resvg mediainfo tree tag
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed yazi nushell broot ncdu code ouch nbpreview rich-cli glow
else
    echo "No pacman found: install yazi and its dependencies with your package manager (see README)."
fi

# 2. nerd font, if none is installed yet
if [[ "$os" == "macos" ]]; then
    if ! ls ~/Library/Fonts /Library/Fonts 2>/dev/null | grep -qi "nerd"; then
        brew install --cask font-hack-nerd-font
        font_added=1
    fi
elif ! fc-list 2>/dev/null | grep -qi "nerd"; then
    mkdir -p ~/.local/share/fonts
    curl -fL -o /tmp/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip \
        && unzip -o -q /tmp/Hack.zip -d ~/.local/share/fonts && rm /tmp/Hack.zip && fc-cache -f
    font_added=1
fi

# 3. clone the config, unless it is already there
if [ ! -d "$cfg/.git" ]; then
    git clone https://github.com/smeisegeier/yazi-config "$cfg"
fi

# 4. shell setup in ~/.zshrc
export_line='export YAZI_CONFIG_HOME="$HOME/.config/yazi"'

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

echo -e "\nDone. Restart zsh, then run: y"
[ -n "$font_added" ] && echo "Hack Nerd Font was installed: set it as your terminal font."
