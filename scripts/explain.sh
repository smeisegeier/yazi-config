#!/usr/bin/env nu

def main [path: string] {
    let ext = ($path | path parse).extension | str downcase

    match $ext {
        "json" | "yaml" | "yml" | "toml" | "xml" => {
            # Print the command in a different color (dim) to separate it from data
            print $"(ansi grey)> open ($path) | table -e(ansi reset)"
            open $path | table -e | print
        }

        "jsonc" => {
            # nu has no jsonc type, but `from json` accepts comments
            print $"(ansi grey)> open --raw ($path) | from json | table -e(ansi reset)"
            open --raw $path | from json | table -e | print
        }

        "duckdb" | "db" | "sqlite"  => {
            print $"(ansi grey)> duckdb -readonly ($path) 'SHOW ALL' | from json | table -e | print(ansi reset)"
            duckdb -readonly $path "SHOW ALL" -json | from json | table -e | print
        }

        _ => {
            print $"(ansi grey)> [No handler] nothing defined yet!(ansi reset)"
            # run_quicklook $path
            # return
        }
    }

    print "" # Spacer
    print -n $"\n\e[0;90mPress any key...\e[0m"; input -n 1 -s | ignore; print -n "\r\e[2K"
}