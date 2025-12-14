#!/usr/bin/env bash
#
# AgentVibes Log Viewer & Analyzer
#
# Commands:
#   ./log-viewer.sh              - Show recent logs (last 50 lines)
#   ./log-viewer.sh tail         - Follow logs in real-time
#   ./log-viewer.sh errors       - Show only errors
#   ./log-viewer.sh daemon       - Show daemon logs
#   ./log-viewer.sh latency      - Analyze latency (show duration times)
#   ./log-viewer.sh session      - Show latest session log
#   ./log-viewer.sh clean        - Delete all logs
#   ./log-viewer.sh stats        - Show log statistics
#

set -euo pipefail

LOG_DIR="$HOME/.claude/logs/agentvibes"
SESSION_LOG_PATTERN="session-*.log"
ERROR_LOG="$LOG_DIR/errors.log"
DAEMON_LOG="$LOG_DIR/daemon.log"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
  echo "AgentVibes Log Viewer"
  echo ""
  echo "Usage: $0 [command]"
  echo ""
  echo "Commands:"
  echo "  (none)    Show recent logs (last 50 lines from all sessions)"
  echo "  tail      Follow logs in real-time"
  echo "  errors    Show only error entries"
  echo "  daemon    Show daemon-specific logs"
  echo "  latency   Analyze latency (show duration times)"
  echo "  session   Show the latest session log"
  echo "  all       Show all logs (may be large)"
  echo "  clean     Delete all logs"
  echo "  stats     Show log statistics"
  echo ""
  echo "Log directory: $LOG_DIR"
}

# Ensure log directory exists
ensure_log_dir() {
  if [[ ! -d "$LOG_DIR" ]]; then
    echo "No log directory found at: $LOG_DIR"
    echo "Logs will be created when AgentVibes runs with AGENTVIBES_DEBUG=1"
    exit 1
  fi
}

# Get latest session log file
get_latest_session_log() {
  ls -t "$LOG_DIR"/$SESSION_LOG_PATTERN 2>/dev/null | head -1
}

# Show recent logs
show_recent() {
  ensure_log_dir
  echo -e "${BLUE}=== Recent AgentVibes Logs (last 50 lines) ===${NC}"
  echo ""

  # Combine and sort all session logs by timestamp
  cat "$LOG_DIR"/$SESSION_LOG_PATTERN 2>/dev/null | sort -t'[' -k2 | tail -50 | while read -r line; do
    if [[ "$line" =~ \[ERROR\] ]]; then
      echo -e "${RED}$line${NC}"
    elif [[ "$line" =~ \[WARN\] ]]; then
      echo -e "${YELLOW}$line${NC}"
    elif [[ "$line" =~ ms\] ]]; then
      # Highlight duration measurements
      echo -e "${GREEN}$line${NC}"
    else
      echo "$line"
    fi
  done
}

# Follow logs in real-time
follow_logs() {
  ensure_log_dir
  echo -e "${BLUE}=== Following AgentVibes Logs (Ctrl+C to stop) ===${NC}"
  echo ""

  # Follow all log files
  tail -f "$LOG_DIR"/*.log 2>/dev/null | while read -r line; do
    if [[ "$line" =~ \[ERROR\] ]]; then
      echo -e "${RED}$line${NC}"
    elif [[ "$line" =~ \[WARN\] ]]; then
      echo -e "${YELLOW}$line${NC}"
    elif [[ "$line" =~ ms\] ]]; then
      echo -e "${GREEN}$line${NC}"
    else
      echo "$line"
    fi
  done
}

# Show only errors
show_errors() {
  ensure_log_dir
  echo -e "${RED}=== AgentVibes Errors ===${NC}"
  echo ""

  if [[ -f "$ERROR_LOG" ]]; then
    cat "$ERROR_LOG"
  fi

  # Also grep for errors in session logs
  grep -h "\[ERROR\]" "$LOG_DIR"/$SESSION_LOG_PATTERN 2>/dev/null | sort -t'[' -k2 || echo "No errors found in session logs"
}

# Show daemon logs
show_daemon() {
  ensure_log_dir
  echo -e "${BLUE}=== Daemon Logs ===${NC}"
  echo ""

  if [[ -f "$DAEMON_LOG" ]]; then
    tail -100 "$DAEMON_LOG" | while read -r line; do
      if [[ "$line" =~ \[ERROR\] ]]; then
        echo -e "${RED}$line${NC}"
      elif [[ "$line" =~ \[WARN\] ]]; then
        echo -e "${YELLOW}$line${NC}"
      elif [[ "$line" =~ ms\] ]]; then
        echo -e "${GREEN}$line${NC}"
      else
        echo "$line"
      fi
    done
  else
    echo "No daemon log found at: $DAEMON_LOG"
  fi
}

# Analyze latency
analyze_latency() {
  ensure_log_dir
  echo -e "${BLUE}=== Latency Analysis ===${NC}"
  echo ""

  echo "Recent operations with timing (from all logs):"
  echo ""

  # Extract all lines with duration measurements [XXXms]
  grep -hE '\[[0-9]+ms\]' "$LOG_DIR"/*.log 2>/dev/null | sort -t'[' -k2 | tail -50 | while read -r line; do
    # Extract duration
    duration=$(echo "$line" | grep -oE '\[[0-9]+ms\]' | tr -d '[]ms')

    if [[ -n "$duration" ]]; then
      if [[ "$duration" -gt 1000 ]]; then
        echo -e "${RED}SLOW (${duration}ms): $line${NC}"
      elif [[ "$duration" -gt 500 ]]; then
        echo -e "${YELLOW}MODERATE (${duration}ms): $line${NC}"
      else
        echo -e "${GREEN}FAST (${duration}ms): $line${NC}"
      fi
    fi
  done

  echo ""
  echo "--- Summary ---"

  # Calculate average latency for key operations
  for op in "FIFO_WRITE" "PIPER_SYNTH" "AUDIO_PLAYBACK" "DAEMON_CHECK" "TTS_REQUEST" "PROCESS_TTS"; do
    times=$(grep -hE "END: $op.*\[[0-9]+ms\]" "$LOG_DIR"/*.log 2>/dev/null | grep -oE '\[[0-9]+ms\]' | tr -d '[]ms')
    if [[ -n "$times" ]]; then
      count=$(echo "$times" | wc -l)
      total=0
      max=0
      min=999999
      while read -r t; do
        total=$((total + t))
        [[ "$t" -gt "$max" ]] && max=$t
        [[ "$t" -lt "$min" ]] && min=$t
      done <<< "$times"
      avg=$((total / count))
      echo "$op: avg=${avg}ms, min=${min}ms, max=${max}ms (n=$count)"
    fi
  done
}

# Show latest session log
show_session() {
  ensure_log_dir
  local latest
  latest=$(get_latest_session_log)

  if [[ -n "$latest" ]] && [[ -f "$latest" ]]; then
    echo -e "${BLUE}=== Latest Session Log: $(basename "$latest") ===${NC}"
    echo ""
    cat "$latest" | while read -r line; do
      if [[ "$line" =~ \[ERROR\] ]]; then
        echo -e "${RED}$line${NC}"
      elif [[ "$line" =~ \[WARN\] ]]; then
        echo -e "${YELLOW}$line${NC}"
      elif [[ "$line" =~ ms\] ]]; then
        echo -e "${GREEN}$line${NC}"
      else
        echo "$line"
      fi
    done
  else
    echo "No session logs found"
  fi
}

# Show all logs
show_all() {
  ensure_log_dir
  echo -e "${BLUE}=== All AgentVibes Logs ===${NC}"
  echo ""

  for logfile in "$LOG_DIR"/*.log; do
    if [[ -f "$logfile" ]]; then
      echo -e "${YELLOW}--- $(basename "$logfile") ---${NC}"
      cat "$logfile"
      echo ""
    fi
  done
}

# Clean logs
clean_logs() {
  ensure_log_dir
  echo -e "${YELLOW}=== Cleaning AgentVibes Logs ===${NC}"

  local count
  count=$(ls -1 "$LOG_DIR"/*.log 2>/dev/null | wc -l)

  if [[ "$count" -eq 0 ]]; then
    echo "No logs to clean"
    exit 0
  fi

  echo "Found $count log file(s) in $LOG_DIR"
  read -p "Delete all logs? [y/N]: " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f "$LOG_DIR"/*.log
    echo -e "${GREEN}Logs cleaned${NC}"
  else
    echo "Cancelled"
  fi
}

# Show stats
show_stats() {
  ensure_log_dir
  echo -e "${BLUE}=== Log Statistics ===${NC}"
  echo ""

  echo "Log directory: $LOG_DIR"
  echo ""

  echo "Log files:"
  ls -lh "$LOG_DIR"/*.log 2>/dev/null | awk '{print "  " $9 ": " $5}'
  echo ""

  echo "Total size: $(du -sh "$LOG_DIR" 2>/dev/null | cut -f1)"
  echo ""

  echo "Entry counts:"
  echo "  Total entries: $(cat "$LOG_DIR"/*.log 2>/dev/null | wc -l)"
  echo "  Errors: $(grep -ch "\[ERROR\]" "$LOG_DIR"/*.log 2>/dev/null | awk '{sum+=$1} END {print sum}')"
  echo "  Warnings: $(grep -ch "\[WARN\]" "$LOG_DIR"/*.log 2>/dev/null | awk '{sum+=$1} END {print sum}')"
  echo ""

  echo "Session logs: $(ls -1 "$LOG_DIR"/$SESSION_LOG_PATTERN 2>/dev/null | wc -l)"

  local latest
  latest=$(get_latest_session_log)
  if [[ -n "$latest" ]]; then
    echo "Latest session: $(basename "$latest")"
  fi
}

# Main command handler
case "${1:-}" in
  tail)
    follow_logs
    ;;
  errors)
    show_errors
    ;;
  daemon)
    show_daemon
    ;;
  latency)
    analyze_latency
    ;;
  session)
    show_session
    ;;
  all)
    show_all
    ;;
  clean)
    clean_logs
    ;;
  stats)
    show_stats
    ;;
  help|--help|-h)
    usage
    ;;
  "")
    show_recent
    ;;
  *)
    echo "Unknown command: $1"
    echo ""
    usage
    exit 1
    ;;
esac
