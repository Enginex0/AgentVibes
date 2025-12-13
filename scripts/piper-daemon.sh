#!/bin/bash
#
# Piper TTS Daemon Control - Wrapper for systemd service
#
# Usage:
#   Start daemon:  ~/.claude/scripts/piper-daemon.sh start
#   Stop daemon:   ~/.claude/scripts/piper-daemon.sh stop
#   Restart:       ~/.claude/scripts/piper-daemon.sh restart
#   Status:        ~/.claude/scripts/piper-daemon.sh status
#   Speak text:    ~/.claude/scripts/piper-daemon.sh speak "Hello world"
#

SERVICE_NAME="piper-tts"
DAEMON_DIR="$HOME/.claude/piper-daemon"
FIFO_IN="$DAEMON_DIR/input.fifo"
VOICE_FILE="$HOME/.claude/tts-voice.txt"
VOICES_DIR="$HOME/.claude/piper-voices"

# Get current voice
get_voice() {
  local voice="en_US-lessac-medium"
  [[ -f "$VOICE_FILE" ]] && voice=$(cat "$VOICE_FILE")
  echo "$voice"
}

# Check if systemd user session is available
check_systemd() {
  if ! systemctl --user status >/dev/null 2>&1; then
    echo "ERROR: systemd user session not available" >&2
    echo "Try: loginctl enable-linger $USER" >&2
    return 1
  fi
  return 0
}

start_daemon() {
  check_systemd || return 1

  # Reload daemon to pick up any service file changes
  systemctl --user daemon-reload

  if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    echo "Daemon already running"
    systemctl --user status "$SERVICE_NAME" --no-pager | head -3
    return 0
  fi

  echo "Starting Piper TTS daemon with voice: $(get_voice)"
  systemctl --user start "$SERVICE_NAME"

  # Wait briefly for startup
  sleep 0.5

  if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    echo "Daemon started successfully"
  else
    echo "Failed to start daemon" >&2
    systemctl --user status "$SERVICE_NAME" --no-pager
    return 1
  fi
}

stop_daemon() {
  check_systemd || return 1

  if ! systemctl --user is-active --quiet "$SERVICE_NAME"; then
    echo "Daemon not running"
    return 0
  fi

  echo "Stopping Piper TTS daemon..."
  systemctl --user stop "$SERVICE_NAME"
  echo "Daemon stopped"
}

restart_daemon() {
  check_systemd || return 1

  echo "Restarting Piper TTS daemon with voice: $(get_voice)"
  systemctl --user daemon-reload
  systemctl --user restart "$SERVICE_NAME"

  # Wait briefly for startup
  sleep 0.5

  if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    echo "Daemon restarted successfully"
  else
    echo "Failed to restart daemon" >&2
    systemctl --user status "$SERVICE_NAME" --no-pager
    return 1
  fi
}

status() {
  check_systemd || return 1

  if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    echo "Daemon running"
    echo "Voice: $(get_voice)"
    echo ""
    systemctl --user status "$SERVICE_NAME" --no-pager | head -10
  else
    echo "Daemon not running"
  fi
}

speak() {
  local text="$1"

  # Ensure FIFO exists
  mkdir -p "$DAEMON_DIR"

  # Auto-start if not running
  if ! systemctl --user is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
    echo "Daemon not running, starting..."
    start_daemon
    sleep 1
  fi

  # Send text to daemon
  if [[ -p "$FIFO_IN" ]]; then
    echo "$text" > "$FIFO_IN"
  else
    echo "ERROR: FIFO not available" >&2
    return 1
  fi
}

enable_daemon() {
  check_systemd || return 1
  systemctl --user enable "$SERVICE_NAME"
  echo "Daemon enabled (will start on login)"
}

disable_daemon() {
  check_systemd || return 1
  systemctl --user disable "$SERVICE_NAME"
  echo "Daemon disabled (won't start on login)"
}

logs() {
  journalctl --user -u "$SERVICE_NAME" -f
}

cleanup() {
  # Kill any orphaned processes (legacy cleanup)
  pkill -9 -f "piper.*\.onnx" 2>/dev/null || true
  pkill -9 -f "tail.*piper-daemon/input.fifo" 2>/dev/null || true
  pkill -9 -f "paplay.*raw.*22050" 2>/dev/null || true
  rm -f "$FIFO_IN"
  echo "Cleaned up all piper processes"
}

case "${1:-}" in
  start)
    start_daemon
    ;;
  stop)
    stop_daemon
    ;;
  restart)
    restart_daemon
    ;;
  status)
    status
    ;;
  speak)
    speak "${2:-}"
    ;;
  enable)
    enable_daemon
    ;;
  disable)
    disable_daemon
    ;;
  logs)
    logs
    ;;
  cleanup)
    cleanup
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|speak \"text\"|enable|disable|logs|cleanup}"
    exit 1
    ;;
esac
