#!/bin/bash
#
# Piper TTS Enhanced Worker - Effects-enabled TTS daemon
#
# Accepts JSON input: {"text": "Hello", "reverb": "heavy", "background": "dark_chill_step"}
# Also accepts plain text for backwards compatibility
#
# This script is managed by systemd (piper-tts.service)
#

# Note: Using -u only (not -e or pipefail) for daemon stability
# -e would exit on any command failure, -o pipefail on pipeline failures
# We want the daemon to continue running even if individual TTS requests fail
set -u

DAEMON_DIR="$HOME/.claude/piper-daemon"
FIFO_IN="$DAEMON_DIR/input.fifo"
VOICE_FILE="$HOME/.claude/tts-voice.txt"
VOICES_DIR="$HOME/.claude/piper-voices"
AUDIO_DIR="$HOME/.claude/audio"
EFFECTS_CFG="$HOME/.claude/config/audio-effects.cfg"
BACKGROUNDS_DIR="$HOME/.claude/audio/tracks"
EVIL_LAUGH_AUDIO="$HOME/.claude/audio/evil-laugh.wav"

# Reverb presets (sox parameters) - includes gain reduction to prevent clipping
declare -A REVERB_LEVELS=(
  ["off"]=""
  ["light"]="gain -3 reverb 20 50 50"
  ["medium"]="gain -5 reverb 40 50 70"
  ["heavy"]="gain -6 reverb 70 50 100"
  ["cathedral"]="gain -8 reverb 90 30 100"
)

# Evil laugh detection - matches patterns like mwahahaha, bwahahaha, muahahaha, hahahaha
has_evil_laugh() {
  local text="$1"
  echo "$text" | grep -qiE '(m[wu]a+(ha+)+|bwa+(ha+)+|(ha+){3,})'
}

# Strip evil laugh patterns from text
strip_evil_laugh() {
  local text="$1"
  # Remove laugh patterns and any trailing punctuation/whitespace
  echo "$text" | sed -E 's/[[:space:]]*(m[wu]a+(ha+)+|bwa+(ha+)+|(ha+){3,})[!.]*[[:space:]]*//gi' | sed 's/[[:space:]]*$//'
}

# Play evil laugh audio
play_evil_laugh() {
  if [[ -f "$EVIL_LAUGH_AUDIO" ]]; then
    timeout 10 paplay "$EVIL_LAUGH_AUDIO" 2>/dev/null || true
  fi
}

# Get current voice
get_voice() {
  local voice="en_US-lessac-medium"
  [[ -f "$VOICE_FILE" ]] && voice=$(cat "$VOICE_FILE")
  echo "$voice"
}

get_model_path() {
  local voice=$(get_voice)
  local model_path="$VOICES_DIR/${voice}.onnx"
  # Security: Validate path doesn't escape VOICES_DIR (prevent path traversal)
  local resolved=$(realpath -m "$model_path" 2>/dev/null || echo "$model_path")
  local voices_resolved=$(realpath -m "$VOICES_DIR" 2>/dev/null || echo "$VOICES_DIR")
  if [[ "$resolved" != "$voices_resolved"/* ]] && [[ "$resolved" != "$voices_resolved" ]]; then
    echo "ERROR: Invalid voice path (potential traversal)" >&2
    return 1
  fi
  echo "$model_path"
}

# Get current reverb setting from config
get_default_reverb() {
  if [[ -f "$EFFECTS_CFG" ]]; then
    local effects=$(grep "^default|" "$EFFECTS_CFG" 2>/dev/null | cut -d'|' -f2)
    if [[ "$effects" =~ reverb ]]; then
      # Extract reverb level name from effects string
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

# Get default background from config
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

# Apply sox reverb to audio file
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

# Mix background audio
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

  # Get voice duration
  local duration
  duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$voice" 2>/dev/null)
  [[ -z "$duration" ]] && { cp "$voice" "$output"; return 0; }

  # Simple mix: background at volume, trimmed to voice duration
  ffmpeg -y -i "$voice" -stream_loop -1 -i "$background" \
    -filter_complex "[1:a]volume=${volume},afade=t=out:st=${duration}:d=0.5[bg];[0:a][bg]amix=inputs=2:duration=first[out]" \
    -map "[out]" -t "$duration" "$output" 2>/dev/null || cp "$voice" "$output"
}

# Process a single TTS request
process_tts() {
  local input="$1"
  local text=""
  local reverb=""
  local background=""
  local volume=""

  # Try to parse as JSON
  if echo "$input" | jq -e . &>/dev/null; then
    text=$(echo "$input" | jq -r '.text // empty')
    reverb=$(echo "$input" | jq -r '.reverb // empty')
    background=$(echo "$input" | jq -r '.background // empty')
    volume=$(echo "$input" | jq -r '.volume // empty')
  else
    # Plain text (backwards compatibility)
    text="$input"
  fi

  [[ -z "$text" ]] && return

  # Check for evil laugh and extract if present
  local play_laugh=false
  if has_evil_laugh "$text"; then
    play_laugh=true
    text=$(strip_evil_laugh "$text")
  fi

  # If text is now empty (was just a laugh), play laugh and return
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
    # Try to find matching track
    local found=$(find "$BACKGROUNDS_DIR" -name "*${background}*" -type f 2>/dev/null | head -1)
    [[ -n "$found" ]] && background="$found"
  fi

  # Security: Use mktemp for unpredictable filenames (prevents symlink attacks)
  mkdir -p "$AUDIO_DIR"
  local raw_wav=$(mktemp "$AUDIO_DIR/daemon-raw-XXXXXX.wav")
  local reverb_wav=$(mktemp "$AUDIO_DIR/daemon-reverb-XXXXXX.wav")
  local final_wav=$(mktemp "$AUDIO_DIR/daemon-final-XXXXXX.wav")

  # Step 1: Generate speech with piper (model is warm = fast)
  echo "$text" | piper --model "$MODEL" --output_file "$raw_wav" 2>/dev/null

  if [[ ! -f "$raw_wav" ]]; then
    echo "ERROR: Piper synthesis failed" >&2
    return 1
  fi

  # Step 2: Apply reverb
  if [[ "$reverb" != "off" ]] && [[ -n "${REVERB_LEVELS[$reverb]:-}" ]]; then
    apply_reverb "$raw_wav" "$reverb_wav" "$reverb"
  else
    cp "$raw_wav" "$reverb_wav"
  fi

  # Step 3: Mix background (if enabled and file exists)
  if [[ -f "$HOME/.claude/config/background-music-enabled.txt" ]] && \
     [[ "$(cat "$HOME/.claude/config/background-music-enabled.txt" 2>/dev/null)" == "true" ]] && \
     [[ -n "$background" ]] && [[ -f "$background" ]]; then
    mix_background "$reverb_wav" "$background" "$volume" "$final_wav"
  else
    cp "$reverb_wav" "$final_wav"
  fi

  # Step 4: Ensure audio stack is healthy
  if ! systemctl --user is-active --quiet pipewire-pulse 2>/dev/null; then
    systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null
    sleep 1
  fi

  # Step 5: Limit concurrent paplay processes (kill oldest if >3)
  # Note: pgrep -c outputs "0" but exits non-zero when no matches, so use separate assignment
  local paplay_count
  paplay_count=$(pgrep -c paplay 2>/dev/null) || paplay_count=0
  if [[ "$paplay_count" -gt 3 ]]; then
    pkill -o paplay 2>/dev/null || true
  fi

  # Step 6: Play audio with timeout (max 5 minutes for long texts)
  timeout 300 paplay "$final_wav" 2>/dev/null || true

  # Step 7: Play evil laugh if detected in original text
  if [[ "$play_laugh" == "true" ]]; then
    sleep 0.2  # Brief pause before laugh
    play_evil_laugh
  fi

  # Small delay to ensure audio buffer is fully flushed to hardware
  sleep 0.5

  # Cleanup temp files
  rm -f "$raw_wav" "$reverb_wav" "$final_wav" 2>/dev/null
}

# Cleanup on exit
cleanup() {
  echo "Enhanced worker shutting down..."
  jobs -p | xargs -r kill 2>/dev/null || true
  exit 0
}

trap cleanup SIGTERM SIGINT SIGHUP

# Setup
mkdir -p "$DAEMON_DIR" "$AUDIO_DIR"

# Security: Create FIFO atomically with ownership verification (prevents TOCTOU race)
# Remove any existing file first, then create fresh FIFO
rm -f "$FIFO_IN" 2>/dev/null
if ! mkfifo -m 600 "$FIFO_IN" 2>/dev/null; then
  # mkfifo failed - could be a race condition where file was recreated
  # Verify it's a FIFO owned by us before proceeding
  if [[ ! -p "$FIFO_IN" ]]; then
    echo "ERROR: Cannot create FIFO: $FIFO_IN" >&2
    exit 1
  fi
  # Verify ownership
  if [[ "$(stat -c '%u' "$FIFO_IN" 2>/dev/null)" != "$(id -u)" ]]; then
    echo "ERROR: FIFO not owned by current user (possible attack): $FIFO_IN" >&2
    exit 1
  fi
fi

# Get model path
MODEL=$(get_model_path)
VOICE=$(get_voice)

if [[ ! -f "$MODEL" ]]; then
  echo "ERROR: Voice model not found: $MODEL" >&2
  exit 1
fi

echo "Piper TTS Enhanced Worker starting"
echo "Voice: $VOICE"
echo "Model: $MODEL"
echo "FIFO: $FIFO_IN"
echo "Default reverb: $(get_default_reverb)"
echo "Effects: sox=$(command -v sox &>/dev/null && echo 'yes' || echo 'no'), ffmpeg=$(command -v ffmpeg &>/dev/null && echo 'yes' || echo 'no'), jq=$(command -v jq &>/dev/null && echo 'yes' || echo 'no')"

# Pre-warm the model by generating a silent sample
echo "Pre-warming model..."
echo "." | piper --model "$MODEL" --output-raw >/dev/null 2>&1 || true
echo "Model warm, ready for requests"

# Main loop - read from FIFO and process each line
while true; do
  # Read a line from FIFO (blocks until input available)
  # Note: read returns non-zero when FIFO has no writers, we ignore this
  if read -r line < "$FIFO_IN" 2>/dev/null; then
    [[ -z "$line" ]] && continue

    # Check if line is a filename (temp file indirection to bypass LINE_MAX limit)
    # Security: Only accept temp files from our daemon directory (prevent arbitrary file read)
    if [[ "$line" == "$DAEMON_DIR"/msg-*.json ]] && [[ -f "$line" ]]; then
      # Read actual content from temp file
      input=$(cat "$line" 2>/dev/null)
      # Delete temp file after reading
      rm -f "$line" 2>/dev/null
      [[ -z "$input" ]] && continue
    else
      # Direct JSON or plain text (backwards compatibility)
      input="$line"
    fi

    # Run synchronously - wait for audio to finish before accepting next request
    # This prevents overlapping audio playback
    process_tts "$input"
  fi
done
