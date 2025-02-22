#!/usr/bin/env nu

def main [x: string] {
    # Check if $x ends with .db or .sqlite
    if ($x | str ends-with ".db") or ($x | str ends-with ".sqlite") {
        # If it does, open it with sqlite3
        print $"open ($x) | query db 'select * from _meta'"
        open $x | query db 'select * from _meta'
    } else {
        print "❌ Error: File must end with .db or .sqlite"
    }
    # ^read in
    # Wait for the user to press Enter
    # print "Press return to continue"
    # let _ = input

}
