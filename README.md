# file-manager-config

[yazi](https://github.com/sxyazi/yazi) release `26.1.22` is used here

## keymappings

[see markdown](./help.md)

## pre-install

- if [nerdfonts](https://www.nerdfonts.com) are not installed, consider e.g _hack nerd font_:
- don't forget to set the terminal font after installing

```bash
# all os
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip && cd ~/.local/share/fonts && unzip Hack.zip && rm Hack.zip && fc-cache -fv
```

## install on unix

**![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey) install [homebrew](https://brew.sh/) if not present**

<br>

**![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey) install dependencies** <small>(this assumes [vscode](https://code.visualstudio.com/) is installed already)</small>

```bash
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide imagemagick broot nushell ouch ncdu nbpreview rich-cli glow mactag librsvg ffmpegthumbnailer resvg mediainfo tree
```

<br>

**![linux](https://img.shields.io/badge/Linux-blue?logo=linux&labelColor=grey) install dependencies**<small> (this assumes [vscode](https://code.visualstudio.com/) is installed already)</small>

```bash
# example usage on arch linux
# as for terminal: any will do (kitty, alacritty, ghostty etc)
# install dependencies beyond what yazi already did
sudo pacman -S yazi nushell broot ncdu code ouch nbpreview rich-cli glow
```
<br>

**![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey) ![linux](https://img.shields.io/badge/Linux-blue?logo=linux&labelColor=grey) clone config**

```bash
git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi
```
<br>

**![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey) ![linux](https://img.shields.io/badge/Linux-blue?logo=linux&labelColor=grey) execute launch script**

```bash
cd ~/.config/yazi && chmod 755 install_unix.sh && ./install_unix.sh
```

## install on windows
> [!WARNING]
> **[![windows](https://badgen.net/badge/icon/windows?icon=windows&label)](https://microsoft.com/windows/) install currently not supported**

<!-- ```bash
# try nerdfonts install
winget install DEVCOM.JetBrainsMonoNerdFont

winget install sxyazi.yazi Gyan.FFmpeg 7zip.7zip jqlang.jq sharkdp.fd BurntSushi.ripgrep.MSVC junegunn.fzf ajeetdsouza.zoxide ImageMagick.ImageMagick

cd ${env:APPDATA} && mkdir yazi 

# -> config dir
# cd ${env:APPDATA}/yazi 2>nul || cd "%APPDATA%"/yazi

# clone into %APPDATA%/yazi/config
git clone https://github.com/smeisegeier/yazi-config ./config

``` -->


## launch

```bash
# run yazi after restart zsh
y

# debug mode (debug | info | warn | error) -> log is in ~/.local/state/yazi/yazi.log
YAZI_LOG=info yazi
```

## hints

> [!INFO]
> - for remote ssh connect use [vfs](https://yazi-rs.github.io/docs/next/configuration/vfs/) logic
