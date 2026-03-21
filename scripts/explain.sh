#!/usr/bin/env nu

def main [path: string] {
    let ext = ($path | path parse).extension | str downcase

    match $ext {
        "json" | "yaml" | "yml" | "toml" => {
            # Print the command in a different color (dim) to separate it from data
            print $"(ansi grey)> open ($path) | table -e(ansi reset)"
            open $path | table -e | print
        }

        "duckdb" | "db" | "sqlite"  => {
            print $"(ansi grey)> duckdb -readonly ($path) 'SHOW ALL' | from json | table -e | print(ansi reset)"
            duckdb -readonly $path "SHOW ALL" -json | from json | table -e | print
        }

        "png" | "jpg" | "jpeg" | "svg" | "pdf" => {
            print $"(ansi grey)> [Executing Quick Look via AppleScript](ansi reset)"
            run_quicklook $path
            return 
        }

        _ => {
            print $"(ansi grey)> [No handler] nothing defined yet!(ansi reset)"
            # run_quicklook $path
            # return
        }
    }

    print "" # Spacer
    input "Press Enter to exit..."
}

# def run_quicklook [path: string] {
#     ^osascript -e $"tell application \"Finder\" to reveal POSIX file \"($path)\"" -e "tell application \"Finder\" to activate" -e \"tell application \"System Events\" to keystroke \" \""
# }

def run_quicklook [path: string] {
    ^osascript -e $"tell application \"Finder\" to reveal POSIX file \"($path)\"" -e "tell application \"Finder\" to activate" -e "tell application \"System Events\" to keystroke \" \""
}