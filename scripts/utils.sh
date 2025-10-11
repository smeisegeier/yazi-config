#!/bin/bash

function get_os() {
  case "$(uname -s)" in
    Linux*)
      # Check for WSL environment on Linux
      if grep -qi microsoft /proc/version; then
        echo "windows"
      else
        echo "linux"
      fi
      ;;
    Darwin*)
      echo "macos"
      ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      echo "windows"
      ;;
    *)
      # Fallback for unknown OS
      echo "unknown"
      ;;
  esac
}