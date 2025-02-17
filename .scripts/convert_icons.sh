#!/bin/bash
XDC_PATH="/home/yovelb/.local/share/ti/ccs1281"

# Define array of image extensions to convert
formats=("ico" "bmp" "gif" "tiff" "jpg" "jpeg" "webp")

for ext in "${formats[@]}"; do
    find "$XDC_PATH" -name "*.$ext" | while read src_file; do
        png_file="${src_file%.$ext}.png"
        
        # Check if PNG already exists
        if [ ! -f "$png_file" ]; then
            echo "Converting: $src_file to $png_file"
            magick "$src_file" "$png_file"
        else
            echo "PNG already exists for: $src_file"
        fi
        
        # Backup original file if not already backed up
        if [ ! -f "${src_file}.backup" ]; then
            echo "Backing up: $src_file"
            mv "$src_file" "${src_file}.backup"
        fi
        
        # Create symlink if it doesn't exist
        if [ ! -L "$src_file" ]; then
            echo "Creating symlink: $src_file -> $png_file"
            ln -s "$png_file" "$src_file"
        fi
    done
done
