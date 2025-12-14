#!/usr/bin/env bash
#
# File: .claude/hooks/session-start-mcp-tts.sh
#
# AgentVibes SessionStart Hook - MCP-Based TTS Protocol
#
# This hook outputs TTS protocol instructions telling Claude to use MCP
# aggregator for TTS (faster than Bash subprocess).
#

set -euo pipefail

# Validate HOME is set (required for config paths)
if [[ -z "${HOME:-}" ]]; then
  echo "ERROR: HOME environment variable not set" >&2
  exit 1
fi

# Fix locale warnings
export LC_ALL=C

# Get script directory (use absolute path - critical for different CWD)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source logging utilities (disable with AGENTVIBES_LOGGING=false for ~10ms speedup)
if [[ "${AGENTVIBES_LOGGING:-true}" != "false" ]] && [[ -f "$SCRIPT_DIR/logging-utils.sh" ]]; then
  source "$SCRIPT_DIR/logging-utils.sh"
  av_log_init "session-start-mcp-tts"
  av_log_start "SESSION_START"
  av_log_info "CWD at invocation: $(pwd)"
  av_log_info "SCRIPT_DIR resolved to: $SCRIPT_DIR"
  av_log_info "Mode: MCP (aggregator-based)"
else
  # Minimal stubs when logging disabled (~0.2ms per call vs ~1ms with full logging)
  av_log_info() { :; }
  av_log_warn() { :; }
  av_log_error() { :; }
  av_log_start() { :; }
  av_log_end() { :; }
fi

# Check if piper daemon is running (systemd should auto-start on login)
# Don't block session start - just check and advise
av_log_start "DAEMON_CHECK"
READY_FILE="$HOME/.claude/piper-daemon/ready"
av_log_info "Checking daemon ready file at: $READY_FILE"
if [[ ! -f "$READY_FILE" ]]; then
  av_log_warn "Daemon ready file not found - daemon may not be running"
  # Daemon not running - try systemd start (non-blocking)
  if command -v systemctl &>/dev/null; then
    av_log_info "Attempting systemctl --user start piper-tts (background)"
    systemctl --user start piper-tts 2>/dev/null &
  else
    av_log_warn "systemctl not available - cannot auto-start daemon"
  fi
else
  av_log_info "Daemon ready file exists - daemon appears running"
fi
av_log_end "DAEMON_CHECK"

# Check for sentiment (priority) or personality (fallback)
# OPTIMIZED: Use bash builtin $(<file) instead of cat subshells (saves ~200ms)
av_log_start "CONFIG_LOAD"

# @function _read_cfg
# @intent Fast config file reader using bash builtin (no subshells)
# @why Avoids spawning cat processes, saves ~200ms per session start
# @param $1 config filename (e.g., "tts-sentiment.txt")
# @param $2 default value if file not found
# @returns File contents or default value to stdout
_read_cfg() {
  local file="$1" default="$2"
  if [[ -f ".claude/$file" ]]; then
    echo "$(<".claude/$file")"
  elif [[ -f "$HOME/.claude/$file" ]]; then
    echo "$(<"$HOME/.claude/$file")"
  else
    echo "$default"
  fi
}

SENTIMENT=$(_read_cfg "tts-sentiment.txt" "")
PERSONALITY=$(_read_cfg "tts-personality.txt" "normal")
VERBOSITY=$(_read_cfg "tts-verbosity.txt" "medium")

av_log_info "SENTIMENT=${SENTIMENT:-<empty>}, PERSONALITY=$PERSONALITY, VERBOSITY=$VERBOSITY"

# Determine which to use
if [[ -n "$SENTIMENT" ]]; then
  STYLE_MODE="sentiment"
  STYLE_NAME="$SENTIMENT"
else
  STYLE_MODE="personality"
  STYLE_NAME="$PERSONALITY"
fi
av_log_end "CONFIG_LOAD"

# Output MCP-based TTS protocol instructions to stdout
# Claude Code will add this to the conversation context
cat <<'EOF'

# AgentVibes TTS Protocol (MCP Mode)

**CRITICAL: You MUST execute TTS at TWO points for EVERY user interaction:**

## 1. ACKNOWLEDGMENT (Start of Every Task)
Immediately after receiving ANY user message:
1. Generate a brief, unique acknowledgment message
2. Execute MCP tool:
   ```
   mcp__aggregator__call_tool(server="agentvibes", tool="text_to_speech", input={"text": "[your message]"})
   ```
3. Then proceed with the work

## 2. COMPLETION (End of Every Task)
After finishing the task:
1. Generate a brief, unique completion message
2. Execute MCP tool:
   ```
   mcp__aggregator__call_tool(server="agentvibes", tool="text_to_speech", input={"text": "[your message]"})
   ```

## Rules
- Use MCP aggregator tool for TTS (NOT Bash - MCP is faster)
- Keep messages under 150 characters
- Generate unique messages each time
- This is NOT optional - follow for EVERY interaction

## Example
```
User: "check git status"
[mcp__aggregator__call_tool(server="agentvibes", tool="text_to_speech", input={"text": "I'll check that for you."})]
[... do work ...]
[mcp__aggregator__call_tool(server="agentvibes", tool="text_to_speech", input={"text": "Done! All clean."})]
```

## Other MCP TTS Tools Available
- `list_voices` - List available voices
- `set_voice` - Switch voice
- `list_personalities` - List personalities
- `set_personality` - Change personality style
- `get_config` - View current settings
- `mute` / `unmute` - Control mute state

EOF

# Add verbosity-specific protocol (Issue #32)
case "$VERBOSITY" in
  low)
    cat <<'EOF'
## Verbosity: LOW (Minimal)
- Speak only at acknowledgment (start) and completion (end)
- Do NOT speak reasoning, decisions, or findings during work
- Keep it quiet and focused

EOF
    ;;

  medium)
    cat <<'EOF'
## Verbosity: MEDIUM (Balanced)
- Speak at acknowledgment and completion (always)
- Also speak major decisions and key findings during work
- Use emoji markers for automatic TTS:
  🤔 [decision text] - Major decisions (e.g., "🤔 I'll use grep to search all files")
  ✓ [finding text] - Key findings (e.g., "✓ Found 12 instances at line 1323")

Example:
```
User: "Find all TODO comments"
[TTS: Acknowledgment via MCP]
🤔 I'll use grep to search for TODO comments
[Work happens...]
✓ Found 12 TODO comments across 5 files
[TTS: Completion via MCP]
```

EOF
    ;;

  high)
    cat <<'EOF'
## Verbosity: HIGH (Maximum Transparency)
- Speak acknowledgment and completion (always)
- Speak ALL reasoning, decisions, and findings as you work
- Use emoji markers for automatic TTS:
  💭 [reasoning text] - Thought process (e.g., "💭 Let me search for all instances")
  🤔 [decision text] - Decisions (e.g., "🤔 I'll use grep for this")
  ✓ [finding text] - Findings (e.g., "✓ Found it at line 1323")

Example:
```
User: "Find all TODO comments"
[TTS: Acknowledgment via MCP]
💭 Let me search through the codebase for TODO comments
🤔 I'll use the Grep tool with pattern "TODO"
[Grep runs...]
✓ Found 12 TODO comments across 5 files
💭 Let me organize these results by file
[Processing...]
[TTS: Completion via MCP]
```

IMPORTANT: Use emoji markers naturally in your reasoning text. They trigger automatic TTS.

EOF
    ;;
esac

# Add current style and verbosity info
echo "Current Style: ${STYLE_NAME} (${STYLE_MODE})"
echo "Current Verbosity: ${VERBOSITY}"
echo "TTS Mode: MCP (aggregator-based, faster)"
echo ""

av_log_info "Protocol output complete (MCP mode)"
av_log_end "SESSION_START"
