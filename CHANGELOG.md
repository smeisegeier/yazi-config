# Changelog

Notable changes to this yazi config. CalVer: `vYY-MM-DD`, with a `.N` sequence suffix for additional versions released the same day.

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
