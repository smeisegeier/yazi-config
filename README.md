# file-manager-config

[yazi](https://github.com/sxyazi/yazi) release `26.8.15` is used here

## keymappings

[see markdown](./help.md)

## install on unix

**![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey) ![linux](https://img.shields.io/badge/Linux-blue?logo=linux&labelColor=grey) run the install script** <small>(this assumes [vscode](https://code.visualstudio.com/) is installed already)</small>

```bash
git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi && bash ~/.config/yazi/install_unix.sh
```

It does, skipping anything already present:

- macOS: installs [homebrew](https://brew.sh/), then the dependencies with brew
- Linux: installs the dependencies with pacman (arch). Other distros: install them with your package manager, the list is in the script
- installs _Hack Nerd Font_ if no [nerd font](https://www.nerdfonts.com) is found. Set it as the terminal font afterwards
- clones the config to `~/.config/yazi` (so the script also works as a standalone download)
- adds `YAZI_CONFIG_HOME` and the `y` wrapper to `~/.zshrc`

## install on windows

**[![windows](https://badgen.net/badge/icon/windows?icon=windows&label)](https://microsoft.com/windows/) run the install script** <small>(this assumes [vscode](https://code.visualstudio.com/) is installed already)</small>

- in PowerShell:

```powershell
irm https://raw.githubusercontent.com/smeisegeier/yazi-config/main/install_windows.ps1 | iex
```

It installs the dependencies with winget (including [Git for Windows](https://gitforwindows.org/)), clones the config to `%USERPROFILE%\.config\yazi`, and sets these for your user:

- `YAZI_CONFIG_HOME` → `%USERPROFILE%\.config\yazi`
- `YAZI_FILE_ONE` → Git's `file.exe` (yazi needs it to detect file types)
- `PATH` += `Git\usr\bin` (for `sh`, `file`, `xargs`, …) and `.config\yazi\scripts\win` (for `yzsh`)

It also:

- adds the `y` wrapper to your PowerShell profile, and sets the execution policy for your user to `RemoteSigned` if scripts are blocked, so the profile loads. Group policy on managed machines can override this
- installs _JetBrainsMono Nerd Font_ and makes it the default font in Windows Terminal, unless one is set already (backup: `settings.json.bak`). For other terminals, set the font yourself

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
