#!/bin/bash
# rclone sync script using user rclone-sync.service and timer
# start and enable the timer using systemd
# systemctl --user start rclone-sync.timer
# journalctl --user -u rclone-sync.service -f       - live log
# journalctl --user -u rclone-sync.service -e       - -e recent logs OR -b logs since boot
# journalctl --user -u rclone-sync.service -p err   - check for errors

# exit on error, undefined vars, and pipe failures
set -euo pipefail

# array mapping remote:paths to local paths
declare -A SYNC_PATHS=(
  ["protondrive:Arch"]="$HOME/Documents/Yovel"
  ["gdrive:Arch/School"]="$HOME/Documents/School"
  ["gdrive:Arch/UserWorkspace"]="$HOME/UserWorkspace"
  ["gdrive:Arch/UserWorkspace/zephyr-workspace"]="$HOME/UserWorkspace/zephyr-workspace/projects"
)

# path exclusion patterns
declare -A EXTRA_EXCLUDES=(
  ["protondrive:Arch"]="
- /books/**
"
  ["gdrive:Arch/UserWorkspace"]="
- /zephyr-workspace/**
- /codeberg/**
- /kicad/custom-libraries/**
- /kicad/exercises/**
- /kicad/projects/**
- /stm32/**
- /stm32/Repository/**
- /stm32/examples/**
"
)

# rclone optimization and performance flags
RCLONE_FLAGS=(
  --transfers=16                                   # number of files to transfer in parallel
  --checkers=16                                    # number of hash checking operations to run in parallel
  --buffer-size=64M                                # size of in memory buffer for each transfer
  --drive-chunk-size=64M                           # size of chunks for upload to Google Drive
  --fast-list                                      # use recursive list if available (faster for large directories)
  --tpslimit=16                                    # limit API calls per second to avoid rate limiting
  --tpslimit-burst=16                              # allow bursts of up to 32 API calls
  --multi-thread-streams=4                         # number of streams to use for multi thread downloads
  --multi-thread-cutoff=64M                        # files larger than this use multi thread transfers
  --drive-acknowledge-abuse                        # skip Google Drive warning for flagged files
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
  --log-level=ERROR
  --filter-from="$HOME/.config/rclone/filters.txt"
)

# check network connectivity with a retry loop (useful for systemd boot/wake)
check_network() {
  local max_attempts=6 # 6 attempts * 10s = 60s timeout
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    if ping -c 1 1.1.1.1 >/dev/null 2>&1; then
      return 0
    fi
    echo "network not ready, waiting 10s (attempt $attempt/$max_attempts)..."
    sleep 10
    ((attempt++))
  done
  echo "error: no network connectivity after waiting" >&2
  return 1
}

# core sync function with filter support
perform_sync() {
  local source="$1"
  local dest="$2"
  local extra_excludes="${3:-}"

  # choose flags based on remote
  local flags=("${RCLONE_FLAGS[@]}")
  if [[ "$dest" == protondrive:* ]]; then
    flags=("${PROTON_RCLONE_FLAGS[@]}")
  fi

  local extra_filter_file=""
  if [ -n "$extra_excludes" ]; then
    extra_filter_file=$(mktemp)
    echo "$extra_excludes" >"$extra_filter_file"

    # ensure temp file is cleaned up on any exit
    trap 'rm -f "$extra_filter_file"' EXIT

    echo "syncing $source to $dest with additional filters"
    if ! rclone sync "${flags[@]}" --filter-from="$extra_filter_file" "$source" "$dest"; then
      echo "error syncing $source to $dest" >&2
      return 1
    fi
  else
    echo "syncing $source to $dest"
    if ! rclone sync "${flags[@]}" "$source" "$dest"; then
      echo "error syncing $source to $dest" >&2
      return 1
    fi
  fi
}

# main function
main() {
  # check network connectivity
  if ! check_network; then
    exit 1
  fi

  # check for global filters file
  if [ ! -f "$HOME/.config/rclone/filters.txt" ]; then
    echo "error: global filters file missing" >&2
    exit 1
  fi

  # perform syncs in parallel for all jobs (only 4 jobs)
  echo "sync started"
  local exit_status=0
  local -a pids=()
  for dest in "${!SYNC_PATHS[@]}"; do
    local source="${SYNC_PATHS[$dest]}"

    perform_sync "$source" "$dest" "${EXTRA_EXCLUDES[$dest]:-}" &
    pids+=($!) # append the PID to the array
  done

  # wait for all remaining syncs to finish
  for pid in "${pids[@]}"; do
    wait "$pid" || exit_status=1
  done

  echo "sync finished"
  return "$exit_status"
}

# run main
main
