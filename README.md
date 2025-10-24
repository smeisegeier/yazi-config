# file-manager-config

⚠️ this config is still a mess. it now points to yazi version `25.2.11` to have a consistent behaviour and to _not break on update_

## pre-install

- if [nerdfonts](https://www.nerdfonts.com) are not installed, consider e.g _hack nerd font_:
- don't forget to set the terminal font after installing

```bash
# all os
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip && cd ~/.local/share/fonts && unzip Hack.zip && rm Hack.zip && fc-cache -fv
```

## install

![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey)

- clearly use [homebrew](https://brew.sh) here

```bash
# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```bash
# install yazi on specific version
brew install yazi@25.2.11

# install dependencies
brew install ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide imagemagick broot nushell vscode ouch ncdu

git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi

# update packs
ya pack -i

```
<!-- install yazi packages from toml -->

[![windows](https://badgen.net/badge/icon/windows?icon=windows&label)](https://microsoft.com/windows/)

**⚠️ outdated**

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

![linux](https://img.shields.io/badge/Linux-blue?logo=linux&labelColor=grey)

- exampls useage on arch linux
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
# http
git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi

# get specific version
cd ~/Downloads
wget https://archive.archlinux.org/packages/y/yazi/yazi-25.2.11-1-x86_64.pkg.tar.zst
sudo pacman -U yazi-25.2.11-1-x86_64.pkg.tar.zst

# install dependencies beyond what yazi already did
sudo pacman -S nushell broot ncdu code ouch

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

- launch

```bash
# run yazi
y

# debug mode (debug | info | warn | error)
YAZI_LOG=info yazi

# after launch log is in ~/.local/state/yazi/yazi.log
```
