#!/usr/bin/env nu

def main [x: string] {
    # Check if $x ends with .db, .sqlite, or .duckdb
    let output = if ($x | str ends-with ".db") or ($x | str ends-with ".sqlite") {
        # If it does, open it with sqlite3
        print $"open ($x) | query db 'select * from _meta'"
        open $x | query db 'select * from _meta'
    } else if ($x | str ends-with ".duckdb") {
        # If it's a .duckdb file, use the DuckDB CLI command
        print $"duckdb ($x) 'SELECT * FROM _meta' | table"
        duckdb $x "SELECT * FROM _meta" | table
    } else {
        # If it's not a recognized file type
        print "❌ Error: File must end with .db, .sqlite, or .duckdb"
    }

    # Force flush and wait
    print $output
    print -n $"\n\e[0;90mPress any key...\e[0m"; input -n 1 -s | ignore; print -n "\r\e[2K"
}
