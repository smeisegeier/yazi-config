# Changelog

Notable changes to this yazi config. CalVer: `vYY-MM-DD`, with a `.N` sequence suffix for additional versions released the same day.

## v26-10-25.1
### Added
- First Windows support. `install_windows.ps1` installs the dependencies, clones the config to `%USERPROFILE%\.config\yazi` and sets `YAZI_CONFIG_HOME`, `YAZI_FILE_ONE` and `PATH`. On Windows, yazi runs shell bindings with `cmd.exe`, so bindings and openers that need bash now have a `for = "windows"` twin that calls `yzsh` (`scripts/win/`). It runs the script in Git Bash and converts Windows paths for it. Openers that only need one command (Show in terminal, EXIF, reveal in Explorer) run directly in cmd.
- `.gitattributes` keeps LF line endings on checkout, so the bash scripts still run after cloning on Windows.
- `docs/windows-plan.md` lists the next steps and the features still missing on Windows. They are to be done on a Windows host.
- The fzf finder (`ff`) shows a short extended-search hint next to the result count.

### Changed
- Bindings and openers that only work on unix are scoped with `for = "unix"`, so Windows no longer lists them. Nothing changes on macOS or Linux.
- `launcher.sh` and `zip_selected.sh` are bash scripts now (they were zsh). The keymap palette (`e`) skips bindings meant for another OS.
- "git fetch" (`c f`), the help page (`F1`, `h`) and the opener selector (`Shift+Enter`) moved from inline shell code into `scripts/git_fetch.sh`, `scripts/help.sh` and `scripts/opener_select.sh`. They behave the same.
- The "🌴 tree to clipboard" opener uses the `tree-to-clipboard` plugin instead of `pbcopy`, so it works on Linux too. On Windows the plugin uses the built-in `tree /A /F`.
- The Finder-tag fetcher runs through `mactag-macos`, which skips it outside macOS. It no longer tries to start the missing `tag` command for every folder on Linux and Windows.

### Fixed
- `k g v` (verify signature) called `gpg_verify_selected.sh`, which doesn't exist. It now calls `gpg_verify_signature.sh`.
- `k t` (create) had `esc =` instead of `desc =`, so it had no description in the key list or the palette.
- sshfs never loaded on Linux, because `init.lua` checked `$OSTYPE`, a shell variable that isn't exported. It now uses `ya.target_os()`.

## v26-10-24.1
### Fixed
- "git fetch" (`c f`) and the help page (`F1`, `h`) no longer show raw escape codes such as `\n\033[0;90m` around "Press any key". yazi runs `shell` bindings with `sh -c`, and bash's `echo` doesn't handle escapes without `-e`. These bindings now use `printf`.
- The full-screen opener selector (`Shift+Enter`) lists every opener in fzf again, instead of one entry with literal `\n` between the names.

## v26-10-23.1
### Fixed
- After a shell call, the "Press any key to continue..." line no longer stays on screen, and the next shell call's output no longer starts at the end of that line. `exec-args` and `run_blocking.sh` now erase the prompt line after the key press.
- Office files (`.docx`, `.xlsx`, `.pptx`, `.odt`, `.ods`, `.odp`) are no longer treated as archives when `file` reports them as `application/zip`. A rule that matches by extension now opens them with the system app.

## v26-10-07.1
### Changed
- "Execute with args" (`sys-open-shell`) stays in yazi again. The new `exec-args` plugin asks for the arguments in a yazi prompt, with only the file name in its title. It then runs the file while yazi is paused and waits for a key before coming back. It no longer depends on the `y()` wrapper in `~/.zshrc`, so it behaves the same on every machine and from plain `yazi`. The opener exits right away, so no task is left running.

### Removed
- `scripts/exec_selected.sh` and the `$YAZI_EXEC_FILE` handoff to `y()`. The extra `y()` code from v26-10-02.1 is no longer needed.

## v26-10-02.2
### Fixed
- Extracting archives no longer leaves macOS AppleDouble `._*` files next to every real file. Opening an archive used yazi's built-in extract plugin (`7zz`), which writes `._` entries out as normal files. All archive types now open with `untar_selected.sh` ("📦 Extract here"), which replaces the built-in extractor in the menu.
- `untar_selected.sh` skips `._*` entries for every format: tar gets `--exclude "._*" --no-xattrs`, plus `--no-mac-metadata` on bsdtar only, since GNU tar rejects it. unzip skips `__MACOSX/` and `._*`, and 7-Zip uses `-xr!._*` and `-xr!__MACOSX`.
- Plain uncompressed `.tar` archives now extract with GNU tar on Linux. The script no longer forces `-z`, and both tars detect the compression themselves.

### Changed
- `untar_selected.sh` now handles any archive 7-Zip can read (`.7z`, `.rar`, `.xz`, single-file `.gz`, …). It uses `7zz` on macOS and `7z` on Linux.
- Archives are extracted into a temp folder first. A single top-level item is moved up into the current folder. Otherwise the contents go into a folder named after the archive, with a timestamp suffix if that name already exists, so nothing gets overwritten.

## v26-10-02.1
### Fixed
- "Execute in shell" no longer runs the script inside a paused yazi. The opener was blocking, and yazi only acts on `ya emit quit` once the opener's process has finished. So the script ran while yazi was paused, and its output or key prompt showed up only after yazi came back. `exec_selected.sh` now writes the file path to `$YAZI_EXEC_FILE` and quits yazi. The `y` shell wrapper then runs the script in the real terminal after yazi has exited. This needs the updated `y()` in `~/.zshrc`. Without it, the script falls back to running inside yazi.

### Changed
- "Execute in shell" now prompts for arguments before running (`exec_selected.sh -a`). Press Enter on an empty prompt to run with no arguments. The menu entry without arguments is commented out.
- `.py` files no longer offer "Execute in shell" (`sys-open-shell`). Use the `py-open` opener (`uv run`) instead.

## v26-09-24.1
### Changed
- Bulk rename/create now opens the filename list in VS Code (`code --wait` via the `terminal-block` opener) instead of vim. Yazi opens `bulk-rename.txt` with the first opener that waits for the editor to close, and the `*.txt` rule resolved to `vim`. A dedicated rule for `bulk-{rename,create}.txt` now comes before it.

## v26-09-23.1
### Changed
- `gpg_decrypt_selected.sh` now passes `--skip-verify`, so signed-and-encrypted files decrypt without signature checks (no failures or noise when the signer's public key is missing).

## v26-09-21.1
### Fixed
- `gpg_decrypt_selected.sh` only stripped a `.gpg` suffix, so decrypting a `.pgp` file redirected gpg's output to the same path as the input — truncating the source to 0 bytes before gpg could even read it. Now supports `.gpg`, `.pgp`, and `.asc`, decrypts to a temp file first, and only replaces the original once gpg exits successfully with non-empty output.

### Changed
- ncdu (`scripts/ncdu.sh` and the `show-dir-size` opener in `yazi.toml`) now runs with `--color off` instead of a hardcoded `--color dark-bg`, so it uses the terminal's own colors instead of a fixed dark palette.

### Added
- `.pgp` files now get the same 🔐 icon as `.gpg` in `theme.toml`.

## v26-09-17.2
### Added
- New `sys-open-shell` opener (scripts/exec_selected.sh) that quits yazi and hands the terminal directly to the selected file, executing it as-is instead of spawning it through macOS `open`. Wired into the `*.{sh,nu,ps1,py,lua,r,conf,ini,js}` rule.

## v26-09-17.1
### Changed
- Bundled `duckdb_ui_readonly.sh` into a single `duckdb_ui.sh` script with `ro`/`rw` modes; the mode is now chosen via separate `duckdb-ui` / `duckdb-ui-rw` openers in `yazi.toml`, not by extension-sniffing inside the script.
- Fixed the `*.csv` opener, which previously reused the readonly `ATTACH`-based DuckDB UI logic and errored on non-database files — CSVs now load into an in-memory table with full read/write access in the session.
- Added a `k x w` hotkey for the CSV read/write DuckDB UI, alongside the existing `k x u` readonly one.
