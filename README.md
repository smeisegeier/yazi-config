# file-manager-config

this uses **current** yazi release `25.5.31`

## pre-install

- if [nerdfonts](https://www.nerdfonts.com) are not installed, consider e.g _hack nerd font_:
- don't forget to set the terminal font after installing

```bash
# all os
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip && cd ~/.local/share/fonts && unzip Hack.zip && rm Hack.zip && fc-cache -fv
```

## install
### 1) ![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey)

<!-- - clearly use [homebrew](https://brew.sh) here -->

```bash
# install homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

<!-- 
cd ~/.config/yazi

# install yazi on specific version, this wont work with brew
mkdir .yazi_tmp && unzip -d .yazi_tmp assets/yazi-aarch64-apple-darwin_25_4_3.zip && rm -f ~/.local/bin/{yazi,ya} && mv .yazi_tmp/*/yazi ~/.local/bin/yazi && mv .yazi_tmp/*/ya ~/.local/bin/ya && chmod +x ~/.local/bin/{yazi,ya} && rm -rf .yazi_tmp

# ⚠️ allow this binary to run, overrides macos security
xattr -d com.apple.quarantine ~/.local/bin/yazi; 
-->

```bash

# install dependencies. this assumes vscode is installed already
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide imagemagick broot nushell ouch ncdu nbpreview rich-cli glow mactag

git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi

```

### 2) ![linux](https://img.shields.io/badge/Linux-blue?logo=linux&labelColor=grey)

- example useage on arch linux
- as for terminal: any will do (kitty, alacritty, ghostty etc)

<br>

<!-- <br>

- make script executable

```bash
chmod 755 scripts/install_linux.sh
```

<br>

- run install script

```bash
./scripts/install_linux.sh

git clone https://github.com/yazi-rs/flavors.git ~/.config/yazi/flavors

# update packs
ya pack -i
``` -->

```bash
# install dependencies beyond what yazi already did
sudo pacman -S yazi nushell broot ncdu code ouch nbpreview rich-cli glow

git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi
```

### 3) [![windows](https://badgen.net/badge/icon/windows?icon=windows&label)](https://microsoft.com/windows/) **⚠️ outdated**

```bash
# try nerdfonts install
winget install DEVCOM.JetBrainsMonoNerdFont

winget install sxyazi.yazi Gyan.FFmpeg 7zip.7zip jqlang.jq sharkdp.fd BurntSushi.ripgrep.MSVC junegunn.fzf ajeetdsouza.zoxide ImageMagick.ImageMagick

cd ${env:APPDATA} && mkdir yazi 

# -> config dir
# cd ${env:APPDATA}/yazi 2>nul || cd "%APPDATA%"/yazi

# clone into %APPDATA%/yazi/config
git clone https://github.com/smeisegeier/yazi-config ./config

# go there
cd config

# update packs
ya pack -i
```

## customization

```bash
# start / quit nushell once to get a config
nu
exit

# add alias, now always quit using 'q'
echo -e "\nalias q = exit" >> ~/.config/nushell/config.nu

# ensure these are run in zsh: add func to cd into last dir for nushell
y='def --env y [] {
    let tempfile = $"/($env.HOME)/.config/yazi/tempfile"
    yazi --cwd-file=($tempfile)
    let new_dir = (open $tempfile | str trim | default "")
    cd $new_dir
}'
echo "$y" >> ~/.config/nushell/config.nu

# now the zsh version
y='function y() {
    # This creates a unique, absolute path in /tmp/
    local tmp="$(mktemp -u --tmpdir="/tmp" "yazi-cwd.XXXXXX")"
    local cwd

    # Run yazi with the absolute path
    yazi "$@" --cwd-file="$tmp"

    # Read the file
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi

    rm -f -- "$tmp"
}'
echo "$y" >> ~/.zshrc
```

## launch

- after restart / sourcing of zsh and nushell

```bash
# run yazi
y

# debug mode (debug | info | warn | error)
YAZI_LOG=info yazi

# after launch log is in ~/.local/state/yazi/yazi.log
```
