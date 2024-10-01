#!/bin/bash

# Reset XKB options
gsettings set org.gnome.desktop.input-sources xkb-options "[]"

# There is an .desktop entry that is launched at startup in:
# ~/.config/autostart/reset-xkb-options.desktop

# Optionally, set your preferred layout here if needed
# gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'il')]"
