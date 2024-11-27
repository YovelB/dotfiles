#!/bin/bash

# Define path - Update this to match your CCS installation path
XDC_PATH="$HOME/.local/share/ti/ccs1281/ccs"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to restore an ico file
restore_ico() {
    local ico_path="$1"
    local backup_path="${ico_path}.backup"
    
    # Only proceed if this is a symlink and backup exists
    if [ -L "$ico_path" ] && [ -f "$backup_path" ]; then
        log "Found backup for: $ico_path"
        
        # Remove symlink
        rm "$ico_path"
        
        # Restore from backup
        mv "$backup_path" "$ico_path"
        log "Restored: $ico_path"
        return 0
    elif [ -f "$ico_path" ] && [ ! -L "$ico_path" ]; then
        log "Original ico already exists at: $ico_path"
        return 1
    else
        log "No backup found for: $ico_path"
        return 1
    fi
}

# Main execution
log "Starting icon restoration process..."

# Find and restore all ico files
find "$XDC_PATH" -name "*.ico.backup" | while read backup_file; do
    original_file="${backup_file%.backup}"
    restore_ico "$original_file"
done

log "Restoration process completed!"

# Check for any remaining symlinks and report them
remaining_symlinks=$(find "$XDC_PATH" -name "*.ico" -type l | wc -l)
if [ "$remaining_symlinks" -gt 0 ]; then
    log "Warning: $remaining_symlinks symlinked .ico files still remain"
    log "You may want to check these manually:"
    find "$XDC_PATH" -name "*.ico" -type l
fi
