# AgentVibes

Text-to-speech for Claude Code, Claude Desktop, and Warp Terminal.

**Piper TTS** (free, offline) or **macOS Say** (built-in).

---

## Install

```bash
npx github:Enginex0/AgentVibes install
```

Done. Claude can now speak.

---

## Uninstall

```bash
npx github:Enginex0/AgentVibes uninstall
```

Removes all AgentVibes files. Non-AgentVibes hooks preserved.

---

## Requirements

| Platform | Requirements |
|----------|-------------|
| Linux/WSL | Node.js 16+, Python 3.10+, sox, ffmpeg |
| macOS | Node.js 16+, bash 5.x (`brew install bash`) |
| Windows | WSL required |

**Piper TTS** (auto-installed):
```bash
pipx install piper-tts
```

---

## Usage

### Slash Commands

```bash
/agent-vibes:list                    # List voices
/agent-vibes:switch Aria             # Switch voice
/agent-vibes:personality pirate      # Set personality
/agent-vibes:verbosity medium        # Set verbosity (low/medium/high)
/agent-vibes:set-language spanish    # Speak in Spanish
```

### MCP (Natural Language)

Say "Switch to Aria voice" or "Speak in Spanish" instead of typing commands.

MCP is auto-configured during install.

### Shell

```bash
~/.claude/hooks/play-tts.sh "Hello world"
```

---

## Voices

25+ Piper voices included. Preview with:

```bash
/agent-vibes:preview
```

Switch voices:
```bash
/agent-vibes:switch en_US-lessac-medium
```

---

## Personalities

19 built-in personalities:

| Personality | Description |
|-------------|-------------|
| normal | Professional, clear |
| pirate | Seafaring swagger |
| sarcastic | Dry wit |
| dramatic | Theatrical flair |
| grandpa | Nostalgic storyteller |
| robot | Mechanical, precise |
| rapper | Rhymes and wordplay |
| zen | Peaceful, mindful |

Full list:
```bash
/agent-vibes:personality list
```

---

## Verbosity Control

Control how much Claude speaks:

| Level | What Gets Spoken |
|-------|-----------------|
| low | Acknowledgments + completions only |
| medium | + Major decisions and findings |
| high | All reasoning (maximum transparency) |

```bash
/agent-vibes:verbosity low
```

---

## Language Learning Mode

Learn a language while coding. Every message plays twice - English then target language.

```bash
/agent-vibes:target spanish
/agent-vibes:learn enable
```

30+ languages supported.

---

## Piper Daemon (Linux)

For faster TTS, use the systemd daemon:

```bash
systemctl --user start piper-tts
systemctl --user enable piper-tts  # Auto-start
```

---

## MCP Tools

26 tools available via MCP:

- `text_to_speech` - Speak text
- `set_voice` - Switch voice
- `set_personality` - Set personality
- `set_verbosity` - Set verbosity level
- `list_voices` - List available voices
- `list_personalities` - List personalities
- `get_config` - Show current config
- `mute` / `unmute` - Toggle TTS
- `set_language` - Set language
- `set_learn_mode` - Toggle learning mode
- `set_speed` - Adjust speech rate
- `replay_audio` - Replay last message

---

## File Locations

| Purpose | Path |
|---------|------|
| Hooks | `~/.claude/hooks/` |
| Personalities | `~/.claude/personalities/` |
| Config | `~/.claude/tts-*.txt` |
| MCP Server | `~/.claude/mcp-server/server.py` |
| Daemon | `~/.claude/scripts/piper-worker-enhanced.sh` |

---

## Troubleshooting

**No audio?**
```bash
# Check hook exists
ls ~/.claude/hooks/play-tts.sh

# Test manually
~/.claude/hooks/play-tts.sh "Test"

# Check daemon
systemctl --user status piper-tts
```

**Commands not found?**
```bash
npx github:Enginex0/AgentVibes install
```

**macOS bash error?**
```bash
brew install bash
```

---

## License

Apache 2.0

Based on [paulpreibisch/AgentVibes](https://github.com/paulpreibisch/AgentVibes).
