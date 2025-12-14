#!/usr/bin/env bash
#
# AgentVibes TTS Mode Toggle
# Switches between MCP (fast) and Bash (fallback) modes for TTS
#
# Usage: ./tts-mode-toggle.sh [mcp|bash|status]
#
# This script updates the symlink at session-start-tts.sh to point
# to either session-start-mcp-tts.sh or session-start-bash-tts.sh.
# Zero runtime overhead - symlink is resolved by kernel at file open.
#

set -euo pipefail

HOOKS_DIR="$HOME/.claude/hooks"
SYMLINK="$HOOKS_DIR/session-start-tts.sh"
MCP_HOOK="session-start-mcp-tts.sh"
BASH_HOOK="session-start-bash-tts.sh"

get_current_mode() {
  if [[ -L "$SYMLINK" ]]; then
    local target
    target=$(readlink "$SYMLINK")
    if [[ "$target" == "$MCP_HOOK" ]]; then
      echo "mcp"
    elif [[ "$target" == "$BASH_HOOK" ]]; then
      echo "bash"
    else
      echo "unknown ($target)"
    fi
  elif [[ -f "$SYMLINK" ]]; then
    # Not a symlink - check file content for mode
    if grep -q "mcp__aggregator__call_tool" "$SYMLINK" 2>/dev/null; then
      echo "mcp (file, not symlink)"
    else
      echo "bash (file, not symlink)"
    fi
  else
    echo "not configured"
  fi
}

set_mode() {
  local mode="$1"
  local target_hook

  case "$mode" in
    mcp)
      target_hook="$MCP_HOOK"
      ;;
    bash)
      target_hook="$BASH_HOOK"
      ;;
    *)
      echo "Error: Invalid mode '$mode'. Use 'mcp' or 'bash'" >&2
      exit 1
      ;;
  esac

  # Check if target hook exists
  if [[ ! -f "$HOOKS_DIR/$target_hook" ]]; then
    echo "Error: Target hook not found: $HOOKS_DIR/$target_hook" >&2
    exit 1
  fi

  # Remove existing symlink/file
  rm -f "$SYMLINK"

  # Create new symlink (relative path for portability)
  ln -s "$target_hook" "$SYMLINK"

  echo "TTS mode switched to: $mode"
  echo "Symlink: session-start-tts.sh -> $target_hook"
  echo ""
  echo "IMPORTANT: Restart Claude Code for changes to take effect!"
}

show_status() {
  local current
  current=$(get_current_mode)

  echo "=== AgentVibes TTS Mode ==="
  echo ""
  echo "Current mode: $current"
  echo ""

  if [[ -L "$SYMLINK" ]]; then
    echo "Symlink target: $(readlink "$SYMLINK")"
  fi

  echo ""
  echo "Available modes:"
  echo "  mcp  - Uses MCP aggregator (faster, ~50-100ms)"
  echo "  bash - Uses Bash subprocess (fallback, ~160-290ms)"
  echo ""
  echo "Usage: $0 [mcp|bash|status]"
  echo ""

  # Show which hooks exist
  echo "Installed hooks:"
  [[ -f "$HOOKS_DIR/$MCP_HOOK" ]] && echo "  [x] $MCP_HOOK" || echo "  [ ] $MCP_HOOK (missing)"
  [[ -f "$HOOKS_DIR/$BASH_HOOK" ]] && echo "  [x] $BASH_HOOK" || echo "  [ ] $BASH_HOOK (missing)"
}

# Main
case "${1:-status}" in
  mcp|bash)
    set_mode "$1"
    ;;
  status)
    show_status
    ;;
  *)
    echo "Usage: $0 [mcp|bash|status]" >&2
    exit 1
    ;;
esac
