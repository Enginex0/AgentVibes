#!/bin/bash
#
# Piper TTS Queue Worker - Non-blocking file-based queue processor
#
# Watches ~/.claude/piper-queue/ for msg-*.json files
# Processes them sequentially and deletes after playback
#
# This eliminates the FIFO blocking issue that caused session startup delays
#
# Accepts JSON input: {"text": "Hello", "reverb": "heavy", "background": "dark_chill_step"}
# Also accepts plain text for backwards compatibility
#
# This script is managed by systemd (piper-tts.service)
#

# Note: Using -u only (not -e or pipefail) for daemon stability
set -u

# ============================================================================
# Configuration
# ============================================================================

QUEUE_DIR="$HOME/.claude/piper-queue"
DAEMON_DIR="$HOME/.claude/piper-daemon"
VOICE_FILE="$HOME/.claude/tts-voice.txt"
VOICES_DIR="$HOME/.claude/piper-voices"
AUDIO_DIR="$HOME/.claude/audio"
EFFECTS_CFG="$HOME/.claude/config/audio-effects.cfg"
BACKGROUNDS_DIR="$HOME/.claude/audio/tracks"
EVIL_LAUGH_AUDIO="$HOME/.claude/audio/evil-laugh.wav"

# Logging
AV_LOG_DIR="$HOME/.claude/logs/agentvibes"
AV_DAEMON_LOG="$AV_LOG_DIR/daemon.log"

# Ready sentinel file - signals that daemon is ready for requests
READY_FILE="$DAEMON_DIR/ready"

# ============================================================================
# Logging Functions
# ============================================================================

mkdir -p "$AV_LOG_DIR" 2>/dev/null || true

av_daemon_log() {
  local level="$1"
  local message="$2"
  local ts
  if date +%s%3N >/dev/null 2>&1; then
    ts=$(date +"%Y-%m-%dT%H:%M:%S.%3N")
  else
    ts=$(date +"%Y-%m-%dT%H:%M:%S.000")
  fi
  echo "[$ts] [$level] [queue-worker] $message" >> "$AV_DAEMON_LOG" 2>/dev/null || true
}

declare -A AV_DAEMON_TIMES
av_daemon_start() {
  local op="$1"
  if date +%s%3N >/dev/null 2>&1; then
    AV_DAEMON_TIMES[$op]=$(date +%s%3N)
  else
    AV_DAEMON_TIMES[$op]=$(($(date +%s) * 1000))
  fi
  av_daemon_log "INFO" "START: $op"
}

av_daemon_end() {
  local op="$1"
  local status="${2:-OK}"
  local end_ms
  if date +%s%3N >/dev/null 2>&1; then
    end_ms=$(date +%s%3N)
  else
    end_ms=$(($(date +%s) * 1000))
  fi
  local start_ms="${AV_DAEMON_TIMES[$op]:-}"
  if [[ -n "$start_ms" ]]; then
    local duration=$((end_ms - start_ms))
    av_daemon_log "INFO" "END: $op ($status) [${duration}ms]"
  else
    av_daemon_log "INFO" "END: $op ($status)"
  fi
  unset "AV_DAEMON_TIMES[$op]" 2>/dev/null || true
}

# ============================================================================
# Reverb Presets
# ============================================================================

declare -A REVERB_LEVELS=(
  ["off"]=""
  ["light"]="gain -3 reverb 20 50 50"
  ["medium"]="gain -5 reverb 40 50 70"
  ["heavy"]="gain -6 reverb 70 50 100"
  ["cathedral"]="gain -8 reverb 90 30 100"
)

# ============================================================================
# Evil Laugh Functions
# ============================================================================

has_evil_laugh() {
  local text="$1"
  echo "$text" | grep -qiE '(m[wu]a+(ha+)+|bwa+(ha+)+|(ha+){3,})'
}

strip_evil_laugh() {
  local text="$1"
  echo "$text" | sed -E 's/[[:space:]]*(m[wu]a+(ha+)+|bwa+(ha+)+|(ha+){3,})[!.]*[[:space:]]*//gi' | sed 's/[[:space:]]*$//'
}

play_evil_laugh() {
  if [[ -f "$EVIL_LAUGH_AUDIO" ]]; then
    timeout 10 paplay "$EVIL_LAUGH_AUDIO" 2>/dev/null || true
  fi
}

# ============================================================================
# Voice and Model Functions
# ============================================================================

get_voice() {
  local voice="en_US-lessac-medium"
  [[ -f "$VOICE_FILE" ]] && voice=$(<"$VOICE_FILE")
  echo "$voice"
}

get_model_path() {
  local voice=$(get_voice)
  local model_path="$VOICES_DIR/${voice}.onnx"
  local resolved=$(realpath -m "$model_path" 2>/dev/null || echo "$model_path")
  local voices_resolved=$(realpath -m "$VOICES_DIR" 2>/dev/null || echo "$VOICES_DIR")
  if [[ "$resolved" != "$voices_resolved"/* ]] && [[ "$resolved" != "$voices_resolved" ]]; then
    echo "ERROR: Invalid voice path (potential traversal)" >&2
    return 1
  fi
  echo "$model_path"
}

# ============================================================================
# Effects Functions
# ============================================================================

get_default_reverb() {
  if [[ -f "$EFFECTS_CFG" ]]; then
    local effects=$(grep "^default|" "$EFFECTS_CFG" 2>/dev/null | cut -d'|' -f2)
    if [[ "$effects" =~ reverb ]]; then
      if [[ "$effects" =~ "reverb 70" ]]; then echo "heavy"
      elif [[ "$effects" =~ "reverb 40" ]]; then echo "medium"
      elif [[ "$effects" =~ "reverb 20" ]]; then echo "light"
      elif [[ "$effects" =~ "reverb 90" ]]; then echo "cathedral"
      else echo "off"
      fi
    else
      echo "off"
    fi
  else
    echo "off"
  fi
}

get_default_background() {
  if [[ -f "$EFFECTS_CFG" ]]; then
    grep "^default|" "$EFFECTS_CFG" 2>/dev/null | cut -d'|' -f3
  fi
}

get_default_volume() {
  if [[ -f "$EFFECTS_CFG" ]]; then
    local vol=$(grep "^default|" "$EFFECTS_CFG" 2>/dev/null | cut -d'|' -f4)
    echo "${vol:-0.3}"
  else
    echo "0.3"
  fi
}

apply_reverb() {
  local input="$1"
  local output="$2"
  local level="$3"

  if [[ -z "$level" ]] || [[ "$level" == "off" ]] || [[ -z "${REVERB_LEVELS[$level]:-}" ]]; then
    cp "$input" "$output"
    return 0
  fi

  if ! command -v sox &>/dev/null; then
    cp "$input" "$output"
    return 0
  fi

  local effects="${REVERB_LEVELS[$level]}"
  sox "$input" "$output" $effects 2>/dev/null || cp "$input" "$output"
}

mix_background() {
  local voice="$1"
  local background="$2"
  local volume="$3"
  local output="$4"

  if [[ -z "$background" ]] || [[ ! -f "$background" ]]; then
    cp "$voice" "$output"
    return 0
  fi

  if ! command -v ffmpeg &>/dev/null; then
    cp "$voice" "$output"
    return 0
  fi

  local duration
  duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$voice" 2>/dev/null)
  [[ -z "$duration" ]] && { cp "$voice" "$output"; return 0; }

  ffmpeg -y -i "$voice" -stream_loop -1 -i "$background" \
    -filter_complex "[1:a]volume=${volume},afade=t=out:st=${duration}:d=0.5[bg];[0:a][bg]amix=inputs=2:duration=first[out]" \
    -map "[out]" -t "$duration" "$output" 2>/dev/null || cp "$voice" "$output"
}

# ============================================================================
# TTS Processing
# ============================================================================

process_tts() {
  local input="$1"
  local text=""
  local reverb=""
  local background=""
  local volume=""

  av_daemon_start "PROCESS_TTS"
  av_daemon_log "INFO" "Input length: ${#input} chars"

  # Try to parse as JSON
  av_daemon_start "JSON_PARSE"
  if echo "$input" | jq -e . &>/dev/null; then
    text=$(echo "$input" | jq -r '.text // empty')
    reverb=$(echo "$input" | jq -r '.reverb // empty')
    background=$(echo "$input" | jq -r '.background // empty')
    volume=$(echo "$input" | jq -r '.volume // empty')
    av_daemon_log "INFO" "Parsed as JSON, text length: ${#text}"
  else
    text="$input"
    av_daemon_log "INFO" "Plain text mode, length: ${#text}"
  fi
  av_daemon_end "JSON_PARSE"

  if [[ -z "$text" ]]; then
    av_daemon_log "WARN" "Empty text, skipping"
    av_daemon_end "PROCESS_TTS" "SKIP"
    return
  fi

  # Check for evil laugh
  local play_laugh=false
  if has_evil_laugh "$text"; then
    play_laugh=true
    text=$(strip_evil_laugh "$text")
  fi

  if [[ -z "$text" ]] || [[ "$text" =~ ^[[:space:]]*$ ]]; then
    play_evil_laugh
    return 0
  fi

  # Use defaults if not specified
  [[ -z "$reverb" ]] && reverb=$(get_default_reverb)
  [[ -z "$background" ]] && background=$(get_default_background)
  [[ -z "$volume" ]] && volume=$(get_default_volume)

  # Resolve background path
  if [[ -n "$background" ]] && [[ ! -f "$background" ]]; then
    local found=$(find "$BACKGROUNDS_DIR" -name "*${background}*" -type f 2>/dev/null | head -1)
    [[ -n "$found" ]] && background="$found"
  fi

  # Create temp files with mktemp
  mkdir -p "$AUDIO_DIR"
  local raw_wav=$(mktemp "$AUDIO_DIR/daemon-raw-XXXXXX.wav")
  local reverb_wav=$(mktemp "$AUDIO_DIR/daemon-reverb-XXXXXX.wav")
  local final_wav=$(mktemp "$AUDIO_DIR/daemon-final-XXXXXX.wav")

  # Synthesize with piper
  av_daemon_start "PIPER_SYNTH"
  av_daemon_log "INFO" "Synthesizing with model: $MODEL"
  echo "$text" | piper --model "$MODEL" --output_file "$raw_wav" 2>/dev/null
  av_daemon_end "PIPER_SYNTH"

  if [[ ! -f "$raw_wav" ]]; then
    av_daemon_log "ERROR" "Piper synthesis failed"
    av_daemon_end "PROCESS_TTS" "ERROR"
    return 1
  fi
  av_daemon_log "INFO" "Synthesis complete, file size: $(stat -c%s "$raw_wav" 2>/dev/null || echo unknown) bytes"

  # Apply reverb
  av_daemon_start "APPLY_REVERB"
  if [[ "$reverb" != "off" ]] && [[ -n "${REVERB_LEVELS[$reverb]:-}" ]]; then
    av_daemon_log "INFO" "Applying reverb: $reverb"
    apply_reverb "$raw_wav" "$reverb_wav" "$reverb"
  else
    av_daemon_log "INFO" "No reverb"
    cp "$raw_wav" "$reverb_wav"
  fi
  av_daemon_end "APPLY_REVERB"

  # Mix background
  av_daemon_start "MIX_BACKGROUND"
  if [[ -f "$HOME/.claude/config/background-music-enabled.txt" ]] && \
     [[ "$(<"$HOME/.claude/config/background-music-enabled.txt" 2>/dev/null)" == "true" ]] && \
     [[ -n "$background" ]] && [[ -f "$background" ]]; then
    av_daemon_log "INFO" "Mixing background: $background"
    mix_background "$reverb_wav" "$background" "$volume" "$final_wav"
  else
    av_daemon_log "INFO" "No background mixing"
    cp "$reverb_wav" "$final_wav"
  fi
  av_daemon_end "MIX_BACKGROUND"

  # Check audio stack
  av_daemon_start "AUDIO_STACK_CHECK"
  if ! systemctl --user is-active --quiet pipewire-pulse 2>/dev/null; then
    av_daemon_log "WARN" "PipeWire not active, restarting..."
    systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null
    sleep 1
  else
    av_daemon_log "INFO" "PipeWire healthy"
  fi
  av_daemon_end "AUDIO_STACK_CHECK"

  # Limit concurrent paplay
  local paplay_count
  paplay_count=$(pgrep -c paplay 2>/dev/null) || paplay_count=0
  av_daemon_log "INFO" "Current paplay processes: $paplay_count"
  if [[ "$paplay_count" -gt 3 ]]; then
    av_daemon_log "WARN" "Too many paplay processes, killing oldest"
    pkill -o paplay 2>/dev/null || true
  fi

  # Play audio
  av_daemon_start "AUDIO_PLAYBACK"
  av_daemon_log "INFO" "Playing audio: $final_wav"
  timeout 300 paplay "$final_wav" 2>/dev/null || true
  av_daemon_end "AUDIO_PLAYBACK"

  # Play evil laugh if detected
  if [[ "$play_laugh" == "true" ]]; then
    av_daemon_log "INFO" "Playing evil laugh"
    sleep 0.2
    play_evil_laugh
  fi

  sleep 0.5
  rm -f "$raw_wav" "$reverb_wav" "$final_wav" 2>/dev/null
  av_daemon_end "PROCESS_TTS"
}

# ============================================================================
# Queue Processing
# ============================================================================

process_queue_file() {
  local filepath="$1"
  [[ -f "$filepath" ]] || return

  av_daemon_start "QUEUE_FILE"
  av_daemon_log "INFO" "Processing queue file: $filepath"

  # Debug: Check file size and existence
  local filesize
  filesize=$(stat -c%s "$filepath" 2>/dev/null || echo "0")
  av_daemon_log "INFO" "File size: $filesize bytes"

  local content
  content=$(cat "$filepath" 2>/dev/null)
  av_daemon_log "INFO" "Content length after read: ${#content}"

  if [[ -z "$content" ]]; then
    av_daemon_log "WARN" "Queue file empty (size was: $filesize), skipping"
    rm -f "$filepath" 2>/dev/null
    av_daemon_end "QUEUE_FILE" "EMPTY"
    return
  fi

  av_daemon_log "INFO" "Read content, length: ${#content}"

  # Process the TTS request
  process_tts "$content"

  # Delete processed file
  rm -f "$filepath" 2>/dev/null
  av_daemon_end "QUEUE_FILE"
}

# ============================================================================
# Cleanup
# ============================================================================

cleanup() {
  av_daemon_log "INFO" "Queue worker shutting down..."
  rm -f "$READY_FILE" 2>/dev/null
  jobs -p | xargs -r kill 2>/dev/null || true
  exit 0
}

trap cleanup SIGTERM SIGINT SIGHUP

# ============================================================================
# Main
# ============================================================================

# Create directories
mkdir -p "$QUEUE_DIR" "$DAEMON_DIR" "$AUDIO_DIR"

# Get model path
MODEL=$(get_model_path)
VOICE=$(get_voice)

if [[ ! -f "$MODEL" ]]; then
  echo "ERROR: Voice model not found: $MODEL" >&2
  exit 1
fi

av_daemon_log "INFO" "=========================================="
av_daemon_log "INFO" "Piper TTS Queue Worker starting"
av_daemon_log "INFO" "Voice: $VOICE"
av_daemon_log "INFO" "Model: $MODEL"
av_daemon_log "INFO" "Queue: $QUEUE_DIR"
av_daemon_log "INFO" "Default reverb: $(get_default_reverb)"

echo "Piper TTS Queue Worker starting"
echo "Voice: $VOICE"
echo "Model: $MODEL"
echo "Queue directory: $QUEUE_DIR"

# Pre-warm the model
av_daemon_start "MODEL_WARMUP"
echo "Pre-warming model..."
echo "." | piper --model "$MODEL" --output-raw >/dev/null 2>&1 || true
av_daemon_end "MODEL_WARMUP"
av_daemon_log "INFO" "Model warm, ready for requests"
echo "Model warm, ready for requests"

# Signal readiness AFTER model is warm
touch "$READY_FILE"
av_daemon_log "INFO" "Ready file created: $READY_FILE"

# Process any existing queued files first (from before daemon started)
av_daemon_log "INFO" "Checking for existing queue files..."
for f in "$QUEUE_DIR"/msg-*.json; do
  [[ -f "$f" ]] || continue
  av_daemon_log "INFO" "Found existing queue file: $f"
  process_queue_file "$f"
done

# Check for inotifywait
if ! command -v inotifywait &>/dev/null; then
  av_daemon_log "ERROR" "inotifywait not found. Install inotify-tools package."
  echo "ERROR: inotifywait not found. Install: sudo apt install inotify-tools" >&2
  exit 1
fi

# Watch for new files using inotifywait
av_daemon_log "INFO" "Watching queue directory: $QUEUE_DIR"
echo "Watching queue directory for new files..."

inotifywait -m -e moved_to --format '%f' "$QUEUE_DIR" 2>/dev/null |
while read -r filename; do
  # Only process msg-*.json files (atomic rename guarantees complete file)
  [[ "$filename" == msg-*.json ]] || continue

  filepath="$QUEUE_DIR/$filename"

  # Small delay to ensure filesystem sync
  sleep 0.01

  [[ -f "$filepath" ]] || continue

  av_daemon_log "INFO" "New queue file detected: $filename"
  process_queue_file "$filepath"
done
