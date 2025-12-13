# MCP Setup

AgentVibes MCP is auto-configured during installation.

```bash
npx github:Enginex0/AgentVibes install
```

MCP allows natural language control instead of slash commands.

---

## Usage

Instead of `/agent-vibes:switch Aria`, say:

- "Switch to Aria voice"
- "Set personality to pirate"
- "Speak in Spanish"
- "List available voices"

---

## Manual Configuration

If MCP wasn't auto-configured, add manually:

### MCP Aggregator

If using MCP Aggregator (`~/.claude/mcp-aggregator/config.json`):

```json
{
  "servers": {
    "agentvibes": {
      "command": "python3",
      "args": ["~/.claude/mcp-server/server.py"],
      "env": {}
    }
  }
}
```

### Claude CLI

```bash
claude mcp add --transport stdio --scope user agentvibes -- python3 ~/.claude/mcp-server/server.py
```

---

## Available Tools

| Tool | Description |
|------|-------------|
| `text_to_speech` | Speak text |
| `set_voice` | Switch voice |
| `set_personality` | Set personality |
| `set_verbosity` | Set verbosity level |
| `list_voices` | List available voices |
| `list_personalities` | List personalities |
| `get_config` | Show current config |
| `mute` / `unmute` | Toggle TTS |
| `set_language` | Set language |
| `set_learn_mode` | Toggle learning mode |
| `set_speed` | Adjust speech rate |
| `set_provider` | Switch TTS provider |

---

## MCP vs Slash Commands

| Feature | MCP | Slash Commands |
|---------|-----|----------------|
| Natural language | Yes | No |
| Works in Claude Desktop | Yes | No |
| Works in Warp | Yes | No |
| Works in Claude Code | Yes | Yes |
| Token overhead | ~1500 tokens | None |

Use slash commands if token usage is a concern.

---

[Back to README](../README.md)
