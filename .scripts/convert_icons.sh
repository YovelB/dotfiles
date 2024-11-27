#!/bin/bash
XDC_PATH="/opt/st"

find "$XDC_PATH" -name "*.ico" | while read ico_file; do
    png_file="${ico_file%.ico}.png"
    
    # Check if PNG already exists
    if [ ! -f "$png_file" ]; then
        echo "Converting: $ico_file to $png_file"
        magick "$ico_file[0]" "$png_file"
    else
        echo "PNG already exists for: $ico_file"
    fi
    
    # Backup ICO file if not already backed up
    if [ ! -f "${ico_file}.backup" ]; then
        echo "Backing up: $ico_file"
        mv "$ico_file" "${ico_file}.backup"
    fi
    
    # Create symlink if it doesn't exist
    if [ ! -L "$ico_file" ]; then
        echo "Creating symlink: $ico_file -> $png_file"
        ln -s "$png_file" "$ico_file"
    fi
done
