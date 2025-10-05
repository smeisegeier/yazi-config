#!/usr/bin/env nu

def main [x: string] {
    # Check if $x ends with .db, .sqlite, or .duckdb
    if ($x | str ends-with ".db") or ($x | str ends-with ".sqlite") {
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
        # ^read in
    # Wait for the user to press Enter
    # print "Press return to continue"
    # let _ = input
}
