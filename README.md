# file-manager-config

🚧 work in progress 🚧

## pre-install

- if [nerdfonts](https://www.nerdfonts.com) are not installed, consider e.g _hack nerd font_:
- don't forget to set the terminal font after installing

```bash
# all os
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip \ 
&& cd ~/.local/share/fonts && unzip Hack.zip && rm Hack.zip && fc-cache -fv
```

## install

![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey)

- install [homebrew](https://brew.sh) 

```bash
# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```bash
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide imagemagick

git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi

# update packs
ya pack -i

```
<!-- install yazi packages from toml -->

[![windows](https://badgen.net/badge/icon/windows?icon=windows&label)](https://microsoft.com/windows/)

```bash
winget install yazi

# -> config dir
cd ${env:APPDATA}/yazi 2>nul || cd "%APPDATA%"/yazi

# clone into %APPDATA%/yazi/config
git clone https://github.com/smeisegeier/yazi-config ./config

# go there
cd config

# update packs
ya pack -i
```

![linux](https://img.shields.io/badge/Linux-blue?logo=linux&labelColor=grey)

- [nix](https://nixos.org/download/#) is used as homebrew alternative (⚠️ homebrew is not supported on ARM Linux)
- 🚧 `ghostty` may fail on installation

<br>

- clone repository

```bash
git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi
```

- make script executable

```bash
chmod 755 scripts/install_linux.sh
```

- run install script

```bash
./scripts/install_linux.sh
```

- launch

```bash
# run nushell for best experience
nu

# run yazi
y
```
<!-- ```bash
# use this mode (single user) in case SELinux is present (eg. Fedora)
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# run to activate nix
. /home/parallels/.nix-profile/etc/profile.d/nix.sh

# install yazi and all dependencies
export NIXPKGS_ALLOW_UNFREE=1

nix-env -iA nixpkgs.yazi nixpkgs.ffmpeg nixpkgs.p7zip nixpkgs.jq nixpkgs.poppler nixpkgs.fd nixpkgs.ripgrep nixpkgs.fzf nixpkgs.zoxide nixpkgs.imagemagick nixpkgs.vscode ixpkgs.nushell nixpkgs.wezterm nixpkgs.broot nixpkgs.ncdu

# clone into ~/.config
git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi

# update packs
ya pack -i

# echo -e "\nalias y = yazi" >> ~/.config/nushell/config.nu
echo -e "\nalias q = exit" >> ~/.config/nushell/config.nu

y='def --env y [] {
    let tempfile = $"/($env.HOME)/.config/yazi/tempfile"
    yazi --cwd-file=($tempfile)
    let new_dir = (open $tempfile | str trim | default "")
    cd $new_dir
}'

echo ($y) >> ~/.config/nushell/config.nu
``` -->
