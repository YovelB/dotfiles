#!/bin/bash
# exit on error, undefined vars, and pipe failures
set -euo pipefail

# configuration paths
LOG_DIR="$HOME/.local/log/rclone"
LOCK_FILE="/tmp/rclone-sync.lock"

# log history size (# of lines)
LOG_SIZE=1000

# create log dir if not exists
mkdir -p "$LOG_DIR"

# associative array mapping remote:paths to local paths
declare -A SYNC_PATHS=(
  ["proton:Arch/Yovel"]="$HOME/Documents/Yovel/Personal"
  ["proton:Arch/Remarkable"]="$HOME/Documents/Yovel/Remarkable"
  ["google:Arch/UserWorkspace"]="$HOME/UserWorkspace"
  ["google:Arch/UserWorkspace/zephyr-workspace"]="$HOME/UserWorkspace/zephyr-workspace/projects"
  ["google:Arch/School"]="$HOME/Documents/School"
)

# path-specific exclusion patterns
#- /KiCad/Precision_Scope/**
declare -A EXTRA_EXCLUDES=(
  ["proton:Arch/Yovel"]="
- /Reading/**
"
  ["proton:Arch/Remarkable"]="
- /Books/**
"
  ["google:Arch/UserWorkspace"]="
- /archive/**
- /zephyr-workspace/**
- /KiCad/exercises/imported/**
- /STM32/Repository/**
- /STM32/examples/**
"
)

# Rclone optimization and performance flags
RCLONE_FLAGS=(
  --transfers=16                                   # number of files to transfer in parallel
  --checkers=16                                    # number of hash checking operations to run in parallel
  --buffer-size=64M                                # size of in-memory buffer for each transfer
  --drive-chunk-size=64M                           # size of chunks for upload to Google Drive
  --fast-list                                      # use recursive list if available (faster for large directories)
  --tpslimit=16                                    # limit API calls per second to avoid rate limiting
  --tpslimit-burst=16                              # allow bursts of up to 32 API calls
  --multi-thread-streams=4                         # number of streams to use for multi-thread downloads
  --multi-thread-cutoff=64M                        # files larger than this use multi-thread transfers
  --drive-acknowledge-abuse                        # skip Google Drive warning for flagged files
  --log-file="$LOG_DIR/rclone.log"                 # where to write logs
  --log-level=ERROR                                # level of logging detail
  --filter-from="$HOME/.config/rclone/filters.txt" # file containing global filters
)

# proton specific flags (more conservative)
PROTON_RCLONE_FLAGS=(
  --transfers=4       # reduce parallel transfers
  --checkers=4        # reduce parallel checkers
  --buffer-size=32M   # smaller buffer size
  --tpslimit=5        # much lower API call limit
  --tpslimit-burst=10 # lower burst limit
  --log-file="$LOG_DIR/rclone.log"
  --log-level=ERROR
  --filter-from="$HOME/.config/rclone/filters.txt"
)

# timestamp logger
log_message() {
  # write timestamped message to log file
  echo "[$(date)] $1" >>"$LOG_DIR/rclone.log"
}

# rotate rclone log file if it exceeds LOG_SIZE lines
rotate_log() {
  if [ -f "$LOG_DIR/rclone.log" ]; then
    local line_count
    line_count=$(wc -l <"$LOG_DIR/rclone.log")
    if [ "$line_count" -gt "$LOG_SIZE" ]; then
      local timestamp backup_file
      timestamp=$(date +"%Y%m%d_%H%M%S")
      backup_file="$LOG_DIR/rclone.log.$timestamp"
      cp "$LOG_DIR/rclone.log" "$backup_file"
      : >"$LOG_DIR/rclone.log"
      log_message "rotated log file, saved as $backup_file"
    fi
  fi
}

# delete rclone log backups older than 30 days
cleanup_old_logs() {
  find "$LOG_DIR" -name "rclone.log.*" -type f -mtime +30 -delete
}

# signal handler for clean termination
cleanup() {
  # handle termination signels (SIGINT, SIGTERM, SIGHUP) and cleanup
  echo "[$(date)] received termination signal. cleaning up..." >>"$LOG_DIR/rclone.log"
  jobs -p | xargs -r kill
  exit 1
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

  # sanitize dest for filename
  local dest_log="${dest//[:\/]/_}"
  local log_file="$LOG_DIR/rclone-$dest_log.log"

  # choose flags based on remote
  local flags=("${RCLONE_FLAGS[@]}")
  if [[ "$dest" == proton:* ]]; then
    flags=("${PROTON_RCLONE_FLAGS[@]}")
  fi

  local extra_filter_file=""
  if [ -n "$extra_excludes" ]; then
    extra_filter_file=$(mktemp)
    if [ -z "$extra_filter_file" ]; then
      log_message "failed to create temporary filter file"
      return 1
    fi
    echo "$extra_excludes" >"$extra_filter_file"

    # ensure temp file is cleaned up on any exit
    trap 'rm -f "$extra_filter_file"' RETURN

    log_message "syncing $source to $dest with additional filters"

    if ! rclone sync "${flags[@]}" \
      --filter-from="$extra_filter_file" \
      "$source" "$dest" --log-file="$log_file" 2>rclone_error.log; then
      log_message "error syncing @$source to $dest"
      log_message "rclone error: $(cat rclone_error.log)"
      rm -f rclone_error.log
      return 1
    fi
    rm -f rclone_error.log
  else
    log_message "syncing $source to $dest"

    if ! rclone sync "${flags[@]}" \
      "$source" "$dest" --log-file="$log_file" 2>rclone_error.log; then
      log_message "error syncing @$source to $dest"
      log_message "rclone error: $(cat rclone_error.log)"
      rm -f rclone_error.log
      return 1
    fi
    rm -f rclone_error.log
  fi
}

# main function
main() {
  # check network connectivity
  if ! check_network; then
    exit 1
  fi

  # clean and rotate log file
  cleanup_old_logs
  rotate_log

  # check for global filters file
  if [ ! -f "$HOME/.config/rclone/filters.txt" ]; then
    log_message "Error: Global filters file missing"
    exit 1
  fi

  # atomic locking using flock
  exec 200>"$LOCK_FILE"
  if ! flock -n 200; then
    log_message "Another instance is already running. Exiting..."
    exit 1
  fi

  # create lock file
  echo "$$" >"$LOCK_FILE"

  # set up signal handlers
  trap cleanup SIGINT SIGTERM SIGHUP

  # log start
  log_message "Sync started"

  # perform syncs in parallel with job limit
  local max_jobs=3
  local exit_status=0
  declare -a pids=()
  for dest in "${!SYNC_PATHS[@]}"; do
    source="${SYNC_PATHS[$dest]}"
    perform_sync "$source" "$dest" "${EXTRA_EXCLUDES[$dest]:-}" &
    pids+=($!)
    # limit parallel jobs
    if [ "${#pids[@]}" -ge "$max_jobs" ]; then
      wait -n
      mapfile -t pids < <(jobs -rp)
    fi
  done

  # wait for all syncs to finish and check exit codes
  for pid in "${pids[@]}"; do
    wait "$pid" || exit_status=1
  done

  # append per remote logs to main log and delete them
  echo >>"$LOG_DIR/rclone.log"
  for dest in "${!SYNC_PATHS[@]}"; do
    dest_log="${dest//[:\/]/_}"
    log_file="$LOG_DIR/rclone-$dest_log.log"
    if [ -f "$log_file" ]; then
      echo "===== Log for $dest =====" >>"$LOG_DIR/rclone.log"
      cat "$log_file" >>"$LOG_DIR/rclone.log"
      rm -f "$log_file"
    fi
  done

  # log end
  log_message "Sync finished"
  echo "All syncs finished. see $LOG_DIR/rclone.log for details."

  # cleanup (lock released automatically on exit)
  return $exit_status
}

# run main
main
