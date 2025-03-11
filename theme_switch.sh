#!/bin/bash

# File paths
NVIM_CONFIG="/Users/glepoutre/.config/nvim/init.lua"
GHOSTTY_CONFIG="/Users/glepoutre/Library/Application Support/com.mitchellh.ghostty/config"

# Ensure we get one of the right args
if [[ "$1" != "light" && "$1" != "dark" && "$1" != "darker" ]]; then
  echo "Usage: $0 {light|dark|darker}"
  exit 1
fi

# Update neovim config
sed -i '' -e "/-- Script finder string!/{n;s/SetColorScheme(\".*\")/SetColorScheme(\"$1\")/;}" "$NVIM_CONFIG"

# Update ghostty config
case "$1" in
  light)
    THEME="Kanagawa Lotus"
    ;;
  dark)
    THEME="Kanagawa Wave"
    ;;
  darker)
    THEME="Kanagawa Dragon"
    ;;
esac
sed -i '' -e "/# Script finder string!/{n;s/theme=.*/theme=$THEME/;}" "$GHOSTTY_CONFIG"

# Reload ghostty config using AppleScript
osascript -e 'tell application "Ghostty" to activate' \
          -e 'tell application "System Events" to keystroke "," using {command down, shift down}'

# Final message
echo "Theme updated to '$1'"
