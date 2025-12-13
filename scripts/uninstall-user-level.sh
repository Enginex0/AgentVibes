#!/bin/bash
#
# AgentVibes User-Level Uninstall Script
#
# This script removes AgentVibes configuration when uninstalled via npm.
# It preserves user-customized files (hooks, personalities, configs).
#
# Run automatically via npm preuninstall or manually: bash scripts/uninstall-user-level.sh
#

set -uo pipefail

USER_CLAUDE="$HOME/.claude"
AGGREGATOR_CONFIG="$USER_CLAUDE/mcp-aggregator/config.json"

echo "=== AgentVibes Uninstall ==="
echo ""

# Step 1: Remove from MCP Aggregator (if configured)
echo "[1/4] Removing from MCP configuration..."
MCP_REMOVED=false

if [[ -f "$AGGREGATOR_CONFIG" ]]; then
  if command -v jq &>/dev/null; then
    if jq -e '.servers.agentvibes' "$AGGREGATOR_CONFIG" &>/dev/null; then
      TEMP_CONFIG=$(mktemp)
      jq 'del(.servers.agentvibes)' "$AGGREGATOR_CONFIG" > "$TEMP_CONFIG" && mv "$TEMP_CONFIG" "$AGGREGATOR_CONFIG"
      echo "  Removed AgentVibes from aggregator config"
      echo "  NOTE: Reload aggregator in Claude to apply (use reload_config tool)"
      MCP_REMOVED=true
    else
      echo "  AgentVibes not found in aggregator config"
    fi
  else
    echo "  Warning: jq not installed, cannot update aggregator config"
  fi
fi

# Also try to remove from Claude direct MCP (if exists)
if command -v claude &>/dev/null; then
  if claude mcp get agentvibes &>/dev/null 2>&1; then
    # Try all scopes
    claude mcp remove agentvibes -s user 2>/dev/null && echo "  Removed from Claude (user scope)" && MCP_REMOVED=true
    claude mcp remove agentvibes -s local 2>/dev/null && echo "  Removed from Claude (local scope)" && MCP_REMOVED=true
    claude mcp remove agentvibes -s project 2>/dev/null && echo "  Removed from Claude (project scope)" && MCP_REMOVED=true
  fi
fi

if [[ "$MCP_REMOVED" == "false" ]]; then
  echo "  No MCP configuration found to remove"
fi

# Step 2: Stop and disable systemd service (Linux only)
echo "[2/4] Removing systemd service..."
if [[ "$(uname)" == "Linux" ]] && command -v systemctl &>/dev/null; then
  if systemctl --user is-active piper-tts &>/dev/null; then
    systemctl --user stop piper-tts 2>/dev/null && echo "  Stopped piper-tts service"
  fi
  if systemctl --user is-enabled piper-tts &>/dev/null; then
    systemctl --user disable piper-tts 2>/dev/null && echo "  Disabled piper-tts service"
  fi
  if [[ -f "$HOME/.config/systemd/user/piper-tts.service" ]]; then
    rm -f "$HOME/.config/systemd/user/piper-tts.service"
    systemctl --user daemon-reload 2>/dev/null
    echo "  Removed systemd service file"
  else
    echo "  No systemd service found"
  fi
else
  echo "  Skipped (not Linux or systemctl not available)"
fi

# Step 3: Remove user-level marker
echo "[3/4] Removing user-level marker..."
if [[ -f "$USER_CLAUDE/agentvibes-user-level" ]]; then
  rm -f "$USER_CLAUDE/agentvibes-user-level"
  echo "  Removed agentvibes-user-level marker"
else
  echo "  Marker not found"
fi

# Step 4: Clean up AgentVibes-specific files (preserve user customizations)
echo "[4/4] Cleaning up AgentVibes files..."

# Remove daemon scripts (these are AgentVibes-specific)
if [[ -f "$USER_CLAUDE/scripts/piper-worker-enhanced.sh" ]]; then
  rm -f "$USER_CLAUDE/scripts/piper-worker-enhanced.sh"
  rm -f "$USER_CLAUDE/scripts/piper-daemon.sh"
  echo "  Removed daemon scripts"
fi

# Remove evil laugh audio (AgentVibes-specific)
if [[ -f "$USER_CLAUDE/audio/evil-laugh.wav" ]]; then
  rm -f "$USER_CLAUDE/audio/evil-laugh.wav"
  echo "  Removed evil-laugh.wav"
fi

# Remove piper-daemon directory
if [[ -d "$USER_CLAUDE/piper-daemon" ]]; then
  rm -rf "$USER_CLAUDE/piper-daemon"
  echo "  Removed piper-daemon directory"
fi

# Note: We preserve hooks, personalities, and config files
# as they may have been customized by the user
echo ""
echo "=== Uninstall Complete ==="
echo ""
echo "The following were preserved (may contain user customizations):"
echo "  - $USER_CLAUDE/hooks/"
echo "  - $USER_CLAUDE/personalities/"
echo "  - $USER_CLAUDE/tts-*.txt config files"
echo ""
echo "To fully remove all AgentVibes files, manually delete:"
echo "  rm -rf $USER_CLAUDE/hooks/"
echo "  rm -rf $USER_CLAUDE/personalities/"
echo "  rm -f $USER_CLAUDE/tts-*.txt"
echo ""
