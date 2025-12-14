#!/usr/bin/env bash
#
# File: .claude/hooks/play-tts-piper.sh
#
# AgentVibes - Finally, your AI Agents can Talk Back! Text-to-Speech WITH personality for AI Assistants!
# Website: https://agentvibes.org
# Repository: https://github.com/paulpreibisch/AgentVibes
#
# Co-created by Paul Preibisch with Claude AI
# Copyright (c) 2025 Paul Preibisch
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# DISCLAIMER: This software is provided "AS IS", WITHOUT WARRANTY OF ANY KIND,
# express or implied. Use at your own risk. See the Apache License for details.
#
# ---
#
# @fileoverview Piper TTS Provider Implementation - Free, offline neural TTS
# @context Provides local, privacy-first TTS alternative to cloud services for WSL/Linux
# @architecture Implements provider interface contract for Piper binary integration
# @dependencies piper (pipx), piper-voice-manager.sh, mpv/aplay, ffmpeg (optional padding)
# @entrypoints Called by play-tts.sh router when provider=piper
# @patterns Provider contract: text/voice → audio file path, voice auto-download, language-aware synthesis
# @related play-tts.sh, piper-voice-manager.sh, language-manager.sh, GitHub Issue #25
#

set -euo pipefail

# Validate HOME is set (required for config paths)
if [[ -z "${HOME:-}" ]]; then
  echo "ERROR: HOME environment variable not set" >&2
  exit 1
fi

# Fix locale warnings
export LC_ALL=C

TEXT="$1"
VOICE_OVERRIDE="${2:-}"  # Optional: voice model name

# Source voice manager and language manager
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source logging utilities (disable with AGENTVIBES_LOGGING=false for ~10ms speedup)
if [[ "${AGENTVIBES_LOGGING:-true}" != "false" ]] && [[ -f "$SCRIPT_DIR/logging-utils.sh" ]]; then
  source "$SCRIPT_DIR/logging-utils.sh"
  av_log_init "play-tts-piper"
  av_log_start "PIPER_TTS"
  av_log_info "CWD: $(pwd)"
  av_log_info "SCRIPT_DIR: $SCRIPT_DIR"
  av_log_info "TEXT length: ${#TEXT} chars"
  av_log_info "VOICE_OVERRIDE: ${VOICE_OVERRIDE:-<none>}"
else
  # Minimal stubs when logging disabled (~0.2ms per call vs ~1ms with full logging)
  av_log_info() { :; }
  av_log_warn() { :; }
  av_log_error() { :; }
  av_log_start() { :; }
  av_log_end() { :; }
fi

av_log_start "SOURCE_MANAGERS"
source "$SCRIPT_DIR/piper-voice-manager.sh"
source "$SCRIPT_DIR/language-manager.sh"
av_log_end "SOURCE_MANAGERS"

# Default voice for Piper
DEFAULT_VOICE="en_US-lessac-medium"

# @function determine_voice_model
# @intent Resolve voice name to Piper model name with language support
# @why Support voice override, language-specific voices, and default fallback
# @param Uses global: $VOICE_OVERRIDE
# @returns Sets $VOICE_MODEL global variable
# @sideeffects None
VOICE_MODEL=""

# Get current language setting
av_log_start "VOICE_RESOLUTION"
CURRENT_LANGUAGE=$(get_language_code)
av_log_info "CURRENT_LANGUAGE: $CURRENT_LANGUAGE"

if [[ -n "$VOICE_OVERRIDE" ]]; then
  # Use override if provided
  VOICE_MODEL="$VOICE_OVERRIDE"
  echo "🎤 Using voice: $VOICE_OVERRIDE (session-specific)"
else
  # Try to get voice from voice file
  VOICE_FILE=""

  # Priority order:
  # 1. User-level mode marker (single source of truth for all projects)
  # 2. CLAUDE_PROJECT_DIR env var (set by MCP for project-specific settings)
  # 3. Script location (for direct slash command usage)
  # 4. Global ~/.claude (fallback)

  if [[ -f "$HOME/.claude/agentvibes-user-level" ]]; then
    # User-level mode: Always use ~/.claude for settings (single source of truth)
    VOICE_FILE="$HOME/.claude/tts-voice.txt"
  elif [[ -n "${CLAUDE_PROJECT_DIR:-}" ]] && [[ -f "${CLAUDE_PROJECT_DIR:-}/.claude/tts-voice.txt" ]]; then
    # MCP context: Use the project directory where MCP was invoked
    VOICE_FILE="${CLAUDE_PROJECT_DIR:-}/.claude/tts-voice.txt"
  elif [[ -f "$SCRIPT_DIR/../tts-voice.txt" ]]; then
    # Direct usage: Use script location
    VOICE_FILE="$SCRIPT_DIR/../tts-voice.txt"
  elif [[ -f "$HOME/.claude/tts-voice.txt" ]]; then
    # Fallback: Use global
    VOICE_FILE="$HOME/.claude/tts-voice.txt"
  fi

  if [[ -n "$VOICE_FILE" ]] && [[ -f "$VOICE_FILE" ]]; then
    FILE_VOICE=$(<"$VOICE_FILE")

    # Check for multi-speaker voice (model + speaker ID stored separately)
    # Use same directory as VOICE_FILE for consistency
    VOICE_DIR=$(dirname "$VOICE_FILE")
    MODEL_FILE="$VOICE_DIR/tts-piper-model.txt"
    SPEAKER_ID_FILE="$VOICE_DIR/tts-piper-speaker-id.txt"

    if [[ -f "$MODEL_FILE" ]] && [[ -f "$SPEAKER_ID_FILE" ]]; then
      # Multi-speaker voice (files verified to exist above)
      VOICE_MODEL=$(<"$MODEL_FILE")
      SPEAKER_ID=$(<"$SPEAKER_ID_FILE")
      echo "🎭 Using multi-speaker voice: $FILE_VOICE (Model: $VOICE_MODEL, Speaker ID: $SPEAKER_ID)"
    # Check if it's a standard Piper model name or custom voice (just use as-is)
    elif [[ -n "$FILE_VOICE" ]]; then
      VOICE_MODEL="$FILE_VOICE"
    fi
  fi

  # If no Piper voice from file, try language-specific voice
  if [[ -z "$VOICE_MODEL" ]]; then
    av_log_info "No voice from file, trying language-specific"
    LANG_VOICE=$(get_voice_for_language "$CURRENT_LANGUAGE" "piper" 2>/dev/null)

    if [[ -n "$LANG_VOICE" ]]; then
      VOICE_MODEL="$LANG_VOICE"
      av_log_info "Using language voice: $LANG_VOICE"
      echo "🌍 Using $CURRENT_LANGUAGE voice: $LANG_VOICE (Piper)"
    else
      # Use default voice
      VOICE_MODEL="$DEFAULT_VOICE"
      av_log_info "Using default voice: $DEFAULT_VOICE"
    fi
  fi
fi
av_log_info "Final VOICE_MODEL: $VOICE_MODEL"
av_log_end "VOICE_RESOLUTION"

# @function validate_inputs
# @intent Check required parameters
# @why Fail fast with clear errors if inputs missing
# @exitcode 1=missing text, 2=missing piper binary
if [[ -z "$TEXT" ]]; then
  echo "Usage: $0 \"text to speak\" [voice_model_name]"
  exit 1
fi

# Check if Piper is installed
if ! command -v piper &> /dev/null; then
  echo "❌ Error: Piper TTS not installed"
  echo "Install with: pipx install piper-tts"
  echo "Or run: .claude/hooks/piper-installer.sh"
  exit 2
fi

# @function ensure_voice_downloaded
# @intent Download voice model if not cached
# @why Provide seamless experience with automatic downloads
# @param Uses global: $VOICE_MODEL
# @sideeffects Downloads voice model files
# @edgecases Prompts user for consent before downloading
if ! verify_voice "$VOICE_MODEL"; then
  echo "📥 Voice model not found: $VOICE_MODEL"
  echo "   File size: ~25MB"
  echo "   Preview: https://huggingface.co/rhasspy/piper-voices"
  echo ""

  # Handle non-interactive mode (CI/automation) - auto-download
  if [[ -t 0 ]]; then
    # Interactive: prompt with timeout
    read -t 30 -p "   Download this voice model? [y/N]: " -n 1 -r || REPLY=""
    echo
  else
    # Non-interactive: auto-download
    echo "   Non-interactive mode: Auto-downloading voice model..."
    REPLY="y"
  fi

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! download_voice "$VOICE_MODEL"; then
      echo "❌ Failed to download voice model"
      echo "Fix: Download manually or choose different voice"
      exit 3
    fi
  else
    echo "❌ Voice download cancelled (or timeout)"
    exit 3
  fi
fi

# Get voice model path
VOICE_PATH=$(get_voice_path "$VOICE_MODEL")
if [[ $? -ne 0 ]]; then
  echo "❌ Voice model path not found: $VOICE_MODEL"
  exit 3
fi

# @function determine_audio_directory
# @intent Find appropriate directory for audio file storage
# @why Supports user-level, project-local, and global storage
# @returns Sets $AUDIO_DIR global variable
if [[ -f "$HOME/.claude/agentvibes-user-level" ]]; then
  # User-level mode: Always use ~/.claude for audio (single source of truth)
  AUDIO_DIR="$HOME/.claude/audio"
elif [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
  AUDIO_DIR="${CLAUDE_PROJECT_DIR:-}/.claude/audio"
else
  # Fallback: try to find .claude directory in current path
  CURRENT_DIR="$PWD"
  while [[ "$CURRENT_DIR" != "/" ]]; do
    if [[ -d "$CURRENT_DIR/.claude" ]]; then
      AUDIO_DIR="$CURRENT_DIR/.claude/audio"
      break
    fi
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
  done
  # Final fallback to global if no project .claude found
  if [[ -z "$AUDIO_DIR" ]]; then
    AUDIO_DIR="$HOME/.claude/audio"
  fi
fi

mkdir -p "$AUDIO_DIR"
# Security: Use mktemp for unpredictable filename (prevents symlink attacks)
TEMP_FILE=$(mktemp "$AUDIO_DIR/tts-XXXXXX.wav")

# @function get_speech_rate
# @intent Determine speech rate for Piper synthesis
# @why Convert user-facing speed (0.5=slower, 2.0=faster) to Piper length-scale (inverted)
# @returns Piper length-scale value (inverted from user scale)
# @note Piper uses length-scale where higher=slower, opposite of user expectation
get_speech_rate() {
  local target_config=""
  local main_config=""

  # Check for target-specific config first (new and legacy paths)
  if [[ -f "$SCRIPT_DIR/../config/tts-target-speech-rate.txt" ]]; then
    target_config="$SCRIPT_DIR/../config/tts-target-speech-rate.txt"
  elif [[ -f "$HOME/.claude/config/tts-target-speech-rate.txt" ]]; then
    target_config="$HOME/.claude/config/tts-target-speech-rate.txt"
  elif [[ -f "$SCRIPT_DIR/../config/piper-target-speech-rate.txt" ]]; then
    target_config="$SCRIPT_DIR/../config/piper-target-speech-rate.txt"
  elif [[ -f "$HOME/.claude/config/piper-target-speech-rate.txt" ]]; then
    target_config="$HOME/.claude/config/piper-target-speech-rate.txt"
  fi

  # Check for main config (new and legacy paths)
  if [[ -f "$SCRIPT_DIR/../config/tts-speech-rate.txt" ]]; then
    main_config="$SCRIPT_DIR/../config/tts-speech-rate.txt"
  elif [[ -f "$HOME/.claude/config/tts-speech-rate.txt" ]]; then
    main_config="$HOME/.claude/config/tts-speech-rate.txt"
  elif [[ -f "$SCRIPT_DIR/../config/piper-speech-rate.txt" ]]; then
    main_config="$SCRIPT_DIR/../config/piper-speech-rate.txt"
  elif [[ -f "$HOME/.claude/config/piper-speech-rate.txt" ]]; then
    main_config="$HOME/.claude/config/piper-speech-rate.txt"
  fi

  # If this is a non-English voice and target config exists, use it
  if [[ "$CURRENT_LANGUAGE" != "english" ]] && [[ -n "$target_config" ]]; then
    local user_speed=$(<"$target_config")
    # Convert user speed to Piper length-scale (invert)
    # User: 0.5=slower, 1.0=normal, 2.0=faster
    # Piper: 2.0=slower, 1.0=normal, 0.5=faster
    # Formula: piper_length_scale = 1.0 / user_speed
    echo "scale=2; 1.0 / $user_speed" | bc -l 2>/dev/null || echo "1.0"
    return
  fi

  # Otherwise use main config if available
  if [[ -n "$main_config" ]]; then
    local user_speed=$(grep -v '^#' "$main_config" 2>/dev/null | grep -v '^$' | tail -1)
    echo "scale=2; 1.0 / $user_speed" | bc -l 2>/dev/null || echo "1.0"
    return
  fi

  # Default: 1.0 (normal) for English, 2.0 (slower) for learning
  if [[ "$CURRENT_LANGUAGE" != "english" ]]; then
    echo "2.0"
  else
    echo "1.0"
  fi
}

SPEECH_RATE=$(get_speech_rate)

# @function ensure_audio_stack_healthy
# @intent Ensure PipeWire audio stack is running before TTS
# @why PipeWire-pulse can die randomly, causing audio to hang
ensure_audio_stack() {
  if ! systemctl --user is-active --quiet pipewire-pulse 2>/dev/null; then
    systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null
    sleep 1
  fi
}

# Ensure audio stack is healthy before any TTS
ensure_audio_stack

# @function check_and_use_queue
# @intent Use file-based queue for non-blocking TTS (replaces FIFO)
# @why File writes NEVER block - eliminates session startup delays
# @architecture Script writes JSON to queue dir, daemon picks up via inotifywait
av_log_start "DAEMON_CHECK"
QUEUE_DIR="$HOME/.claude/piper-queue"
READY_FILE="$HOME/.claude/piper-daemon/ready"

# Check if queue worker is ready (ready file exists after model warmup)
daemon_ready=false
if [[ -f "$READY_FILE" ]]; then
  # Daemon is warm and ready
  daemon_ready=true
  av_log_info "Ready file exists - daemon ready (fast path)"
elif systemctl --user is-active --quiet piper-tts 2>/dev/null; then
  # Systemd says running but ready file missing - daemon still warming up
  # Still queue the request - it will be processed once daemon is ready
  daemon_ready=true
  av_log_info "Systemd active, ready file missing - queuing anyway"
else
  av_log_warn "Daemon not running"
fi

if [[ "$daemon_ready" == "true" ]]; then
  av_log_info "Using file queue for non-blocking TTS"

  # Create queue directory if needed
  mkdir -p "$QUEUE_DIR"

  # Security: Prevent queue overflow (max 100 files)
  queue_count=$(find "$QUEUE_DIR" -maxdepth 1 -name "msg-*.json" 2>/dev/null | wc -l)
  if [[ "$queue_count" -gt 100 ]]; then
    av_log_warn "Queue overflow ($queue_count files), falling back to direct synthesis"
    daemon_ready=false
  fi
fi

if [[ "$daemon_ready" == "true" ]]; then
  # Generate unique filename with nanosecond timestamp + PID for ordering
  TIMESTAMP=$(date +%s%N)
  MSG_FILE="$QUEUE_DIR/msg-${TIMESTAMP}-$$.json"
  TEMP_MSG="$QUEUE_DIR/.msg-${TIMESTAMP}-$$.tmp"

  # Write JSON with proper escaping (jq handles newlines, tabs, control chars)
  av_log_start "QUEUE_WRITE"
  if command -v jq &>/dev/null; then
    # Use jq for complete JSON escaping (handles all special characters)
    printf '%s' "$TEXT" | jq -Rsc '{"text": .}' > "$TEMP_MSG"
  else
    # Fallback: manual escaping (handles common cases)
    ESCAPED_TEXT="${TEXT//\\/\\\\}"
    ESCAPED_TEXT="${ESCAPED_TEXT//$'\n'/\\n}"
    ESCAPED_TEXT="${ESCAPED_TEXT//$'\r'/\\r}"
    ESCAPED_TEXT="${ESCAPED_TEXT//$'\t'/\\t}"
    ESCAPED_TEXT="${ESCAPED_TEXT//\"/\\\"}"
    printf '{"text":"%s"}' "$ESCAPED_TEXT" > "$TEMP_MSG"
  fi

  # Atomic rename (prevents partial reads by inotifywait)
  mv "$TEMP_MSG" "$MSG_FILE"
  av_log_info "Queued message: $MSG_FILE"
  av_log_end "QUEUE_WRITE"

  # Return immediately - NO BLOCKING
  av_log_end "DAEMON_CHECK"
  av_log_end "PIPER_TTS"
  echo "⚡ Daemon TTS (instant)"
  echo "🎤 Voice: $VOICE_MODEL (Piper queue)"
  exit 0
else
  av_log_warn "Daemon not available - will use direct synthesis"
fi
av_log_end "DAEMON_CHECK"

# Daemon not running - fall back to regular synthesis
# @function synthesize_with_piper
# @intent Generate speech using Piper TTS
# @why Provides free, offline TTS alternative
# @param Uses globals: $TEXT, $VOICE_PATH, $SPEECH_RATE, $SPEAKER_ID (optional)
# @returns Creates WAV file at $TEMP_FILE
# @exitcode 0=success, 4=synthesis error
# @sideeffects Creates audio file
# @edgecases Handles piper errors, invalid models, multi-speaker voices
av_log_start "DIRECT_SYNTHESIS"
av_log_info "Falling back to direct piper synthesis (no daemon)"
av_log_info "VOICE_PATH: $VOICE_PATH"
av_log_info "SPEECH_RATE: $SPEECH_RATE"
av_log_info "TEMP_FILE: $TEMP_FILE"

if [[ -n "${SPEAKER_ID:-}" ]]; then
  # Multi-speaker voice: Pass speaker ID
  av_log_info "Multi-speaker mode, SPEAKER_ID: ${SPEAKER_ID}"
  echo "$TEXT" | piper --model "$VOICE_PATH" --speaker "${SPEAKER_ID}" --length-scale "$SPEECH_RATE" --output_file "$TEMP_FILE" 2>/dev/null
else
  # Single-speaker voice
  av_log_info "Single-speaker mode"
  echo "$TEXT" | piper --model "$VOICE_PATH" --length-scale "$SPEECH_RATE" --output_file "$TEMP_FILE" 2>/dev/null
fi
av_log_end "DIRECT_SYNTHESIS"

if [[ ! -f "$TEMP_FILE" ]] || [[ ! -s "$TEMP_FILE" ]]; then
  av_log_error "Synthesis failed - no output file created"
  av_log_end "PIPER_TTS" "ERROR"
  echo "❌ Failed to synthesize speech with Piper"
  echo "Voice model: $VOICE_MODEL"
  echo "Check that voice model is valid"
  exit 4
fi
av_log_info "Synthesis successful, file size: $(stat -c%s "$TEMP_FILE" 2>/dev/null || stat -f%z "$TEMP_FILE" 2>/dev/null) bytes"

# @function add_silence_padding
# @intent Add silence to prevent WSL audio static
# @why WSL audio subsystem cuts off first ~200ms
# @param Uses global: $TEMP_FILE
# @returns Updates $TEMP_FILE to padded version
# @sideeffects Modifies audio file
# AI NOTE: Use ffmpeg if available, otherwise skip padding (degraded experience)
# Skip padding if disabled via config (for native Linux where it's not needed)
SKIP_PADDING_FILE="$HOME/.claude/tts-skip-padding.txt"
if [[ -f "$SKIP_PADDING_FILE" ]] && [[ "$(<"$SKIP_PADDING_FILE")" == "true" ]]; then
  # Padding disabled - native Linux doesn't need it
  :
elif command -v ffmpeg &> /dev/null; then
  # Security: Use mktemp for unpredictable filename
  PADDED_FILE=$(mktemp "$AUDIO_DIR/tts-padded-XXXXXX.wav")
  # Add 200ms of silence at the beginning
  ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo:d=0.2 -i "$TEMP_FILE" \
    -filter_complex "[0:a][1:a]concat=n=2:v=0:a=1[out]" \
    -map "[out]" -y "$PADDED_FILE" 2>/dev/null

  if [[ -f "$PADDED_FILE" ]]; then
    rm -f "$TEMP_FILE"
    TEMP_FILE="$PADDED_FILE"
  fi
fi

# @function play_audio
# @intent Play generated audio using available player with sequential playback
# @why Support multiple audio players and prevent overlapping audio in learning mode
# @param Uses global: $TEMP_FILE, $CURRENT_LANGUAGE
# @sideeffects Plays audio with lock mechanism for sequential playback

# Security: Use user-specific lock directory (prevent DoS via shared /tmp)
LOCK_DIR="${XDG_RUNTIME_DIR:-$HOME/.cache}/agentvibes"
mkdir -p "$LOCK_DIR" 2>/dev/null && chmod 700 "$LOCK_DIR" 2>/dev/null
LOCK_FILE="$LOCK_DIR/audio.lock"

# Wait for previous audio to finish using flock (max 30 seconds)
exec 9>"$LOCK_FILE"
if ! flock -w 30 9 2>/dev/null; then
  echo "Warning: Could not acquire audio lock, playing anyway" >&2
fi

# Track last target language audio for replay command
if [[ "$CURRENT_LANGUAGE" != "english" ]]; then
  TARGET_AUDIO_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/last-target-audio.txt"
  echo "$TEMP_FILE" > "$TARGET_AUDIO_FILE"
fi

# Play audio (lock already acquired via flock)

# Get audio duration for proper lock timing
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$TEMP_FILE" 2>/dev/null)
DURATION=${DURATION%.*}  # Round to integer
DURATION=${DURATION:-1}   # Default to 1 second if detection fails

# Play audio in background (skip if in test mode)
av_log_start "AUDIO_PLAYBACK"
if [[ "${AGENTVIBES_TEST_MODE:-false}" != "true" ]]; then
  # Detect platform and use appropriate audio player
  if [[ "$(uname -s)" == "Darwin" ]]; then
    # macOS: Use afplay (native macOS audio player)
    av_log_info "Using afplay (macOS)"
    afplay "$TEMP_FILE" >/dev/null 2>&1 &
    PLAYER_PID=$!
  else
    # Linux/WSL: Try mpv, aplay, or paplay
    av_log_info "Using mpv/aplay/paplay (Linux)"
    (mpv "$TEMP_FILE" || aplay "$TEMP_FILE" || paplay "$TEMP_FILE") >/dev/null 2>&1 &
    PLAYER_PID=$!
  fi
  av_log_info "Player started, PID: ${PLAYER_PID:-unknown}"
else
  av_log_info "Test mode - skipping playback"
fi

# Check if audio saving is enabled (default: false = delete after playback)
SAVE_AUDIO_FILE="$HOME/.claude/config/tts-save-audio.txt"
SAVE_AUDIO="false"
if [[ -f "$SAVE_AUDIO_FILE" ]] && [[ "$(<"$SAVE_AUDIO_FILE")" == "true" ]]; then
  SAVE_AUDIO="true"
fi
av_log_info "SAVE_AUDIO: $SAVE_AUDIO"
av_log_info "Audio duration: ${DURATION}s"

# Wait for audio to finish, then release lock (flock released on fd close) and optionally cleanup
if [[ "$SAVE_AUDIO" == "true" ]]; then
  (sleep $DURATION; exec 9>&-) &
  echo "🎵 Saved to: $TEMP_FILE"
else
  (sleep $DURATION; exec 9>&-; rm -f "$TEMP_FILE") &
  echo "🎵 Audio played (not saved)"
fi
disown
av_log_end "AUDIO_PLAYBACK"

av_log_info "Direct synthesis complete"
av_log_end "PIPER_TTS"
echo "🎤 Voice used: $VOICE_MODEL (Piper TTS)"
