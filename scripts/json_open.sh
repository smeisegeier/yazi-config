#!/usr/bin/env nu

def main [x: string] {
    # Check for both .json and .yaml/.yml
    if ($x | str ends-with ".json") or ($x | str ends-with ".yaml") or ($x | str ends-with ".yml") {
        
        # 1. 'open' detects the type and turns it into a Nu record
        # 2. 'table -e' forces all nested layers to expand
        open $x | table -e | print

    } else {
        print $"❌ Error: ($x) is not a supported data file (JSON/YAML)"
    }

    input "Press Enter to continue..."
}