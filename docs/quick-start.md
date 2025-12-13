# Quick Start

Get AgentVibes running in 3 steps.

## macOS Users

Install bash 5.x first:

```bash
brew install bash
```

macOS ships with bash 3.2 which lacks features AgentVibes needs.

---

## Step 1: Install

```bash
npx github:Enginex0/AgentVibes install
```

This installs hooks, personalities, MCP server, and systemd service.

## Step 2: Install Piper TTS

```bash
pipx install piper-tts
```

Download a voice:
```bash
~/.claude/hooks/piper-voice-manager.sh download en_US-lessac-medium
```

## Step 3: Start Daemon (Linux)

```bash
systemctl --user start piper-tts
systemctl --user enable piper-tts
```

## Test

```bash
~/.claude/hooks/play-tts.sh "Hello world"
```

Or in Claude Code:
```bash
/agent-vibes:sample Aria
```

---

## Commands

```bash
/agent-vibes:list              # List voices
/agent-vibes:switch Aria       # Switch voice
/agent-vibes:personality pirate # Set personality
/agent-vibes:verbosity medium  # Set verbosity
```

---

## Uninstall

```bash
npx github:Enginex0/AgentVibes uninstall
```

---

[Back to README](../README.md)
