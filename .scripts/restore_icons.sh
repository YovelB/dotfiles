#!/bin/bash

# Define path - Update this to match your CCS installation path
XDC_PATH="$HOME/.local/share/ti/ccs1281/ccs"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to restore an svg file
restore_svg() {
    local svg_path="$1"
    local backup_path="${svg_path}.backup"
    
    # Only proceed if this is a symlink and backup exists
    if [ -L "$svg_path" ] && [ -f "$backup_path" ]; then
        log "Found backup for: $svg_path"
        
        # Remove symlink
        rm "$svg_path"
        
        # Restore from backup
        mv "$backup_path" "$svg_path"
        log "Restored: $svg_path"
        return 0
    elif [ -f "$svg_path" ] && [ ! -L "$svg_path" ]; then
        log "Original svg already exists at: $svg_path"
        return 1
    else
        log "No backup found for: $svg_path"
        return 1
    fi
}

# Main execution
log "Starting SVG icon restoration process..."

# Find and restore all svg files
find "$XDC_PATH" -name "*.svg.backup" | while read backup_file; do
    original_file="${backup_file%.backup}"
    restore_svg "$original_file"
done
