#!/usr/bin/env bash
# The DuckDB UI extension stores its own state (notebooks, etc.) as tables
# in the main database, so it can't run directly against a database opened
# with -readonly (fails with a Binder/Catalog error). Instead: keep the
# main/default catalog as the throwaway in-memory db for the UI's own
# bookkeeping, and attach the target file read-only under its own name.
#
# mode:
#   ro  duckdb/sqlite/db file - attach read-only, source file stays untouched
#   rw  csv file - load into an in-memory table, fully writable in-session

mode="$1"
file="$2"
name="$(basename "$file")"
name="${name%.*}"

case "$mode" in
    ro)
        duckdb -cmd "ATTACH '$file' AS \"$name\" (READ_ONLY); USE \"$name\";" -ui
        ;;
    rw)
        duckdb -cmd "CREATE TABLE \"$name\" AS SELECT * FROM read_csv_auto('$file');" -ui
        ;;
    *)
        echo "Usage: $(basename "$0") <ro|rw> <file>" >&2
        exit 1
        ;;
esac
