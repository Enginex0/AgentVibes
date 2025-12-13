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

echo "=== AgentVibes User-Level Setup ==="
echo "Package: $PACKAGE_DIR"
echo "Target: $USER_CLAUDE"
echo ""

# Create directory structure
echo "[1/7] Creating directory structure..."
mkdir -p "$USER_CLAUDE"/{hooks,personalities,config,audio,scripts,piper-daemon}

# Copy hooks (already patched with user-level support)
echo "[2/7] Installing hooks..."
if [[ -d "$PACKAGE_DIR/.claude/hooks" ]]; then
  cp -r "$PACKAGE_DIR/.claude/hooks/"* "$USER_CLAUDE/hooks/" 2>/dev/null || true
  chmod +x "$USER_CLAUDE/hooks/"*.sh 2>/dev/null || true
  echo "  Copied $(ls "$USER_CLAUDE/hooks/"*.sh 2>/dev/null | wc -l) hook scripts"
fi

# Copy personalities (with voice assignments)
echo "[3/7] Installing personalities..."
if [[ -d "$PACKAGE_DIR/.claude/personalities" ]]; then
  cp -r "$PACKAGE_DIR/.claude/personalities/"* "$USER_CLAUDE/personalities/" 2>/dev/null || true
  echo "  Copied $(ls "$USER_CLAUDE/personalities/" 2>/dev/null | wc -l) personality files"
fi

# Copy enhanced scripts
echo "[4/7] Installing daemon scripts..."
if [[ -f "$PACKAGE_DIR/scripts/piper-worker-enhanced.sh" ]]; then
  cp "$PACKAGE_DIR/scripts/piper-worker-enhanced.sh" "$USER_CLAUDE/scripts/"
  cp "$PACKAGE_DIR/scripts/piper-daemon.sh" "$USER_CLAUDE/scripts/"
  chmod +x "$USER_CLAUDE/scripts/"*.sh 2>/dev/null || true
  echo "  Installed piper daemon scripts"
fi

# Copy audio assets
echo "[5/7] Installing audio assets..."
if [[ -d "$PACKAGE_DIR/audio" ]]; then
  cp -r "$PACKAGE_DIR/audio/"* "$USER_CLAUDE/audio/" 2>/dev/null || true
  echo "  Copied audio files"
fi

# Create default configs (only if not exist - preserve user settings)
echo "[6/7] Setting up default configuration..."
[[ ! -f "$USER_CLAUDE/tts-provider.txt" ]] && echo "piper" > "$USER_CLAUDE/tts-provider.txt" && echo "  Set provider: piper"
[[ ! -f "$USER_CLAUDE/tts-voice.txt" ]] && echo "en_US-lessac-medium" > "$USER_CLAUDE/tts-voice.txt" && echo "  Set voice: en_US-lessac-medium"
[[ ! -f "$USER_CLAUDE/tts-verbosity.txt" ]] && echo "medium" > "$USER_CLAUDE/tts-verbosity.txt" && echo "  Set verbosity: medium"
[[ ! -f "$USER_CLAUDE/config/tts-save-audio.txt" ]] && echo "false" > "$USER_CLAUDE/config/tts-save-audio.txt" && echo "  Set save-audio: false"

# Enable user-level mode (marker file)
touch "$USER_CLAUDE/agentvibes-user-level"
echo "  User-level mode enabled"

# Install systemd service (Linux only)
echo "[7/7] Installing systemd service..."
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
