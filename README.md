# 🎤 AgentVibes

> **Finally! Your agents can talk back!**
>
> 🌐 **[agentvibes.org](https://agentvibes.org)**
>
> Professional text-to-speech for **Claude Code**, **Claude Desktop**, and **Warp Terminal** - **ElevenLabs AI** or **Piper TTS (Free!)**

[![npm version](https://img.shields.io/npm/v/agentvibes?color=blue)](https://www.npmjs.com/package/agentvibes)
[![Test Suite](https://github.com/paulpreibisch/AgentVibes/actions/workflows/test.yml/badge.svg)](https://github.com/paulpreibisch/AgentVibes/actions/workflows/test.yml)
[![Publish](https://github.com/paulpreibisch/AgentVibes/actions/workflows/publish.yml/badge.svg)](https://github.com/paulpreibisch/AgentVibes/actions/workflows/publish.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

**Author**: Paul Preibisch ([@997Fire](https://x.com/997Fire)) | **Version**: v2.0.17-beta

---

## ✨ What is AgentVibes?

**AgentVibes adds lively voice narration to your Claude AI sessions!**

Whether you're coding in Claude Code, chatting in Claude Desktop, or using Warp Terminal - AgentVibes brings AI to life with professional voices and personalities.

### 🎯 Key Features

- 🎙️ **AgentVibes MCP** - **NEW!** Natural language control for Claude Code, Claude Desktop & Warp (no slash commands!)
- 📚 **Language Learning Mode** - **NEW!** Learn a second language while you program (e.g., Learn Spanish as you code!)
- 🔊 **SSH Audio Optimization** - **NEW!** Auto-detects remote sessions and eliminates static (VS Code Remote SSH, cloud dev)
- 🎭 **Multi-Provider Support** - Choose ElevenLabs (150+ premium voices) or Piper TTS (50+ free voices)
- 🌍 **30+ Languages** - Multilingual support with native voice quality
- 🎙️ **27+ Professional AI Voices** - Character voices, accents, and unique personalities
- 🎭 **19 Built-in Personalities** - From sarcastic to flirty, pirate to dry humor
- 💬 **Advanced Sentiment System** - Apply personality styles to ANY voice without changing it
- 🔌 **Enhanced BMAD Plugin** - Auto voice switching for BMAD agents with multilingual support
- 🔊 **Live Audio Feedback** - Hear task acknowledgments and completions in any language
- 🎵 **Voice Preview & Replay** - Listen before you choose, replay last 10 TTS messages
- 🆓 **Free Option Available** - Use Piper TTS with no API key required
- ⚡ **One-Command Install** - Get started in seconds

---

## 📑 Table of Contents

### Getting Started
- [🚀 Quick Start](#claude-code-quick-start) - Install in 3 steps
- [✨ What is AgentVibes?](#what-is-agentvibes) - Overview & key features
- [📰 Latest Release](#latest-release) - What's new

### AgentVibes MCP (Natural Language Control)
- [🎙️ AgentVibes MCP Overview](#agentvibes-mcp-easiest-way-to-use-agentvibes) - **Easiest way** - Natural language commands
  - [For Claude Desktop](#for-claude-desktop) - Windows/WSL setup, Python requirements
  - [For Warp Terminal](#for-warp-terminal) - Warp configuration
  - [For Claude Code](#for-claude-code) - Project-specific setup
- [📦 What Gets Installed](#where-settings-are-saved) - MCP dependencies & settings

### Core Features
- [🎤 Commands Reference](#commands-reference) - All available commands
- [📚 Language Learning Mode](#language-learning-mode) - **NEW!** Learn Spanish while you program
- [🎭 Personalities vs Sentiments](#personalities-vs-sentiments) - Two systems explained
- [🗣️ Voice Library](#voice-library) - 27+ professional voices
- [🌍 Multilingual Support](#change-language) - Speak in 30+ languages
- [🔌 BMAD Plugin](#bmad-plugin) - Auto voice switching for BMAD agents

### Advanced Topics
- [📦 Installation Structure](#installation-structure) - What gets installed
- [💡 Usage Examples](#usage-examples) - Common workflows
- [🔧 Advanced Features](#advanced-features) - Custom voices & personalities
- [🔊 Remote Audio Setup](#remote-audio-setup) - Play TTS from remote servers
- [💰 Pricing & Usage](#pricing--usage) - ElevenLabs costs & monitoring
- [❓ Troubleshooting](#troubleshooting) - Common issues & fixes

### Additional Resources
- [🔗 Useful Links](#useful-links) - Voice typing & AI tools
- [🔄 Updating](#updating) - Keep AgentVibes current
- [🙏 Credits](#credits) - Acknowledgments
- [🤝 Contributing](#contributing) - Show support

---

## 📰 Latest Release

**[v2.0.17-beta - Release Notes](https://github.com/paulpreibisch/AgentVibes/releases/tag/v2.0.17-beta)** 🎉

**NEW: Automatic SSH Audio Optimization!** AgentVibes now automatically detects remote SSH sessions and optimizes audio for perfect playback - no more static or clicking sounds!

Plus: **Language Learning Mode** (e.g., Learn Spanish while you program!) with dual-language TTS, **Unified Speech Speed Control**, and **Enhanced MCP Integration** with smart project-specific settings.

**Key highlights:**
- 🔊 **SSH Audio Optimization** - Auto-detects and converts audio for remote SSH sessions (VS Code Remote, regular SSH, cloud dev)
- 📚 **Language Learning Mode** - Dual-language TTS with sequential playback and target language replay
- ⚡ **Unified Speech Speed Control** - Single control for both ElevenLabs and Piper TTS providers
- 🎙️ **Enhanced MCP Integration** - Smart context detection with project-specific settings
- 🎤 **Audio Quality Improvements** - Better bitrate preservation and non-blocking playback
- 🔧 **Improved Provider Switching** - Seamless transitions between ElevenLabs and Piper

[→ View Full Release Notes](RELEASE_NOTES_V2.md) | [→ View All Releases](https://github.com/paulpreibisch/AgentVibes/releases)

---

## 🎙️ AgentVibes MCP (Easiest Way to Use AgentVibes!)

**🎯 The easiest way to control AgentVibes - just talk naturally!**

In addition to installing AgentVibes in Claude Code using the NPX installer, we **highly recommend** installing the AgentVibes MCP server. This allows you to control AgentVibes simply by talking naturally to it (especially if you've installed [WhisperTyping](https://whispertyping.com/)), rather than having to remember slash commands.

**Note:** Slash commands (`/agent-vibes:*`) only work in Claude Code. For Claude Desktop and Warp Terminal, you **must** use the AgentVibes MCP for voice control.

Instead of remembering slash commands like `/agent-vibes:switch Aria`, just say:
- "Switch to Aria voice"
- "Change to pirate personality"
- "Speak in Spanish"
- "List available voices"

### Why Use AgentVibes MCP?

✅ **Natural language** - No commands to memorize

✅ **Works everywhere** - Claude Desktop, Claude Code, Warp Terminal

✅ **Unified interface** - Same tools across all apps

✅ **Smart context** - Project-specific or global settings

### Quick MCP Setup

#### For Claude Desktop

**⚠️ IMPORTANT Requirements:**

- **Windows:** WSL (Windows Subsystem for Linux) must be enabled
- **Python 3:** Must be installed on your system ([Download Python](https://www.python.org/downloads/))
  - The MCP server will automatically install Python packages (mcp, pipx, Piper TTS)
  - But Python 3 itself must be installed first by you

**Step 1: Set Your ElevenLabs API Key (Windows)**

Open Command Prompt or PowerShell and run:
```cmd
setx ELEVENLABS_API_KEY "your-api-key-here"
```

**Important:** After running `setx`, you must:
1. Close Claude Desktop completely (if running)
2. Open a **new** terminal window (the variable won't be available in current terminal)
3. Restart Claude Desktop

**Step 2: Configure Claude Desktop**

Add to `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `%APPDATA%\Claude\claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "agentvibes": {
      "command": "npx",
      "args": ["-y", "agentvibes@beta", "agentvibes-mcp-server"]
    }
  }
}
```

**Note:** The `env` section is optional. Claude Desktop automatically inherits Windows environment variables, so if you've set `ELEVENLABS_API_KEY` with `setx`, it will be available automatically.

#### For Warp Terminal

Add to `~/.warp/mcp.json`:

```json
{
  "agentvibes": {
    "command": "npx",
    "args": ["-y", "agentvibes@beta", "agentvibes-mcp-server"],
    "env": {
      "ELEVENLABS_API_KEY": "${ELEVENLABS_API_KEY}"
    }
  }
}
```

#### For Claude Code

Add to `.mcp-minimal.json` in your project:

```json
{
  "mcpServers": {
    "agentvibes": {
      "command": "npx",
      "args": ["-y", "agentvibes@beta", "agentvibes-mcp-server"],
      "env": {
        "ELEVENLABS_API_KEY": "${ELEVENLABS_API_KEY}"
      }
    }
  }
}
```

**That's it!** Restart the app and start using natural language:

```
"Switch to Northern Terry voice"
"Change personality to sarcastic"
"What voices are available?"
"Speak in French"
"Show my current configuration"
```

### AgentVibes MCP vs Slash Commands

| Feature | AgentVibes MCP | Slash Commands |
|---------|-----------|----------------|
| **Ease of Use** | Natural language | Must remember syntax |
| **Works In** | Claude Desktop, Warp, Claude Code | Claude Code only |
| **Setup** | Add to config file | Auto-installed |
| **Examples** | "Switch voice to Aria" | `/agent-vibes:switch Aria` |

**💡 Recommendation:** Use **AgentVibes MCP for daily use** (easier), **slash commands for scripting** (precise).

### Available AgentVibes MCP Tools

All these work with natural language:

| Tool | Example Command |
|------|-----------------|
| **text_to_speech** | "Say hello in a pirate voice" |
| **list_voices** | "What voices are available?" |
| **set_voice** | "Change to Aria voice" |
| **list_personalities** | "Show me all personalities" |
| **set_personality** | "Set personality to flirty" |
| **set_language** | "Speak in Spanish" |
| **get_config** | "What's my current voice?" |
| **replay_audio** | "Replay the last message" |

### Where Settings Are Saved

The MCP server is smart about where it saves settings:

- **Warp Terminal** → Global `~/.claude/` (terminal-wide settings)
- **Claude Code** → Project `.claude/` (per-project settings)
- **Claude Desktop** → Project `.claude/` (per-project settings)

This means different projects can have different voices/personalities!

[↑ Back to top](#-table-of-contents)

---

## 🚀 Claude Code Quick Start

### Step 1: Install AgentVibes

Choose your preferred installation method:

#### **Option A: Using npx (Recommended)** ⚡
No installation needed! Run directly:
```bash
npx agentvibes install
```

#### **Option B: Install globally via npm** 📦
Install once, use anywhere:
```bash
npm install -g agentvibes
agentvibes install
```

#### **Option C: From source (Development)** 🔧
Clone and run from repository:
```bash
git clone https://github.com/paulpreibisch/AgentVibes.git
cd AgentVibes
npm install
node bin/agent-vibes install
```

### Step 2: Choose Your TTS Provider

AgentVibes supports two TTS providers - pick the one that fits your needs:

#### **Option A: Piper TTS (Free, Recommended for Getting Started)** 🆓

**No setup required!** Piper TTS works out of the box with zero configuration.

- ✅ Completely free, no API key needed
- ✅ Works offline (perfect for Windows, WSL, Linux)
- ✅ 50+ neural voices
- ✅ 18 languages supported
- ✅ Privacy-focused local processing

**To use:** Just install AgentVibes and you're done! The installer will set Piper as default if no ElevenLabs key is detected.

#### **Option B: ElevenLabs (Premium AI Voices)** 🎤

**Best for production and variety.** Requires API key but offers 150+ premium voices.

- ✅ 150+ professional AI voices
- ✅ 30+ languages with multilingual v2
- ✅ Studio-quality audio with emotional range
- ✅ Character voices and unique personalities

**Setup steps:**

1. Sign up at [elevenlabs.io](https://elevenlabs.io/) (free tier: 10,000 chars/month)
2. Copy your API key from the dashboard
3. Add it to your environment:

```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export ELEVENLABS_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc
```

**Switch providers anytime:** `/agent-vibes:provider switch`

### Step 3: Enable Voice ⚠️ **CRITICAL STEP**

#### For Claude Code:
**🔴 REQUIRED:** You MUST run this command to enable TTS in Claude Code:
```bash
/output-style agent-vibes
```

#### For Claude Desktop/Warp:
**Already works!** AgentVibes MCP is enabled by default once configured.

**That's it! Claude will now speak to you!** 🎉

[↑ Back to top](#-table-of-contents)

---

## 🎭 Multi-Provider Support

AgentVibes v2.0 introduces **multi-provider TTS support** - choose between premium ElevenLabs AI voices or free offline Piper TTS!

### 🎤 ElevenLabs (Premium AI Voices)

**Features:**
- 150+ professional AI voices
- 30+ languages with multilingual v2 model
- Studio-quality audio with emotional range
- Character voices, accents, and unique personalities
- Voices include: Aria, Archer, Cowboy Bob, Pirate Marshal, Grandpa Spuds, Jessica Anne Bogart, and more!

**Requirements:**
- ElevenLabs API key (get free tier at [elevenlabs.io](https://elevenlabs.io))
- Internet connection for API calls

**Pricing (2025):**
- Free: 10,000 chars/month (light use)
- Starter: $5/month - 30,000 chars
- Creator: $22/month - 100,000 chars
- Pro: $99/month - 500,000 chars

### 🆓 Piper TTS (Free, Offline)

**Features:**
- 50+ neural voices, completely free
- 18 languages supported
- No API key required
- Works offline (perfect for Windows, WSL, and Linux)
- Privacy-focused local processing
- Cross-platform support (Windows, macOS, Linux)

**Requirements:**
- None! Works out of the box
- Automatic voice download on first use
- Native Windows support - no additional setup needed

### Provider Commands

```bash
# View current provider
/agent-vibes:provider info
# MCP: "What's my current TTS provider?" or "Show provider info"

# List available providers
/agent-vibes:provider list
# MCP: "List all TTS providers" or "What providers are available?"

# Switch providers instantly
/agent-vibes:provider switch
# MCP: "Switch to Piper TTS" or "Change provider to ElevenLabs"

# Test provider functionality
/agent-vibes:provider test
# MCP: "Test my TTS provider" or "Test ElevenLabs connection"
```

### Switching Between Providers

**During Installation:**
The installer asks which provider you prefer and sets it up automatically.

**After Installation:**
```bash
# Switch to Piper TTS (free)
/agent-vibes:provider switch
# Select: piper

# Switch to ElevenLabs (premium)
/agent-vibes:provider switch
# Select: elevenlabs
```

**Automatic Fallback:**
If ElevenLabs API key is missing, AgentVibes automatically falls back to Piper TTS.

### Provider Comparison

| Feature | ElevenLabs | Piper TTS |
|---------|-----------|-----------|
| **Voices** | 150+ premium AI | 50+ neural voices |
| **Cost** | $0-99/month | Free forever |
| **Quality** | Studio-grade | High-quality neural |
| **Languages** | 30+ with multilingual v2 | 18 languages |
| **Offline** | ❌ Requires internet | ✅ Works offline |
| **API Key** | ✅ Required | ❌ Not needed |
| **Emotional Range** | ✅ Advanced | ⚠️ Limited |
| **Character Voices** | ✅ Extensive library | ⚠️ Standard voices |
| **Platform Support** | All platforms | Windows, macOS, Linux, WSL |
| **Best For** | Production, demos, variety | Development, privacy, Windows users |

### Which Provider Should I Choose?

**Choose ElevenLabs if:**
- You want premium studio-quality voices
- You need extensive character voice variety
- You're creating demos or production content
- You want advanced emotional range
- You have a budget for API costs

**Choose Piper TTS if:**
- You want completely free TTS (especially great for Windows!)
- You prefer offline/local processing
- You're on Windows, WSL, or Linux
- You value privacy and data control
- You're in development/testing phase
- You don't want to manage API keys or billing

**Pro Tip:** Use Piper for development and ElevenLabs for production/demos!

[↑ Back to top](#-table-of-contents)

---

## 🎤 Commands Reference

All commands are prefixed with `/agent-vibes:`

### Voice Commands

| Command | AgentVibes MCP Equivalent | Description |
|---------|----------------|-------------|
| `/agent-vibes:list` | "List all voices" or "What voices are available?" | Show all available voices |
| `/agent-vibes:switch <voice>` | "Switch to Aria voice" or "Change voice to Cowboy Bob" | Change to a different voice |
| `/agent-vibes:whoami` | "What's my current voice?" or "Show my configuration" | Show current voice, sentiment & personality |
| `/agent-vibes:preview [N]` | "Preview voices" or "Let me hear the first 5 voices" | Preview voices with audio samples |
| `/agent-vibes:sample <voice>` | "Test Aria voice" or "Let me hear Cowboy Bob" | Test a specific voice |
| `/agent-vibes:add <name> <id>` | "Add custom voice MyVoice with ID abc123" | Add custom ElevenLabs voice |
| `/agent-vibes:replay [N]` | "Replay last message" or "Replay the 3rd message" | Replay recent TTS audio |
| `/agent-vibes:get` | "What voice am I using?" or "Get current voice" | Get currently selected voice |

### System Commands

| Command | AgentVibes MCP Equivalent | Description |
|---------|----------------|-------------|
| `/agent-vibes:version` | "What version of AgentVibes?" or "Show version" | Show installed AgentVibes version |
| `/agent-vibes:update [--yes]` | "Update AgentVibes" or "Upgrade to latest version" | Update to latest version |

### Personality Commands

| Command | AgentVibes MCP Equivalent | Description |
|---------|----------------|-------------|
| `/agent-vibes:personality <name>` | "Set personality to pirate" or "Change to sarcastic personality" | Set personality (changes voice + style) |
| `/agent-vibes:personality list` | "List all personalities" or "What personalities are available?" | Show all personalities |
| `/agent-vibes:personality add <name>` | "Create custom personality called mycustom" | Create custom personality |
| `/agent-vibes:personality edit <name>` | "Edit the flirty personality" | Edit personality file |
| `/agent-vibes:personality get` | "What's my current personality?" or "Show personality" | Show current personality |
| `/agent-vibes:personality reset` | "Reset personality to normal" or "Remove personality" | Reset to normal |

### Sentiment Commands

| Command | AgentVibes MCP Equivalent | Description |
|---------|----------------|-------------|
| `/agent-vibes:sentiment <name>` | "Apply sarcastic sentiment" or "Add flirty sentiment to voice" | Apply sentiment to current voice |
| `/agent-vibes:sentiment list` | "List all sentiments" or "What sentiments are available?" | Show all available sentiments |
| `/agent-vibes:sentiment get` | "What's my current sentiment?" or "Show sentiment" | Show current sentiment |
| `/agent-vibes:sentiment clear` | "Clear sentiment" or "Remove sentiment" | Remove sentiment |

### Language Commands

| Command | AgentVibes MCP Equivalent | Description |
|---------|----------------|-------------|
| `/agent-vibes:set-language <language>` | "Speak in Spanish" or "Change language to French" | Set TTS language (30+ supported) |
| `/agent-vibes:set-language english` | "Reset to English" or "Change language to English" | Reset to English |
| `/agent-vibes:set-language list` | "List all languages" or "What languages are supported?" | Show all supported languages |
| `/agent-vibes:whoami` | "What's my current language?" or "Show configuration" | Show current language + voice |

### BMAD Plugin Commands

| Command | AgentVibes MCP Equivalent | Description |
|---------|----------------|-------------|
| `/agent-vibes-bmad status` | "Show BMAD plugin status" or "What's the BMAD configuration?" | Show BMAD plugin status & mappings |
| `/agent-vibes-bmad enable` | "Enable BMAD voice plugin" or "Turn on BMAD voices" | Enable automatic voice switching |
| `/agent-vibes-bmad disable` | "Disable BMAD plugin" or "Turn off BMAD voices" | Disable plugin (restores previous settings) |
| `/agent-vibes-bmad list` | "List BMAD agent voices" or "Show BMAD voice mappings" | List all BMAD agent voice mappings |
| `/agent-vibes-bmad set <agent> <voice> [personality]` | "Set PM agent to Aria voice with zen personality" | Update agent mapping |
| `/agent-vibes-bmad edit` | "Edit BMAD configuration" or "Open BMAD voice config" | Edit configuration file |

[↑ Back to top](#-table-of-contents)

---

## 📚 Language Learning Mode

**Learn a second language naturally while you program!** 🌍

AgentVibes' Language Learning Mode is a **breakthrough feature** that helps programmers learn new languages through **context and repetition**. Every task acknowledgment and completion is spoken **twice** - first in your native language (English), then in your target language (e.g., Spanish).

### 🎯 Why This Is Revolutionary

**The Problem:** Traditional language learning apps are disconnected from your daily workflow. You have to stop coding, open Duolingo, and study separately.

**The Solution:** With AgentVibes, you learn **while you code**. Every git commit, every build command, every test run - you hear it in English, then immediately in Spanish. Natural, contextual, effortless learning.

### ✨ How It Works

1. **Set your target language** - Choose from 30+ languages (Spanish, French, German, etc.)
2. **Enable learning mode** - One simple command
3. **Code normally** - AgentVibes handles the rest
4. **Hear everything twice** - English first, then your target language
5. **Adjust speed** - Slow down target language for better comprehension

### 🚀 Quick Start (Learn Spanish Example)

```bash
# Step 1: Set Spanish as your target language
/agent-vibes:target spanish

# Step 2: Enable learning mode
/agent-vibes:learn

# Step 3: Code normally!
# Every acknowledgment plays twice:
#   1st: "Starting the build" (English)
#   2nd: "Iniciando la compilación" (Spanish)

# Optional: Slow down Spanish for learning
/agent-vibes:set-speed target 2x    # 2x slower Spanish
```

### 📖 Example Learning Session

```
User: "Run the tests"

Claude (English): "Running your test suite now!"
🔊 Plays in English (Aria voice)

Claude (Spanish): "¡Ejecutando tu suite de pruebas ahora!"
🔊 Plays in Spanish (Antoni voice, 2x slower if configured)

User: "Fix the bug"

Claude (English): "I'll track down that bug for you!"
🔊 Plays in English

Claude (Spanish): "¡Voy a rastrear ese error para ti!"
🔊 Plays in Spanish
```

### 🎓 Why This Works for Learning

1. **Context-based learning** - Hear programming terms in real situations
2. **Spaced repetition** - Natural exposure throughout your coding day
3. **Native pronunciation** - AI voices model perfect accent
4. **Adjustable pace** - Slow down difficult phrases
5. **Consistent exposure** - Build vocabulary passively while working
6. **Zero extra effort** - Learning happens automatically

### 🌍 Supported Target Languages

Spanish, French, German, Italian, Portuguese, Chinese, Japanese, Korean, Russian, Arabic, Hindi, Polish, Dutch, Turkish, Swedish, Danish, Norwegian, Finnish, Czech, Romanian, Ukrainian, Greek, Bulgarian, Croatian, Slovak, and more!

### 🎚️ Advanced Features

**Speech Rate Control:**
```bash
# Slow down target language for better comprehension
/agent-vibes:set-speed target 2x    # 2x slower
/agent-vibes:set-speed target 3x    # 3x slower (best for beginners)
/agent-vibes:set-speed normal       # Reset to normal speed
```

**Mixed Provider Support:**
- Use **ElevenLabs** for English (premium quality)
- Use **Piper TTS** for Spanish (free, adjustable speed)
- System auto-detects provider from voice name

**Auto-Voice Selection:**
- System picks the best voice for your target language
- Provider-aware (ElevenLabs voices for ElevenLabs, Piper voices for Piper)
- Smart fallback if preferred voice unavailable

### 📝 All Language Learning Commands

| Command | Description |
|---------|-------------|
| `/agent-vibes:target <language>` | Set target language to learn (e.g., `spanish`) |
| `/agent-vibes:target-voice <voice>` | Set voice for target language |
| `/agent-vibes:learn` | Enable/disable learning mode |
| `/agent-vibes:language <language>` | Set your native/main language |
| `/agent-vibes:set-speed target <speed>` | Adjust target language speed |
| `/agent-vibes:set-speed get` | Show current speed settings |

### 💡 Pro Tips

1. **Start with 2x slower** - Give yourself time to process
2. **Use Piper TTS for free** - Unlimited practice with no API costs
3. **Learn during routine tasks** - Git commits, builds, tests
4. **Gradually increase speed** - As you improve, speed up the playback
5. **Combine with personalities** - Learn sarcasm in Spanish! 😄

### 🎯 Real-World Use Case

**Before AgentVibes Learning Mode:**
- Study Spanish on Duolingo for 30 minutes
- Context: Random sentences like "The apple is red"
- Total daily practice: 30 minutes

**With AgentVibes Learning Mode:**
- Code for 8 hours with learning mode enabled
- Context: Real programming tasks you're actually doing
- Total daily practice: Hundreds of contextual phrases
- **Result:** Learn programming vocabulary in Spanish naturally!

[↑ Back to top](#-table-of-contents)

---

## 🎭 Personalities vs Sentiments

### 🎪 Personalities (Voice + Style)

**Personalities change BOTH voice AND how Claude talks.** Each has a dedicated ElevenLabs voice:

| Personality | Voice | Style |
|------------|-------|-------|
| **sarcastic** | Jessica Anne Bogart | Dry wit and cutting observations |
| **flirty** | Jessica Anne Bogart | Playful charm and compliments |
| **pirate** | Pirate Marshal | Seafaring swagger - "Arr matey!" |
| **grandpa** | Grandpa Spuds Oxley | Rambling nostalgic stories |
| **dry-humor** | Aria | British wit and deadpan delivery |
| **angry** | Demon Monster | Frustrated and loud |
| **robot** | Dr. Von Fusion | Mechanical and precise |
| **zen** | Aria | Peaceful and mindful |
| **professional** | Matthew Schmitz | Formal and corporate |

**All 19 personalities:** sarcastic, flirty, pirate, grandpa, dry-humor, angry, robot, zen, professional, dramatic, millennial, surfer-dude, sassy, poetic, moody, funny, annoying, crass, normal, random

```bash
/agent-vibes:personality sarcastic
/agent-vibes:personality pirate
/agent-vibes:personality list
```

### 💭 Sentiments (Style Only)

**Sentiments apply personality styles to YOUR current voice:**

```bash
# Use YOUR voice with sarcastic attitude
/agent-vibes:sentiment sarcastic

# Clear sentiment
/agent-vibes:sentiment clear
```

**Key Difference:**
- **Personality** = Changes voice + style (e.g., Pirate Marshal + pirate speak)
- **Sentiment** = Keeps your voice + adds style (e.g., Your Voice + sarcasm)

### 🎤 Combine Voice + Sentiment

```bash
# Switch to Aria with sarcastic sentiment
/agent-vibes:switch Aria --sentiment sarcastic
```

[↑ Back to top](#-table-of-contents)

---

## 🗣️ Voice Library

AgentVibes includes **27 unique ElevenLabs voices** with multilingual support. See full voice library [here](#-voice-library-full-list).

💡 **Tip:** Click voice names to hear samples on ElevenLabs!
🎧 **Try in Claude Code:** `/agent-vibes:preview` to hear all voices
🌍 **Multilingual:** Use Antoni, Rachel, Domi, or Bella for automatic language detection

[→ View Full Voice Library](#-voice-library-full-list)

[↑ Back to top](#-table-of-contents)

---

## 🔌 BMAD Plugin

**Automatically switch voices when using BMAD agents!**

The BMAD plugin detects when you activate a BMAD agent (e.g., `/BMad:agents:pm`) and automatically uses the assigned voice for that role. See full BMAD documentation [here](#-bmad-plugin-full-documentation).

[→ View Full BMAD Documentation](#-bmad-plugin-full-documentation)

[↑ Back to top](#-table-of-contents)

---

## 📦 Installation Structure

See what gets installed [here](#-installation-structure-full-details).

[→ View Full Installation Structure](#-installation-structure-full-details)

[↑ Back to top](#-table-of-contents)

---

## 💡 Usage Examples

### Switch Voices

```bash
/agent-vibes:list                    # See all voices
/agent-vibes:switch Aria             # Switch to Aria
/agent-vibes:switch "Cowboy Bob"     # Switch to Cowboy Bob
/agent-vibes:whoami                  # Check current setup
```

### Try Personalities

```bash
/agent-vibes:personality sarcastic   # Sarcastic + Jessica Anne Bogart
/agent-vibes:personality pirate      # Pirate + Pirate Marshal
/agent-vibes:personality dry-humor   # British wit + Aria
/agent-vibes:personality list        # See all 19 personalities
```

### Use Sentiments

```bash
/agent-vibes:switch Aria             # Set to Aria voice
/agent-vibes:sentiment sarcastic     # Add sarcasm to Aria
/agent-vibes:sentiment clear         # Remove sentiment
```

### Audio Replay

```bash
/agent-vibes:replay                  # Replay last message
/agent-vibes:replay 3                # Replay 3rd-to-last
```

### Voice Preview

```bash
/agent-vibes:preview                 # Hear first 3 voices
/agent-vibes:preview 10              # Hear first 10
/agent-vibes:preview last 5          # Hear last 5
```

### Change Language

Make Claude speak in **30+ languages** using multilingual voices:

```bash
# Set to Spanish
/agent-vibes:set-language spanish

# Set to French
/agent-vibes:set-language french

# Set to German
/agent-vibes:set-language german

# See all supported languages
/agent-vibes:set-language list

# Reset to English
/agent-vibes:set-language english
```

**Supported Languages:**
- Spanish, French, German, Italian, Portuguese
- Chinese, Japanese, Korean, Hindi, Arabic
- Polish, Dutch, Turkish, Swedish, Russian
- And 15+ more!

[↑ Back to top](#-table-of-contents)

---

## 🔧 Advanced Features

### Custom Personalities

1. Create new personality:
   ```bash
   /agent-vibes:personality add mycustom
   ```

2. Edit `.claude/personalities/mycustom.md`:
   ```markdown
   ---
   name: mycustom
   description: My style
   voice: Aria
   ---

   ## AI Instructions
   Speak in your unique style...
   ```

3. Use it:
   ```bash
   /agent-vibes:personality mycustom
   ```

### Add Custom Voices

```bash
# Get voice ID from elevenlabs.io
/agent-vibes:add "My Voice" abc123xyz789
```

### Use in Custom Output Styles

```markdown
I'll do the task
[Bash: .claude/hooks/play-tts.sh "Starting" "Aria"]

... work ...

✅ Done
[Bash: .claude/hooks/play-tts.sh "Complete" "Cowboy Bob"]
```

[↑ Back to top](#-table-of-contents)

---

## 🔊 Remote Audio Setup

**Running AgentVibes on a remote server but want to hear TTS on your local machine?**

We've got you covered! AgentVibes now includes **automatic SSH audio tunnel detection and optimization** for seamless remote audio playback.

### 🎯 Automatic SSH Audio Optimization (v2.0.17+)

**NEW:** AgentVibes automatically detects SSH sessions and optimizes audio for remote playback!

**What it does:**
- ✅ **Auto-detects** remote SSH sessions (VS Code Remote SSH, regular SSH, cloud environments)
- ✅ **Auto-converts** audio to 48kHz stereo WAV format for SSH tunnel compatibility
- ✅ **Eliminates static/clicking** sounds that occur with default audio formats
- ✅ **Zero configuration** - works out of the box

**How it works:**
1. AgentVibes checks for SSH environment variables (`SSH_CONNECTION`, `SSH_CLIENT`, `VSCODE_IPC_HOOK_CLI`)
2. If detected, it converts ElevenLabs audio (44.1kHz mono MP3) to 48kHz stereo WAV
3. Audio plays clearly through your SSH tunnel without static or distortion

**Supported scenarios:**
- 🖥️ **VS Code Remote SSH** - Code from local VS Code, run TTS on remote server
- 🔐 **Regular SSH** - Standard SSH connections with audio tunneling
- ☁️ **Cloud Dev Environments** - AWS, Azure, GCP instances with SSH access

### 📚 Full Remote Audio Setup Guide

For detailed PulseAudio SSH tunnel configuration:

**[→ Remote Audio Setup Guide](docs/remote-audio-setup.md)**

[↑ Back to top](#-table-of-contents)

---

## 💰 Pricing & Usage

### ElevenLabs Pricing (2025)

| Plan | Monthly Cost | Characters/Month | Best For |
|------|-------------|------------------|----------|
| **Free** | $0 | 10,000 | Trying it out, light use |
| **Starter** | $5 | 30,000 | Casual coding (1-2 hrs/day) |
| **Creator** | $22 | 100,000 | Regular coding (4-5 hrs/day) |
| **Pro** | $99 | 500,000 | Heavy daily use (8+ hrs/day) |
| **Scale** | $330 | 2,000,000 | Professional/teams |

### Monitor Your Usage

**Track consumption in real-time:**

1. **Go to ElevenLabs Dashboard**: https://elevenlabs.io/app/usage
2. **Monitor**: Credits used, character breakdown, billing period
3. **Set alerts**: Check usage weekly, watch for spikes

[↑ Back to top](#-table-of-contents)

---

## 🔗 Useful Links

### Voice & AI Tools

- 🎤 **[WhisperTyping](https://whispertyping.com/)** - Fast voice-to-text typing for developers
- 🗣️ **[OpenWhisper (Azure)](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/whisper-overview)** - Microsoft's speech-to-text service
- 🎙️ **[ElevenLabs](https://elevenlabs.io/)** - Premium AI voice synthesis
- 🆓 **[Piper TTS](https://github.com/rhasspy/piper)** - Free offline neural TTS
- 🤖 **[Claude Code](https://claude.com/claude-code)** - AI coding assistant
- 🎭 **[BMAD METHOD](https://github.com/bmad-code-org/BMAD-METHOD)** - Multi-agent framework

### AgentVibes Resources

- 📊 **[Usage Dashboard](https://elevenlabs.io/app/usage)** - Monitor ElevenLabs usage
- 💳 **[Pricing Page](https://elevenlabs.io/pricing)** - ElevenLabs plans
- 🐛 **[Issues](https://github.com/paulpreibisch/AgentVibes/issues)** - Report bugs
- 📝 **[Changelog](https://github.com/paulpreibisch/AgentVibes/releases)** - Version history

[↑ Back to top](#-table-of-contents)

---

## ❓ Troubleshooting

### No Audio Playing?

1. Check API key: `echo $ELEVENLABS_API_KEY`
2. Check output style: `/output-style agent-vibes`
3. Test playback: `/agent-vibes:sample Aria`

### Commands Not Found?

```bash
# Verify installation
npx agentvibes status

# Reinstall
npx agentvibes install --yes
```

### Wrong Voice Playing?

```bash
# Check current setup
/agent-vibes:whoami

# Reset if needed
/agent-vibes:personality reset
/agent-vibes:sentiment clear
```

### MCP Not Working?

1. **Check config file**: Verify JSON syntax in `claude_desktop_config.json` or `.mcp-minimal.json`
2. **Restart app**: Close and reopen Claude Desktop/Warp/Claude Code
3. **Check logs**: Look for MCP connection errors in app logs
4. **Verify npx**: Run `npx -y agentvibes-mcp-server` manually to test

[↑ Back to top](#-table-of-contents)

---

## 🔄 Updating

### Quick Update (From Claude Code)

The fastest way to update is directly from Claude Code:

```bash
/agent-vibes:update
```

This checks for the latest version and updates with confirmation.

### Alternative Methods

#### If installed via npx:
```bash
npx agentvibes update --yes
```

#### If installed globally via npm:
```bash
npm update -g agentvibes
agentvibes update --yes
```

#### If installed from source:
```bash
cd ~/AgentVibes
git pull origin master
npm install
node bin/agent-vibes update --yes
```

### Check Your Version

```bash
/agent-vibes:version
```

### What Gets Updated

The update command will:
- ✅ Update all slash commands
- ✅ Update TTS scripts and plugins
- ✅ Add new personalities (keeps your custom ones)
- ✅ Update output styles
- ✅ Update MCP server
- ✅ Show recent changes and release notes
- ⚠️  Preserves your voice settings and configurations

[↑ Back to top](#-table-of-contents)

---

## ⚠️ Important Disclaimers

**API Costs & Usage:**
- ElevenLabs usage may incur charges based on your subscription tier and character usage
- Users are solely responsible for their own API costs and usage
- Free tier: 10,000 characters/month | Paid plans: $5-99/month
- See [ElevenLabs Pricing](https://elevenlabs.io/pricing) for current rates

**Third-Party Services:**
- This project integrates with ElevenLabs (TTS API) and Piper TTS (local processing)
- We are **not affiliated with, endorsed by, or officially connected** to ElevenLabs, Anthropic, or Claude
- ElevenLabs and Piper TTS are subject to their respective terms of service

**Privacy & Data:**
- **ElevenLabs**: Your text prompts are sent to ElevenLabs servers for processing
- **Piper TTS**: All processing happens locally on your machine, no external data transmission
- Review [ElevenLabs Privacy Policy](https://elevenlabs.io/privacy) for their data handling

**Software License:**
- Provided "as-is" under Apache 2.0 License without warranty of any kind
- See [LICENSE](LICENSE) file for full terms
- No liability for data loss, bugs, service interruptions, or any damages

**Use at Your Own Risk:**
- This is open-source software maintained by the community
- Always test in development before production use
- Monitor your API usage and costs regularly

[↑ Back to top](#-table-of-contents)

---

## 🙏 Credits

**Built with ❤️ by [Paul Preibisch](https://github.com/paulpreibisch)**

- 🐦 Twitter: [@997Fire](https://x.com/997Fire)
- 💼 LinkedIn: [paul-preibisch](https://www.linkedin.com/in/paul-preibisch/)
- 🌐 GitHub: [paulpreibisch](https://github.com/paulpreibisch)

**Powered by:**
- [ElevenLabs](https://elevenlabs.io/) - Premium AI voices
- [Piper TTS](https://github.com/rhasspy/piper) - Free neural voices
- [Claude Code](https://claude.com/claude-code) - AI coding assistant
- Licensed under Apache 2.0

**Special Thanks:**
- 💡 [Claude Code Hooks Mastery](https://github.com/disler/claude-code-hooks-mastery) by [@disler](https://github.com/disler) - Hooks inspiration
- 🤖 [BMAD METHOD](https://github.com/bmad-code-org/BMAD-METHOD) - Multi-agent framework with auto voice switching integration

[↑ Back to top](#-table-of-contents)

---

## 🤝 Contributing

If AgentVibes makes your coding more fun:
- ⭐ **Star this repo** on GitHub
- 🐦 **Tweet** and tag [@997Fire](https://x.com/997Fire)
- 🎥 **Share videos** of Claude with personality
- 💬 **Tell dev friends** about voice-powered AI

---

**Ready to give Claude a voice? Install now and code with personality! 🎤✨**

[↑ Back to top](#-table-of-contents)

---

# 📚 Appendix

## 🗣️ Voice Library (Full List)

### 🌍 Multilingual Voices (Supports 30+ Languages)

Perfect for international projects! These voices work with Spanish, French, German, Italian, Portuguese, and many more languages using ElevenLabs' Multilingual v2 model.

| Voice | Character | Languages | Best For |
|-------|-----------|-----------|----------|
| [Antoni](https://elevenlabs.io/voice-library/antoni/ErXwobaYiN019PkySvjV) | Well-balanced | 30+ | International, Spanish |
| [Rachel](https://elevenlabs.io/voice-library/rachel/21m00Tcm4TlvDq8ikWAM) | Clear, professional | 30+ | Global communication, French |
| [Domi](https://elevenlabs.io/voice-library/domi/AZnzlk1XvdvUeBnXmlld) | Strong, confident | 30+ | Leadership, German |
| [Bella](https://elevenlabs.io/voice-library/bella/EXAVITQu4vr4xnSDxMaL) | Soft, engaging | 30+ | Friendly, Italian |

### 🗣️ Language-Optimized Voices

| Voice | Character | Optimized For |
|-------|-----------|---------------|
| [Charlotte](https://elevenlabs.io/voice-library/charlotte/XB0fDUnXU5powFXDhCwa) | Expressive | French, German, Spanish |
| [Matilda](https://elevenlabs.io/voice-library/matilda/XrExE9yKIg1WjnnlVkGX) | Warm | Spanish, Portuguese |

### 🎭 English Character Voices

| Voice | Character | Best For |
|-------|-----------|----------|
| [Aria](https://elevenlabs.io/voice-library/aria-professional-narration/TC0Zp7WVFzhA8zpTlRqV) | Clear professional | Default, all-purpose |
| [Archer](https://elevenlabs.io/voice-library/archer/L0Dsvb3SLTyegXwtm47J) | Authoritative | Leadership, orchestration |
| [Jessica Anne Bogart](https://elevenlabs.io/voice-library/jessica-anne-bogart/flHkNRp1BlvT73UL6gyz) | Wickedly eloquent | Sarcastic, flirty |
| [Pirate Marshal](https://elevenlabs.io/voice-library/pirate-marshal/PPzYpIqttlTYA83688JI) | Authentic pirate | Pirate personality |
| [Grandpa Spuds Oxley](https://elevenlabs.io/voice-library/grandpa-spuds-oxley/NOpBlnGInO9m6vDvFkFC) | Wise elder | Grandpa personality |
| [Matthew Schmitz](https://elevenlabs.io/voice-library/matthew-schmitz/0SpgpJ4D3MpHCiWdyTg3) | Deep baritone | Professional |
| [Cowboy Bob](https://elevenlabs.io/voice-library/cowboy-bob/KTPVrSVAEUSJRClDzBw7) | Western charm | Casual, friendly |
| [Northern Terry](https://elevenlabs.io/voice-library/northern-terry/wo6udizrrtpIxWGp2qJk) | Eccentric British | Quirky responses |
| [Ms. Walker](https://elevenlabs.io/voice-library/ms-walker/DLsHlh26Ugcm6ELvS0qi) | Warm teacher | Professional |
| [Dr. Von Fusion](https://elevenlabs.io/voice-library/dr-von-fusion/yjJ45q8TVCrtMhEKurxY) | Mad scientist | Robot personality |
| [Michael](https://elevenlabs.io/voice-library/michael/U1Vk2oyatMdYs096Ety7) | British urban | Professional |
| [Ralf Eisend](https://elevenlabs.io/voice-library/ralf-eisend/A9evEp8yGjv4c3WsIKuY) | International | Multi-cultural |
| [Amy](https://elevenlabs.io/voice-library/amy/bhJUNIXWQQ94l8eI2VUf) | Chinese accent | Diverse |
| [Lutz Laugh](https://elevenlabs.io/voice-library/lutz-laugh/9yzdeviXkFddZ4Oz8Mok) | Jovial | Funny |
| [Burt Reynolds](https://elevenlabs.io/voice-library/burt-reynolds/4YYIPFl9wE5c4L2eu2Gb) | Smooth baritone | Confident |
| [Juniper](https://elevenlabs.io/voice-library/juniper/aMSt68OGf4xUZAnLpTU8) | Warm, friendly | Relations |
| [Tiffany](https://elevenlabs.io/voice-library/tiffany/6aDn1KB0hjpdcocrUkmq) | Professional | Leadership |
| [Tom](https://elevenlabs.io/voice-library/tom/DYkrAHD8iwork3YSUBbs) | Professional | Coordination |
| [Demon Monster](https://elevenlabs.io/voice-library/demon-monster/vfaqCOvlrKi4Zp7C2IAm) | Deep, spooky | Dramatic |

[↑ Back to top](#-table-of-contents)

---

## 🔌 BMAD Plugin (Full Documentation)

**Automatically switch voices when using BMAD agents!**

The BMAD plugin detects when you activate a BMAD agent (e.g., `/BMad:agents:pm`) and automatically uses the assigned voice for that role.

### Default BMAD Voice Mappings

| Agent | Role | Voice | Personality |
|-------|------|-------|-------------|
| **pm** | Product Manager | Jessica Anne Bogart | professional |
| **dev** | Developer | Matthew Schmitz | normal |
| **qa** | QA Engineer | Burt Reynolds | professional |
| **architect** | Architect | Michael | normal |
| **po** | Product Owner | Tiffany | professional |
| **analyst** | Analyst | Ralf Eisend | normal |
| **sm** | Scrum Master | Ms. Walker | professional |
| **ux-expert** | UX Expert | Aria | normal |
| **bmad-master** | BMAD Master | Archer | zen |
| **bmad-orchestrator** | Orchestrator | Tom | professional |

### Plugin Management

```bash
# Check status (auto-enables if BMAD detected)
/agent-vibes-bmad status

# Disable plugin
/agent-vibes-bmad disable

# Re-enable plugin
/agent-vibes-bmad enable

# Customize agent voice
/agent-vibes-bmad set pm "Aria" zen

# Edit configuration
/agent-vibes-bmad edit
```

### How It Works

1. **Auto-Detection**: Plugin checks for `.bmad-core/install-manifest.yaml`
2. **Auto-Enable**: Enables automatically when BMAD is detected
3. **Settings Preservation**: Saves your previous voice/personality when enabling
4. **Restore on Disable**: Restores previous settings when disabling

### 🌍 Language Support with BMAD

When you set a language, AgentVibes intelligently selects the best voice:

**Language Priority System:**
1. **BMAD Agent Active** + **Language Set**: Uses multilingual version of agent's assigned voice
   - If agent's voice doesn't support the language → switches to Antoni/Rachel/Domi/Bella (multilingual)
2. **BMAD Agent Active** + **No Language Set**: Uses agent's assigned voice (default English)
3. **No BMAD Agent** + **Language Set**: Uses current voice if multilingual, otherwise switches to Antoni
4. **No BMAD Agent** + **No Language Set**: Uses current voice/personality normally

**Example Workflow:**
```bash
# Set language to Spanish
/agent-vibes:set-language spanish

# Activate BMAD PM agent
/BMad:agents:pm
# → Will try to use Jessica Anne Bogart for Spanish
# → If not multilingual, falls back to Antoni (Spanish-optimized)

# All TTS will speak in Spanish with appropriate voice
```

**Supported Languages:**
- Spanish, French, German, Italian, Portuguese, Chinese, Japanese, Korean, Polish, Dutch, Turkish, Russian, and 20+ more

**Multilingual Fallback Voices:**
- **Antoni** - Best for Spanish
- **Rachel** - Best for French
- **Domi** - Best for German
- **Bella** - Best for Italian
- **Charlotte** - European languages
- **Matilda** - Latin languages

[↑ Back to top](#-table-of-contents)

---

## 📦 Installation Structure (Full Details)

```
your-project/
└── .claude/
    ├── commands/
    │   ├── agent-vibes/              # 15 voice commands
    │   └── agent-vibes-bmad.md       # BMAD plugin command
    ├── hooks/
    │   ├── play-tts.sh               # Main TTS (provider-aware)
    │   ├── play-tts-elevenlabs.sh    # ElevenLabs implementation
    │   ├── play-tts-piper.sh         # Piper implementation
    │   ├── provider-manager.sh       # Provider switching
    │   ├── provider-commands.sh      # Provider CLI
    │   ├── language-manager.sh       # Language system
    │   ├── voice-manager.sh          # Voice switching
    │   ├── personality-manager.sh    # Personality system
    │   ├── sentiment-manager.sh      # Sentiment system
    │   ├── bmad-voice-manager.sh     # BMAD integration
    │   ├── piper-voice-manager.sh    # Piper voices
    │   ├── piper-download-voices.sh  # Piper downloader
    │   └── voices-config.sh          # Voice ID mappings
    ├── personalities/                # 19 personality templates
    ├── plugins/
    │   └── bmad-voices.md            # BMAD voice mappings
    ├── output-styles/
    │   └── agent-vibes.md            # Voice output style
    └── audio/                        # Generated TTS files
```

### Voice Settings Storage

**Project-Local Settings** (`.claude/` in project):
- **Current Provider**: `tts-provider.txt` - Active TTS provider (elevenlabs/piper)
- **Current Voice**: `tts-voice.txt` - Selected voice name
- **Current Personality**: `tts-personality.txt` - Active personality
- **Current Sentiment**: `tts-sentiment.txt` - Active sentiment
- **Current Language**: `tts-language.txt` - Selected language

**Global Fallback** (`~/.claude/`):
Settings fall back to global config if project-local doesn't exist.

**How it works:**
1. AgentVibes checks `.claude/` in current project first
2. Falls back to `~/.claude/` if project setting doesn't exist
3. This allows different voices/personalities per project!

Settings persist across Claude Code sessions!

[↑ Back to top](#-table-of-contents)
