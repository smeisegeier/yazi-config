#!/usr/bin/env nu

def main [x: string] {
    # Check if $x ends with .db or .sqlite
    if ($x | str ends-with ".db") or ($x | str ends-with ".sqlite") {
        # If it does, open it with sqlite3
        print $"open ($x) | schema"
        open $x | schema
    } else if ($x | str ends-with ".duckdb") {
        # If it's a .duckdb file, use the DuckDB CLI command
        print $"duckdb -readonly ($x) 'SHOW ALL' | table"
        duckdb $x "SHOW ALL" -json | from json 
    } else {
        print "❌ Error: File must end with .db or .sqlite"
    }
}
