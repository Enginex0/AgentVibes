#!/bin/bash
#
# AgentVibes User-Level Uninstall Script
#
# This script removes AgentVibes configuration when uninstalled via npm.
# It preserves user-customized files (hooks, personalities, configs).
#
# Run automatically via npm preuninstall or manually: bash scripts/uninstall-user-level.sh
#

set -euo pipefail

USER_CLAUDE="$HOME/.claude"
AGGREGATOR_CONFIG="$USER_CLAUDE/mcp-aggregator/config.json"

echo "=== AgentVibes Uninstall ==="
echo ""

# Step 1: Remove from MCP Aggregator (if configured)
echo "[1/5] Removing from MCP configuration..."
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
echo "[2/5] Removing systemd service..."
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
echo "[3/5] Removing user-level marker..."
if [[ -f "$USER_CLAUDE/agentvibes-user-level" ]]; then
  rm -f "$USER_CLAUDE/agentvibes-user-level"
  echo "  Removed agentvibes-user-level marker"
else
  echo "  Marker not found"
fi

# Step 4: Clean up ALL AgentVibes files (complete removal)
echo "[4/5] Cleaning up AgentVibes files..."

# Remove daemon scripts
if [[ -d "$USER_CLAUDE/scripts" ]]; then
  rm -f "$USER_CLAUDE/scripts/piper-worker-enhanced.sh"
  rm -f "$USER_CLAUDE/scripts/piper-daemon.sh"
  rm -f "$USER_CLAUDE/scripts/piper-queue-worker.sh"
  rm -f "$USER_CLAUDE/scripts/piper-worker.sh"
  rm -f "$USER_CLAUDE/scripts/mcp-tts-play.sh"
  echo "  Removed daemon scripts"
fi

# Remove piper-daemon directory
if [[ -d "$USER_CLAUDE/piper-daemon" ]]; then
  rm -rf "$USER_CLAUDE/piper-daemon"
  echo "  Removed piper-daemon directory"
fi

# Remove piper-queue directory
if [[ -d "$USER_CLAUDE/piper-queue" ]]; then
  rm -rf "$USER_CLAUDE/piper-queue"
  echo "  Removed piper-queue directory"
fi

# Remove piper-voices directory (downloaded voice models)
if [[ -d "$USER_CLAUDE/piper-voices" ]]; then
  rm -rf "$USER_CLAUDE/piper-voices"
  echo "  Removed piper-voices directory"
fi

# Remove piper-voices-dir.txt
rm -f "$USER_CLAUDE/piper-voices-dir.txt" 2>/dev/null

# Remove MCP server directory (stable location for server.py)
if [[ -d "$USER_CLAUDE/mcp-server" ]]; then
  rm -rf "$USER_CLAUDE/mcp-server"
  echo "  Removed mcp-server directory"
fi

# Remove audio directory (AgentVibes sounds)
if [[ -d "$USER_CLAUDE/audio" ]]; then
  rm -rf "$USER_CLAUDE/audio"
  echo "  Removed audio directory"
fi

# Remove personalities directory
if [[ -d "$USER_CLAUDE/personalities" ]]; then
  rm -rf "$USER_CLAUDE/personalities"
  echo "  Removed personalities directory"
fi

# Remove TTS config files
rm -f "$USER_CLAUDE/tts-voice.txt" \
      "$USER_CLAUDE/tts-personality.txt" \
      "$USER_CLAUDE/tts-provider.txt" \
      "$USER_CLAUDE/tts-verbosity.txt" \
      "$USER_CLAUDE/tts-skip-padding.txt" \
      "$USER_CLAUDE/tts-speed.txt" \
      "$USER_CLAUDE/tts-target-speed.txt" \
      "$USER_CLAUDE/tts-learn-mode.txt" \
      "$USER_CLAUDE/tts-main-language.txt" \
      "$USER_CLAUDE/tts-target-language.txt" \
      2>/dev/null
echo "  Removed TTS config files"

# Remove AgentVibes config files
if [[ -d "$USER_CLAUDE/config" ]]; then
  rm -f "$USER_CLAUDE/config/audio-effects.cfg" \
        "$USER_CLAUDE/config/background-music-enabled.txt" \
        "$USER_CLAUDE/config/background-music-volume.txt" \
        "$USER_CLAUDE/config/background-music-default.txt" \
        "$USER_CLAUDE/config/tts-save-audio.txt" \
        "$USER_CLAUDE/config/tts-speech-rate.txt" \
        "$USER_CLAUDE/config/tts-target-speech-rate.txt" \
        "$USER_CLAUDE/config/piper-speech-rate.txt" \
        "$USER_CLAUDE/config/piper-target-speech-rate.txt" \
        2>/dev/null
  echo "  Removed AgentVibes config files"
fi

# Remove ALL AgentVibes hooks (by specific filenames to avoid removing non-AgentVibes hooks)
echo "[5/5] Removing AgentVibes hooks..."
HOOKS_DIR="$USER_CLAUDE/hooks"
if [[ -d "$HOOKS_DIR" ]]; then
  # List of AgentVibes hook files to remove
  AGENTVIBES_HOOKS=(
    "README-TTS-QUEUE.md"
    "audio-processor.sh"
    "background-music-manager.sh"
    "bmad-speak-enhanced.sh"
    "bmad-speak.sh"
    "bmad-tts-injector.sh"
    "bmad-voice-manager.sh"
    "configure-rdp-mode.sh"
    "download-extra-voices.sh"
    "effects-manager.sh"
    "github-star-reminder.sh"
    "language-manager.sh"
    "learn-manager.sh"
    "macos-voice-manager.sh"
    "migrate-background-music.sh"
    "migrate-to-agentvibes.sh"
    "optimize-background-music.sh"
    "personality-manager.sh"
    "piper-download-voices.sh"
    "piper-installer.sh"
    "piper-multispeaker-registry.sh"
    "piper-voice-manager.sh"
    "play-tts-elevenlabs.sh"
    "play-tts-enhanced.sh"
    "play-tts-macos.sh"
    "play-tts-piper.sh"
    "play-tts.sh"
    "prepare-release.sh"
    "provider-commands.sh"
    "provider-manager.sh"
    "replay-target-audio.sh"
    "requirements.txt"
    "sentiment-manager.sh"
    "session-start-mcp-tts.sh"
    "session-start-tts.sh"
    "speed-manager.sh"
    "translate-manager.sh"
    "translator.py"
    "tts-queue-worker.sh"
    "tts-queue.sh"
    "verbosity-manager.sh"
    "voice-manager.sh"
    "voices-config.sh"
    "logging-utils.sh"
  )

  HOOKS_REMOVED=0
  for hook in "${AGENTVIBES_HOOKS[@]}"; do
    if [[ -f "$HOOKS_DIR/$hook" ]]; then
      rm -f "$HOOKS_DIR/$hook"
      HOOKS_REMOVED=$((HOOKS_REMOVED + 1))
    fi
  done
  echo "  Removed $HOOKS_REMOVED AgentVibes hook files"
fi

echo ""
echo "=== Uninstall Complete ==="
echo ""
echo "All AgentVibes files have been removed."
echo "Non-AgentVibes Claude hooks have been preserved."
echo ""
