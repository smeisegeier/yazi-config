# file-manager-config

[yazi](https://github.com/sxyazi/yazi) release `26.8.15` is used here

## keymappings

[see markdown](./help.md)

## install on unix

**![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey) ![linux](https://img.shields.io/badge/Linux-blue?logo=linux&labelColor=grey) pre-install**

- if [nerdfonts](https://www.nerdfonts.com) are not installed, consider e.g _hack nerd font_:
- don't forget to set the terminal font after installing

```bash
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip && cd ~/.local/share/fonts && unzip Hack.zip && rm Hack.zip && fc-cache -fv
```

**![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey) install [homebrew](https://brew.sh/) if not present**

<br>

**![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey) install dependencies** <small>(this assumes [vscode](https://code.visualstudio.com/) is installed already)</small>

```bash
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide imagemagick broot nushell ouch ncdu nbpreview rich-cli glow mactag librsvg ffmpegthumbnailer resvg mediainfo tree tag
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

**[![windows](https://badgen.net/badge/icon/windows?icon=windows&label)](https://microsoft.com/windows/) run the install script** <small>(this assumes [vscode](https://code.visualstudio.com/) is installed already)</small>

- download install_windows.ps1 from this repo, then in PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass; .\install_windows.ps1
```

- if your PowerShell profile fails with "running scripts is disabled on this system", allow local scripts for your user once, then open a new terminal:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

It installs the dependencies with winget (including [Git for Windows](https://gitforwindows.org/)), clones the config to `%USERPROFILE%\.config\yazi`, and sets these for your user:

- `YAZI_CONFIG_HOME` → `%USERPROFILE%\.config\yazi`
- `YAZI_FILE_ONE` → Git's `file.exe` (yazi needs it to detect file types)
- `PATH` += `Git\usr\bin` (for `sh`, `file`, `xargs`, …) and `.config\yazi\scripts\win` (for `yzsh`)

It also installs _JetBrainsMono Nerd Font_. Set it as the terminal font afterwards, e.g. in Windows Terminal: Settings → your profile → Appearance → Font face → `JetBrainsMono Nerd Font`, then restart the terminal.

> [!NOTE]
> - yazi runs shell bindings with `cmd.exe` on Windows. Bindings and openers that need bash go through `yzsh`, which runs the script in Git Bash and converts Windows paths for it.
> - Not available on Windows yet: pgp/gpg and agent keys (`k g …`, `c a`, `c A`, `c g`, `c s`), "Execute with args", the `c d/l/p/i/I` pickers, dir size (ncdu), Quicklook. macOS only: Finder tags, Finder/iCloud keys. Unix only: chmod, mount, suspend.
> - Symlinks (`p l`, `p L`) need Windows Developer Mode or an admin shell.

## launch

```bash
# run yazi after restart zsh
y

# debug mode (debug | info | warn | error) -> log is in ~/.local/state/yazi/yazi.log
YAZI_LOG=info yazi
```

## hints

> [!NOTE]
> - for remote ssh connect use [vfs](https://yazi-rs.github.io/docs/next/configuration/vfs/) logic

> [!CAUTION]
> how to upgrade yazi:
> By default, brew upgrade runs cleanup afterward and deletes the old Cellar keg — so once you upgrade, the old 26.5.6 binary is gone and there's no yazi@26.5.6 versioned formula to fall back to in homebrew-core.
> How to keep a safe rollback path:
> ```bash
> brew unpin yazi
> export HOMEBREW_NO_INSTALL_CLEANUP=1
> # tell brew not to auto-remove the old keg
> ```
>
> ```bash
> brew upgrade yazi
> ```
>
> ❌ If something breaks:
>
> ```bash
> brew switch yazi 26.5.6 
> # instant relink to the old keg, no reinstall/download needed, since cleanup was skipped.
> ```
>
> ✅ If you're happy with the new version:
>
> ```bash
> brew cleanup yazi 
> brew pin yazi
> # later to reclaim the disk space from the old keg.
> ```

## release notes

### 26.8.15 (from 26.5.6)

- `vfs.toml`: SFTP sections renamed upstream, `[services.*]` → `[sftp.*]`, and the per-entry `type = "sftp"` field was dropped (the scheme is now the table key itself). Update local `vfs.toml` accordingly or SFTP mounts will fail to parse.
- `yazi.toml`: `[tasks] micro_workers`/`macro_workers` (already dead since 26.5.6) replaced with `file_workers`, `plugin_workers`, `fetch_workers`, `preload_workers`, `process_workers`.
- `keymap.toml`: deprecated `copy dirname` action renamed to `copy dirpath`.
- ran `ya pkg upgrade` for all managed plugins/flavors; `office.yazi` and `duckdb.yazi` were skipped since both carry local hand-applied fixes that don't match their pinned upstream commit — left on their old revs, no removed/deprecated API usage found in either.
- `Url.is_archive` was removed upstream; only the inactive, unmanaged `file-actions.yazi` plugin used it (binding already commented out in `keymap.toml`) — no action needed unless it's re-enabled.
