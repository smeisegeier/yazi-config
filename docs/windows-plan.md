# Windows support: status and next steps

Handoff for continuing the Windows port **on a Windows host**. The groundwork was done and tested on macOS (v26-10-25.1). The Windows side has not run yet.

## Ground rules

- **macOS must not regress.** Unix lines in `yazi.toml`/`keymap.toml` stay byte-identical apart from `for = "unix"`. Windows behaviour goes into separate `for = "windows"` entries, or into `ya.target_family() == "windows"` branches in Lua.
- Do one item per commit. Before merging each one, check it on macOS: run `YAZI_LOG=warn yazi` and use it a bit; `~/.local/state/yazi/yazi.log` must stay empty.
- Windows support runs bash scripts through **Git Bash**, not PowerShell ports. Any key or opener that needs bash calls `yzsh <script> [args]` (see below).

## How it works on Windows (already in place)

- yazi runs `shell` keys and openers with `cmd.exe /C`. So there is no `~`, no `$VAR`, no `;`, and no `read`.
- `scripts/win/yzsh.cmd` starts Git's `bash.exe` on `scripts/win/yzsh`. That script converts `C:\...` arguments with `cygpath -u`, sets `YAZI_CONFIG_HOME` to its POSIX form, and runs `scripts/<name>` (with nu if the shebang says nu, otherwise bash). `yzsh -c '<snippet>' args...` runs an inline snippet.
- `install_windows.ps1` does the following:
  - installs the dependencies with winget;
  - clones the config to `%USERPROFILE%\.config\yazi`;
  - sets the user variables `YAZI_CONFIG_HOME` and `YAZI_FILE_ONE` (Git's `file.exe`);
  - adds `Git\usr\bin` and `scripts\win` to the user `PATH`;
  - adds a `y` wrapper to `$PROFILE`.
- `.gitattributes` forces LF line endings (and CRLF for `*.cmd`), so the scripts survive `core.autocrlf=true`.
- Hidden on Windows for now (`for = "unix"`/`"macos"`): pgp/gpg, agent keys, "Execute with args", chmod, ncdu, mount, `<C-z>`, `c d/l/p/i/I`, and `g b/e/m/r/T`.

## Step 1: set up and verify the basics

1. Install the config with `Set-ExecutionPolicy -Scope Process Bypass; .\install_windows.ps1`, then open a **new** terminal (Windows Terminal) and set a Nerd Font.
2. Check that the core assumption holds: in yazi, press `;`, run `echo %ComSpec%`, and confirm it shows `cmd.exe`. If yazi uses another shell, the twins need rethinking before going further.
3. Check the line endings and that yazi finds its config:
   - `git -C %USERPROFILE%\.config\yazi ls-files --eol`: `.sh` and `.lua` files must show `w/lf`.
   - `yazi --debug`: shows the config dir and `YAZI_FILE_ONE`.
   - `where winget` and `winget list`: confirm every package ID in `install_windows.ps1` installed. The IDs are **unchecked**, so fix any that are wrong.
4. Mime rules and previews: Enter on a `.png` offers the image openers. Check that `.md` (piper → `sh` + glow), `.csv` (duckdb) and `.docx` (office: needs LibreOffice `soffice` + poppler) render.
5. Go through every visible menu entry: `Enter` on several file types, `k …`, `c f`, `g …`, `y …`, `F1`/`h`, `e`, `<S-Enter>`, `:`. In particular:
   - "Extract here" / `k a u` on a zip in a path with spaces and umlauts
   - `k a a` zip
   - `y t` and the Enter → "tree to clipboard" opener (Windows `tree /A /F`)
   - `k f` reveal in Explorer
6. Watch every "Press any key" prompt. The scripts use `read … < /dev/tty`. If that fails under conpty, see D7.
7. Write down what failed, fix it, and commit (e.g. `v26-1x-xx.1: fix Windows basics`).

## Step 2: deferred items (one commit each, after step 1 passes)

| # | Feature | Windows replacement | Effort | Check first on Windows |
|---|---|---|---|---|
| D1 | "Execute with args" (`plugins/exec-args.yazi`, opener `sys-open-shell`) | In a `target_family() == "windows"` branch, pick the program by extension: `.sh` → `yzsh -c`, `.ps1` → `pwsh -NoProfile -File`, `.py` → `uv run`, `.cmd`/`.bat`/`.exe` → direct. Use `;` instead of the newline. Match the title with `[^/\\]+$`. Then remove `for = "unix"` from `sys-open-shell`. | Medium | How `ya.quote` and cmd handle args that contain quotes or `&`; whether the pause prompt shows |
| D2 | gpg/ssh: `pgp-*`, `sig`, `k g *`, `c a/A/g/s` | Use one tool chain: Gpg4win `gpg.exe` (keys in `%APPDATA%\gnupg`) and the Windows OpenSSH agent service. Under MSYS, the scripts should prefer `$PROGRAMFILES/GnuPG/bin/gpg.exe` over Git's `/usr/bin/gpg`. `start_agents*.sh`: `gpgconf --kill gpg-agent` from Gpg4win, and `ssh-add` against the Windows agent instead of `eval $(ssh-agent -s)`. Then add `yzsh` twins. | Medium | Which `gpg` comes first on PATH; whether loopback pinentry works in Windows Terminal; whether keys are visible to both tools |
| D3 | fzf helpers `c p`, `c d` (`scripts/fzf.sh`) | `get_ps`: `powershell -NoProfile -Command "Get-Process \| Format-Table Id,ProcessName,CPU -Auto"`. `get_disk`: `Get-Disk` / `Get-Partition` (`wmic` is gone in Win11 24H2). Keep `c l`, `c i` and `c I` unix-only. | Medium | UTF-8 output when piped into fzf |
| D4 | Clipboard `to_clipboard` in `scripts/utils.sh` | `powershell -NoProfile -Command "[Console]::InputEncoding=[Text.UTF8Encoding]::new(); Set-Clipboard -Value ([Console]::In.ReadToEnd())"` instead of `clip.exe`, which garbles ä/ö/ü. | Low | Umlaut round trip |
| D5 | Dir size: opener `show-dir-size`, key `k s` | `gdu` (winget `dundee.gdu`) as a `for = "windows"` twin. | Low | — |
| D6 | Quicklook opener | `QuickLook.exe %s1` (QuickLook app from winget) as a `for = "windows"` twin. | Low | Install path, and whether it's on PATH |
| D7 | `read … < /dev/tty` prompts (~10 scripts) | Only if step 1.6 shows failures: read from stdin instead (yazi's `--block` already hands the script the terminal). Keep macOS behaviour the same. | Unclear | Decide after step 1 |

**Not ported** (they stay macOS/unix-only):
- mactag: Windows has no file tags.
- mount `M` and sshfs `S`: would need rewritten plugins, or WinFsp/SSHFS-Win.
- chmod: Windows uses ACLs.
- `<C-z>`: terminal programs can't be suspended on Windows.
- `g b`/`g T`: the Recycle Bin isn't a normal folder.
- `p l`/`p L` (symlinks) need Developer Mode. This is already noted in the README.

## Finishing

- Update the README "install on windows" notes: remove items from "Not available on Windows yet" as they get ported.
- Add a CHANGELOG entry per release in the existing CalVer style (`vYY-MM-DD.N`).
- Re-run the macOS check from "Ground rules" before pushing.
