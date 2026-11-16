#!/usr/bin/env nu

def main [x: string] {
    # Check for both .json and .yaml/.yml
    if ($x | str ends-with ".json") or ($x | str ends-with ".yaml") or ($x | str ends-with ".yml") {
        
        # 1. 'open' detects the type and turns it into a Nu record
        # 2. 'table -e' forces all nested layers to expand
        open $x | table -e | print

    } else if ($x | str ends-with ".jsonc") {

        # nu has no jsonc type, but `from json` accepts comments
        open --raw $x | from json | table -e | print

    } else {
        print $"❌ Error: ($x) is not a supported data file (JSON/YAML)"
    }

    print -n $"\n\e[0;90mPress any key...\e[0m"; input -n 1 -s | ignore; print -n "\r\e[2K"
}