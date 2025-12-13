#!/bin/bash
#
# AgentVibes User-Level Auto-Setup Script
#
# This script automatically configures AgentVibes for user-level operation,
# enabling TTS across ALL projects with zero manual configuration.
#
# Run automatically via postinstall or manually: bash scripts/install-user-level.sh
#

set -euo pipefail

USER_CLAUDE="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

AGGREGATOR_CONFIG="$USER_CLAUDE/mcp-aggregator/config.json"
# Use stable user directory for MCP server (not volatile NPX cache)
MCP_SERVER="$USER_CLAUDE/mcp-server/server.py"

echo "=== AgentVibes User-Level Setup ==="
echo "Package: $PACKAGE_DIR"
echo "Target: $USER_CLAUDE"
echo ""

# Create directory structure
echo "[1/10] Creating directory structure..."
mkdir -p "$USER_CLAUDE"/{hooks,personalities,commands,config,audio,scripts,piper-daemon,mcp-server}

# Copy hooks (already patched with user-level support)
echo "[2/10] Installing hooks..."
if [[ -d "$PACKAGE_DIR/.claude/hooks" ]]; then
  cp -r "$PACKAGE_DIR/.claude/hooks/"* "$USER_CLAUDE/hooks/" 2>/dev/null || true
  chmod +x "$USER_CLAUDE/hooks/"*.sh 2>/dev/null || true
  echo "  Copied $(ls "$USER_CLAUDE/hooks/"*.sh 2>/dev/null | wc -l) hook scripts"
fi

# Copy personalities (with voice assignments)
echo "[3/10] Installing personalities..."
if [[ -d "$PACKAGE_DIR/.claude/personalities" ]]; then
  cp -r "$PACKAGE_DIR/.claude/personalities/"* "$USER_CLAUDE/personalities/" 2>/dev/null || true
  echo "  Copied $(ls "$USER_CLAUDE/personalities/" 2>/dev/null | wc -l) personality files"
fi

# Copy slash commands (for /agent-vibes:* commands)
echo "[4/10] Installing slash commands..."
if [[ -d "$PACKAGE_DIR/.claude/commands" ]]; then
  cp -r "$PACKAGE_DIR/.claude/commands/"* "$USER_CLAUDE/commands/" 2>/dev/null || true
  # Count total commands including subdirectories
  CMD_COUNT=$(find "$USER_CLAUDE/commands" -name "*.md" 2>/dev/null | wc -l)
  echo "  Copied $CMD_COUNT slash command files"
fi

# Copy enhanced scripts
echo "[5/10] Installing daemon scripts..."
if [[ -f "$PACKAGE_DIR/scripts/piper-worker-enhanced.sh" ]]; then
  cp "$PACKAGE_DIR/scripts/piper-worker-enhanced.sh" "$USER_CLAUDE/scripts/"
  cp "$PACKAGE_DIR/scripts/piper-daemon.sh" "$USER_CLAUDE/scripts/"
  chmod +x "$USER_CLAUDE/scripts/"*.sh 2>/dev/null || true
  echo "  Installed piper daemon scripts"
fi

# Copy audio assets
echo "[6/10] Installing audio assets..."
if [[ -d "$PACKAGE_DIR/audio" ]]; then
  cp -r "$PACKAGE_DIR/audio/"* "$USER_CLAUDE/audio/" 2>/dev/null || true
  echo "  Copied audio files"
fi

# Copy MCP server to stable user location (critical: avoids volatile NPX cache paths)
echo "[7/10] Installing MCP server..."
if [[ -f "$PACKAGE_DIR/mcp-server/server.py" ]]; then
  cp "$PACKAGE_DIR/mcp-server/server.py" "$USER_CLAUDE/mcp-server/"
  echo "  Copied server.py to stable location"

  # Try to install mcp Python package (required for server.py)
  if command -v pip3 &>/dev/null; then
    if pip3 install --user --quiet "mcp>=0.9.0" 2>/dev/null; then
      echo "  Installed MCP Python package"
    else
      echo "  Warning: Could not install mcp package (TTS shell mode still works)"
    fi
  elif command -v pip &>/dev/null; then
    if pip install --user --quiet "mcp>=0.9.0" 2>/dev/null; then
      echo "  Installed MCP Python package"
    else
      echo "  Warning: Could not install mcp package (TTS shell mode still works)"
    fi
  else
    echo "  Warning: pip not found, MCP server may not work (TTS shell mode still works)"
  fi
else
  echo "  Warning: server.py not found in package"
fi

# Create default configs (only if not exist - preserve user settings)
echo "[8/10] Setting up default configuration..."
[[ ! -f "$USER_CLAUDE/tts-provider.txt" ]] && echo "piper" > "$USER_CLAUDE/tts-provider.txt" && echo "  Set provider: piper"
[[ ! -f "$USER_CLAUDE/tts-voice.txt" ]] && echo "en_US-lessac-medium" > "$USER_CLAUDE/tts-voice.txt" && echo "  Set voice: en_US-lessac-medium"
[[ ! -f "$USER_CLAUDE/tts-verbosity.txt" ]] && echo "medium" > "$USER_CLAUDE/tts-verbosity.txt" && echo "  Set verbosity: medium"
[[ ! -f "$USER_CLAUDE/config/tts-save-audio.txt" ]] && echo "false" > "$USER_CLAUDE/config/tts-save-audio.txt" && echo "  Set save-audio: false"

# Enable user-level mode (marker file)
touch "$USER_CLAUDE/agentvibes-user-level"
echo "  User-level mode enabled"

# Install systemd service (Linux only)
echo "[9/10] Installing systemd service..."
if [[ "$(uname)" == "Linux" ]] && command -v systemctl &>/dev/null; then
  if [[ -f "$PACKAGE_DIR/systemd/piper-tts.service" ]]; then
    mkdir -p "$HOME/.config/systemd/user"

    # Update paths in service file to user's home and UID
    sed -e "s|/home/president|$HOME|g" -e "s|/run/user/1000|/run/user/$(id -u)|g" "$PACKAGE_DIR/systemd/piper-tts.service" > "$HOME/.config/systemd/user/piper-tts.service"

    systemctl --user daemon-reload 2>/dev/null || true
    echo "  Systemd service installed"
    echo "  Start with: systemctl --user start piper-tts"
    echo "  Enable auto-start: systemctl --user enable piper-tts"
  fi
else
  echo "  Skipped (not Linux or systemctl not available)"
fi

# Configure MCP Server (auto-detect aggregator vs direct)
echo "[10/10] Configuring MCP server..."
MCP_CONFIGURED=false

if [[ -f "$AGGREGATOR_CONFIG" ]]; then
  # Aggregator detected - add to aggregator config
  echo "  MCP Aggregator detected"

  # Check if jq is available for JSON manipulation
  if command -v jq &>/dev/null; then
    # Check if agentvibes already configured
    if jq -e '.servers.agentvibes' "$AGGREGATOR_CONFIG" &>/dev/null; then
      echo "  AgentVibes already configured in aggregator"
      MCP_CONFIGURED=true
    else
      # Add agentvibes to aggregator config with flock to prevent race conditions
      TEMP_CONFIG=$(mktemp)
      # Use flock to serialize concurrent config modifications
      if (
        flock -x -w 10 200 || { echo "  Warning: Could not acquire config lock" >&2; exit 1; }
        jq --arg mcp "$MCP_SERVER" '.servers.agentvibes = {
          "command": "python3",
          "args": [$mcp],
          "env": {}
        }' "$AGGREGATOR_CONFIG" > "$TEMP_CONFIG" && mv "$TEMP_CONFIG" "$AGGREGATOR_CONFIG"
      ) 200>"$AGGREGATOR_CONFIG.lock"; then
        echo "  Added AgentVibes to aggregator config"
        echo "  NOTE: Reload aggregator in Claude to activate (use reload_config tool)"
        MCP_CONFIGURED=true
      else
        echo "  Warning: Failed to update aggregator config"
        rm -f "$TEMP_CONFIG" 2>/dev/null
      fi
    fi
  else
    echo "  Warning: jq not installed, cannot update aggregator config"
    echo "  Install jq or manually add AgentVibes to $AGGREGATOR_CONFIG"
  fi
elif command -v claude &>/dev/null; then
  # No aggregator - use Claude CLI for direct MCP setup
  echo "  No aggregator found, using Claude CLI"

  # Check if already configured
  if claude mcp get agentvibes &>/dev/null 2>&1; then
    echo "  AgentVibes MCP already configured"
    MCP_CONFIGURED=true
  else
    # Add via Claude CLI (user scope for global availability)
    if claude mcp add --transport stdio --scope user agentvibes -- python3 "$MCP_SERVER" 2>/dev/null; then
      echo "  Added AgentVibes MCP server (user scope)"
      MCP_CONFIGURED=true
    else
      echo "  Warning: Failed to add MCP server via Claude CLI"
    fi
  fi
else
  echo "  Warning: Neither aggregator nor Claude CLI found"
  echo "  Manual MCP setup required"
fi

if [[ "$MCP_CONFIGURED" == "true" ]]; then
  echo "  MCP server configured successfully"
fi

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "AgentVibes is now configured for user-level operation."
echo ""
echo "Next steps:"
echo "  1. Install Piper TTS: pipx install piper-tts"
echo "  2. Download a voice: ~/.claude/hooks/piper-voice-manager.sh download en_US-lessac-medium"
echo "  3. Start the daemon: systemctl --user start piper-tts"
echo "  4. Test TTS: ~/.claude/hooks/play-tts.sh 'Hello world!'"
echo ""
echo "Configuration files:"
echo "  Voice:       $USER_CLAUDE/tts-voice.txt"
echo "  Personality: $USER_CLAUDE/tts-personality.txt"
echo "  Verbosity:   $USER_CLAUDE/tts-verbosity.txt"
echo ""
