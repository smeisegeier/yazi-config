#!/usr/bin/env bash
# The DuckDB UI extension stores its own state (notebooks, etc.) as tables
# in the main database, so it can't run directly against a database opened
# with -readonly (fails with a Binder/Catalog error). Instead: keep the
# main/default catalog as the throwaway in-memory db for the UI's own
# bookkeeping, and attach the target file read-only under its own name.

file="$1"
name="$(basename "$file")"
name="${name%.*}"

duckdb -cmd "ATTACH '$file' AS \"$name\" (READ_ONLY); USE \"$name\";" -ui
