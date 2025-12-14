#!/usr/bin/env bash
#
# File: .claude/hooks/session-start-tts.sh
#
# AgentVibes SessionStart Hook - Injects TTS Protocol Instructions
#
# This hook outputs TTS protocol instructions to stdout, which Claude Code
# adds to the conversation context at session start.
#

set -euo pipefail

# Fix locale warnings
export LC_ALL=C

# Get script directory (use absolute path - critical for different CWD)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source logging utilities
if [[ -f "$SCRIPT_DIR/logging-utils.sh" ]]; then
  source "$SCRIPT_DIR/logging-utils.sh"
  av_log_init "session-start-tts"
  av_log_start "SESSION_START"
  av_log_info "CWD at invocation: $(pwd)"
  av_log_info "SCRIPT_DIR resolved to: $SCRIPT_DIR"
else
  # Fallback if logging not available
  av_log_info() { :; }
  av_log_warn() { :; }
  av_log_error() { :; }
  av_log_start() { :; }
  av_log_end() { :; }
fi

# Check if AgentVibes is installed
if [[ ! -f "$SCRIPT_DIR/play-tts.sh" ]]; then
  # AgentVibes not installed, don't inject anything
  av_log_warn "play-tts.sh not found at $SCRIPT_DIR - AgentVibes not installed"
  av_log_end "SESSION_START" "SKIP"
  exit 0
fi
av_log_info "AgentVibes installation verified"

# Check if piper daemon is running (systemd should auto-start on login)
# Don't block session start - just check and advise
av_log_start "DAEMON_CHECK"
DAEMON_FIFO="$HOME/.claude/piper-daemon/input.fifo"
av_log_info "Checking daemon FIFO at: $DAEMON_FIFO"
if [[ ! -p "$DAEMON_FIFO" ]]; then
  av_log_warn "Daemon FIFO not found - daemon may not be running"
  # Daemon not running - try systemd start (non-blocking)
  if command -v systemctl &>/dev/null; then
    av_log_info "Attempting systemctl --user start piper-tts (background)"
    systemctl --user start piper-tts 2>/dev/null &
  else
    av_log_warn "systemctl not available - cannot auto-start daemon"
  fi
else
  av_log_info "Daemon FIFO exists - daemon appears running"
fi
av_log_end "DAEMON_CHECK"

# Check for sentiment (priority) or personality (fallback)
av_log_start "CONFIG_LOAD"
av_log_info "Loading config - checking project-level then user-level"

SENTIMENT=$(cat .claude/tts-sentiment.txt 2>/dev/null || cat ~/.claude/tts-sentiment.txt 2>/dev/null || echo "")
PERSONALITY=$(cat .claude/tts-personality.txt 2>/dev/null || cat ~/.claude/tts-personality.txt 2>/dev/null || echo "normal")

av_log_info "SENTIMENT=${SENTIMENT:-<empty>}"
av_log_info "PERSONALITY=$PERSONALITY"

# Determine which to use
if [[ -n "$SENTIMENT" ]]; then
  STYLE_MODE="sentiment"
  STYLE_NAME="$SENTIMENT"
else
  STYLE_MODE="personality"
  STYLE_NAME="$PERSONALITY"
fi
av_log_info "Using STYLE_MODE=$STYLE_MODE, STYLE_NAME=$STYLE_NAME"

# Get verbosity level (Issue #32)
VERBOSITY=$(cat .claude/tts-verbosity.txt 2>/dev/null || cat ~/.claude/tts-verbosity.txt 2>/dev/null || echo "low")
av_log_info "VERBOSITY=$VERBOSITY"
av_log_end "CONFIG_LOAD"

# Output TTS protocol instructions to stdout
# Claude Code will add this to the conversation context
cat <<'EOF'

# AgentVibes TTS Protocol

**CRITICAL: You MUST execute TTS at TWO points for EVERY user interaction:**

## 1. ACKNOWLEDGMENT (Start of Every Task)
Immediately after receiving ANY user message:
1. Generate a brief, unique acknowledgment message
2. Execute: `Bash: ~/.claude/hooks/play-tts.sh "[your message]"`
3. Then proceed with the work

## 2. COMPLETION (End of Every Task)
After finishing the task:
1. Generate a brief, unique completion message
2. Execute: `Bash: ~/.claude/hooks/play-tts.sh "[your message]"`

## Rules
- Use Bash tool to execute play-tts.sh
- Keep messages under 150 characters
- Generate unique messages each time
- Use absolute path: ~/.claude/hooks/play-tts.sh
- This is NOT optional - follow for EVERY interaction

## Example
```
User: "check git status"
[Bash: ~/.claude/hooks/play-tts.sh "I'll check that for you."]
[... do work ...]
[Bash: ~/.claude/hooks/play-tts.sh "Done! All clean."]
```

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
[TTS: Acknowledgment]
🤔 I'll use grep to search for TODO comments
[Work happens...]
✓ Found 12 TODO comments across 5 files
[TTS: Completion]
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
[TTS: Acknowledgment]
💭 Let me search through the codebase for TODO comments
🤔 I'll use the Grep tool with pattern "TODO"
[Grep runs...]
✓ Found 12 TODO comments across 5 files
💭 Let me organize these results by file
[Processing...]
[TTS: Completion]
```

IMPORTANT: Use emoji markers naturally in your reasoning text. They trigger automatic TTS.

EOF
    ;;
esac

# Add current style and verbosity info
echo "Current Style: ${STYLE_NAME} (${STYLE_MODE})"
echo "Current Verbosity: ${VERBOSITY}"
echo ""

av_log_info "Protocol output complete"
av_log_end "SESSION_START"
