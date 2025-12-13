#!/usr/bin/env bash
#
# File: ~/.claude/hooks/session-start-mcp-tts.sh
#
# AgentVibes MCP TTS Protocol Injection (User-Level)
#
# This hook outputs TTS protocol instructions telling Claude to use MCP tools
# instead of Bash hooks. Works across ALL projects via user-level config.
#

# Fix locale warnings
export LC_ALL=C

# Get verbosity level from user-level config
VERBOSITY=$(cat ~/.claude/tts-verbosity.txt 2>/dev/null || echo "low")
PERSONALITY=$(cat ~/.claude/tts-personality.txt 2>/dev/null || echo "normal")

# Output MCP-based TTS protocol instructions
cat <<'EOF'

# AgentVibes TTS Protocol (MCP-Based)

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
- Use MCP aggregator tool for TTS (NOT Bash)
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

# Add verbosity-specific protocol
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

EOF
    ;;

  high)
    cat <<'EOF'
## Verbosity: HIGH (Maximum Transparency)
- Speak acknowledgment and completion (always)
- Speak ALL reasoning, decisions, and findings as you work

EOF
    ;;
esac

# Add current style info
echo "Current Style: ${PERSONALITY}"
echo "Current Verbosity: ${VERBOSITY}"
echo ""

exit 0
