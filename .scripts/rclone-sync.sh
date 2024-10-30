#!/bin/bash

# Create log dir if not exists
LOG_DIR="$HOME/.local/log/rclone"
mkdir -p "$LOG_DIR"

# Define paths to sync
declare -A SYNC_PATHS=(
    ["proton:Fedora/Yovel"]="$HOME/Documents/Yovel"
    ["google:Fedora/Remarkable"]="$HOME/Documents/Remarkable"
)

# Define additional exclude patterns specific to each destination
declare -A EXTRA_EXCLUDES=(
    ["proton:Fedora/Yovel"]="
- /Reading/**
- /Documents/Yovel/Private/**
"
    ["google:Fedora/Remarkable"]="
- /Books/**
- /Documents/Remarkable/Personal/**
"
)

# Rclone base flags
RCLONE_FLAGS=(
    --transfers=8
    --checkers=8
    --buffer-size=64M
    --drive-chunk-size=64M
    --fast-list
    --stats=5s
    --progress
    --tpslimit=8
    --tpslimit-burst=16
    --drive-acknowledge-abuse
    --log-file="$LOG_DIR/rclone.log"
    --log-level=INFO
    --filter-from="$HOME/.config/rclone/filters.txt"  # Global filters
)

# Log start
echo "[$(date)] Sync started" >> "$LOG_DIR/rclone.log"

# Perform syncs with additional filters
for dest in "${!SYNC_PATHS[@]}"; do
    source="${SYNC_PATHS[$dest]}"
    
    # Create temporary filter file for additional exclusions
    if [[ -n "${EXTRA_EXCLUDES[$dest]:-}" ]]; then
        EXTRA_FILTER_FILE=$(mktemp)
        echo "${EXTRA_EXCLUDES[$dest]}" > "$EXTRA_FILTER_FILE"
        
        echo "[$(date)] Syncing $source to $dest with additional filters" >> "$LOG_DIR/rclone.log"
        
        # Sync with both global and additional filters
        rclone sync "${RCLONE_FLAGS[@]}" \
            --filter-from="$EXTRA_FILTER_FILE" \
            "$source" "$dest"
            
        rm "$EXTRA_FILTER_FILE"
    else
        echo "[$(date)] Syncing $source to $dest" >> "$LOG_DIR/rclone.log"
        
        # Sync with only global filters
        rclone sync "${RCLONE_FLAGS[@]}" \
            "$source" "$dest"
    fi
done

# Log end
echo "[$(date)] Sync finished" >> "$LOG_DIR/rclone.log"
