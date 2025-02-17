#!/bin/bash
# exit on error, undefined vars, and pipe failures
set -euo pipefail

# configuration paths
LOG_DIR="$HOME/.local/log/rclone"
LOCK_FILE="/tmp/rclone-sync.lock"
SYNC_PID=""

# log history size (# of lines)
LOG_SIZE=1000

# create log dir if not exists
mkdir -p "$LOG_DIR"


# associative array mapping remote:paths to local paths
declare -A SYNC_PATHS=(
    ["proton:Fedora/Yovel"]="$HOME/Documents/Yovel"
    ["proton:Fedora/Remarkable"]="$HOME/Documents/Remarkable"
    ["google:Fedora/UserWorkspace"]="$HOME/UserWorkspace"
)

# path-specific exclusion patterns
declare -A EXTRA_EXCLUDES=(
    ["proton:Fedora/Yovel"]="
- /Reading/**
- /Volunteer/**
"
    ["proton:Fedora/Remarkable"]="
- /Books/**
"
    ["google:Fedora/UserWorkspace"]="
- /archive/**
- /CCS/**
- /zephyrproject/**
"
)

# Rclone optimization and performance flags
RCLONE_FLAGS=(
    --transfers=16                                     # Number of files to transfer in parallel
    --checkers=16                                      # Number of hash checking operations to run in parallel
    --buffer-size=64M                                 # Size of in-memory buffer for each transfer
    --drive-chunk-size=64M                            # Size of chunks for upload to Google Drive
    --fast-list                                       # Use recursive list if available (faster for large directories)
    --stats=5s                                        # Print stats every 5 seconds
    --progress                                        # Show progress during transfer
    --tpslimit=16                                     # Limit API calls per second to avoid rate limiting
    --tpslimit-burst=16                               # Allow bursts of up to 32 API calls
    --multi-thread-streams=4                          # Number of streams to use for multi-thread downloads
    --multi-thread-cutoff=64M                         # Files larger than this use multi-thread transfers
    --drive-acknowledge-abuse                         # Skip Google Drive warning for flagged files
    --log-file="$LOG_DIR/rclone.log"                  # Where to write logs
    --log-level=INFO                                  # Level of logging detail
    --filter-from="$HOME/.config/rclone/filters.txt"  # File containing global filters
)

# signal handler for clean termination
cleanup() {
  # handle termination signels (SIGINT, SIGTERM, SIGHUP) and cleanup
  echo "[$(date)] Received termination signal. Cleaning up..." >> "$LOG_DIR/rclone.log"
  if [ -n "$SYNC_PID" ]; then
      kill -TERM "$SYNC_PID" 2>/dev/null || true
  fi
  rm -f "$LOCK_FILE"
  exit 1
}

# log rotation for rclone log
rotate_log() {
  if [ -f "$LOG_DIR/rclone.log" ]; then
    local line_count=$(wc -l < "$LOG_DIR/rclone.log")
    if [ "$line_count" -gt "$LOG_SIZE" ]; then
      # create backup with timestamp
      local timestamp=$(date +"%Y%m%d_%H%M%S")
      local backup_file="$LOG_DIR/rclone.log.$timestamp"
      
      # make backup of current log
      cp "$LOG_DIR/rclone.log" "$backup_file"
      
      # clear the current log file
      : > "$LOG_DIR/rclone.log"
      
      log_message "Rotated log file, saved as $backup_file"
    fi
  fi
}

# timestamp logger
log_message() {
  # write timestamped message to log file
  echo "[$(date)] $1" >> "$LOG_DIR/rclone.log"
}

# check network connectivity
check_network() {
  if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    log_message "No network connectivity"
    return 1
  fi
  return 0
}

# core sync function with filter support
perform_sync() {
  # perform sync operation with optional extra filters
  local source="$1"
  local dest="$2"
  local extra_excludes="$3"

  if [ -n "$extra_excludes" ]; then
    # create temporary filter file for additional exclusions
    local extra_filter_file=$(mktemp)
    if ! extra_filter_file=$(mktemp); then
      log_message "Failed to create temporary filter file"
      return 1
    fi
    echo "$extra_excludes" > "$extra_filter_file"

    log_message "Syncing $source to $dest with additional filters"

    if ! rclone sync "${RCLONE_FLAGS[@]}" \
      --filter-from="$extra_filter_file" \
      "$source" "$dest"; then
      log_message "Error syncing @$source to $dest"
      rm -f "$extra_filter_file"
      return 1
    fi

    rm -f "$extra_filter_file"
  else
    log_message "Syncing $source to $dest"

    if ! rclone sync "${RCLONE_FLAGS[@]}" \
      "$source" "$dest"; then
      log_message "Error syncing @$source to $dest"
      return 1
    fi
  fi
}

# main function
main() {
  # check network connectivity
  if ! check_network; then
    rm -f "$LOCK_FILE"  # Clean up lock file
    exit 1
  fi

  # rotate log file
  rotate_log

  # check for global filters file
  if [ ! -f "$HOME/.config/rclone/filters.txt" ]; then
    log_message "Error: Global filters file missing"
    rm -f "$LOCK_FILE"  # Clean up lock file
    exit 1
  fi

  # check for existing instance (lock mechanism)
  if [ -f "$LOCK_FILE" ]; then
    log_message "Another instance is already running. Exiting..."
    rm -f "$LOCK_FILE"  # Clean up lock file
    exit 1
  fi

  # create lock file
  echo "$$" > "$LOCK_FILE"

  # set up signal handlers
  trap cleanup SIGINT SIGTERM SIGHUP

  # log start
  log_message "Sync started"

  # perform syncs
  local exit_status=0
  for dest in "${!SYNC_PATHS[@]}"; do
    source="${SYNC_PATHS[$dest]}"
    if ! perform_sync "$source" "$dest" "${EXTRA_EXCLUDES[$dest]:-}"; then
      exit_status=1
      log_message "Failed to sync $source to $dest"
    fi
  done

  # log end
  log_message "Sync finished"

  # cleanup
  rm -f "$LOCK_FILE"

  return $exit_status
}

# run main
main
