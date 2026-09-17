# Changelog

Notable changes to this yazi config. No version scheme — entries are dated.

## 2026-09-17
### Changed
- Bundled `duckdb_ui_readonly.sh` into a single `duckdb_ui.sh` script with `ro`/`rw` modes; the mode is now chosen via separate `duckdb-ui` / `duckdb-ui-rw` openers in `yazi.toml`, not by extension-sniffing inside the script.
- Fixed the `*.csv` opener, which previously reused the readonly `ATTACH`-based DuckDB UI logic and errored on non-database files — CSVs now load into an in-memory table with full read/write access in the session.
- Added a `k x w` hotkey for the CSV read/write DuckDB UI, alongside the existing `k x u` readonly one.
