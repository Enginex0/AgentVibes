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

**🎯 Control AgentVibes with natural language - no slash commands to remember!**

Just say "Switch to Aria voice" or "Speak in Spanish" instead of typing commands.

**Works in:** Claude Desktop, Claude Code, Warp Terminal

**[→ View Complete MCP Setup Guide](docs/mcp-setup.md)** - Full setup for all platforms, configuration examples, available tools, and MCP vs slash commands comparison

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

AgentVibes supports **two TTS providers** - choose between premium ElevenLabs AI voices or free offline Piper TTS!

**Quick Comparison:**
- **ElevenLabs**: 150+ premium voices, 30+ languages, studio-quality (requires API key, $0-99/month)
- **Piper TTS**: 50+ neural voices, 18 languages, completely free, works offline (no API key needed)

**Switch providers anytime:**
```bash
/agent-vibes:provider switch
# Or: "Switch to Piper TTS" (MCP)
```

**[→ View Complete Provider Guide](docs/providers.md)** - Full comparison, pricing, features, and setup instructions

[↑ Back to top](#-table-of-contents)

---

## 🎤 Commands Reference

AgentVibes provides **50+ slash commands** and **natural language MCP equivalents**.

**Quick Examples:**
```bash
# Voice control
/agent-vibes:switch Aria              # Or: "Switch to Aria voice"
/agent-vibes:list                     # Or: "List all voices"

# Personality & sentiment
/agent-vibes:personality pirate       # Or: "Set personality to pirate"
/agent-vibes:sentiment sarcastic      # Or: "Apply sarcastic sentiment"

# Language & learning
/agent-vibes:set-language spanish     # Or: "Speak in Spanish"
/agent-vibes:learn                    # Or: "Enable learning mode"
```

**[→ View Complete Command Reference](docs/commands.md)** - All voice, system, personality, sentiment, language, and BMAD commands with MCP equivalents

[↑ Back to top](#-table-of-contents)

---

## 📚 Language Learning Mode

**🎯 Learn Spanish (or 30+ languages) while you program!** 🌍

Every task acknowledgment plays **twice** - first in English, then in your target language. Context-based learning while you code!

**[→ View Complete Learning Mode Guide](docs/language-learning-mode.md)** - Full tutorial, quick start, commands, speech rate control, supported languages, and pro tips

[↑ Back to top](#-table-of-contents)

---

## 🎭 Personalities vs Sentiments

**Two ways to add personality to Claude's voice:**

### 🎪 Personalities (Voice + Style)
Changes **both** voice AND how Claude talks. Each personality has a dedicated voice.

**Examples:** `sarcastic`, `pirate`, `grandpa`, `flirty`, `zen`, `robot`

```bash
/agent-vibes:personality pirate       # Uses Pirate Marshal voice + pirate speak
```

### 💭 Sentiments (Style Only)
Applies personality style to **your current voice** without changing it.

```bash
/agent-vibes:switch Aria              # Set voice
/agent-vibes:sentiment sarcastic      # Add sarcasm to Aria
```

**Key Difference:**
- **Personality** = Changes voice + style
- **Sentiment** = Keeps your voice + adds style

**[→ View Complete Personalities Guide](docs/personalities.md)** - All 19 personalities, voice mappings, and how to create custom ones

[↑ Back to top](#-table-of-contents)

---

## 🗣️ Voice Library

AgentVibes includes **27 unique ElevenLabs voices** with multilingual support.

💡 **Tip:** Click voice names to hear samples on ElevenLabs!
🎧 **Try in Claude Code:** `/agent-vibes:preview` to hear all voices
🌍 **Multilingual:** Use Antoni, Rachel, Domi, or Bella for automatic language detection

**[→ View Complete Voice Library](docs/voice-library.md)** - All 27 voices with clickable samples, descriptions, and best use cases

[↑ Back to top](#-table-of-contents)

---

## 🔌 BMAD Plugin

**Automatically switch voices when using BMAD agents!**

The BMAD plugin detects when you activate a BMAD agent (e.g., `/BMad:agents:pm`) and automatically uses the assigned voice for that role.

**[→ View Complete BMAD Documentation](docs/bmad-plugin.md)** - All agent mappings, language support, plugin management, and customization

[↑ Back to top](#-table-of-contents)

---

## 📦 Installation Structure

**What gets installed:** Commands, hooks, personalities, plugins, and output styles in `.claude/` directory.

**[→ View Complete Installation Structure](docs/installation-structure.md)** - Full directory tree, file descriptions, and settings storage

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

AgentVibes supports **custom personalities**, **custom voices**, and **integration with custom output styles**.

**Quick Examples:**
```bash
# Create custom personality
/agent-vibes:personality add mycustom

# Add custom ElevenLabs voice
/agent-vibes:add "My Voice" abc123xyz789

# Use in custom output styles
[Bash: .claude/hooks/play-tts.sh "Starting" "Aria"]
```

**[→ View Advanced Features Guide](docs/advanced-features.md)** - Custom personalities, custom voices, output style integration

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

**ElevenLabs Pricing (2025):**
- **Free**: $0/month - 10,000 chars (light use)
- **Starter**: $5/month - 30,000 chars (1-2 hrs/day)
- **Creator**: $22/month - 100,000 chars (4-5 hrs/day)
- **Pro**: $99/month - 500,000 chars (8+ hrs/day)

**Monitor Usage:** [ElevenLabs Dashboard](https://elevenlabs.io/app/usage)

**[→ View Complete Pricing Guide](docs/pricing.md)** - Full pricing breakdown, usage monitoring, and cost optimization tips

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

**Common Issues:**

**No Audio Playing?**
1. Check API key: `echo $ELEVENLABS_API_KEY`
2. Enable output style: `/output-style agent-vibes`
3. Test: `/agent-vibes:sample Aria`

**Commands Not Found?**
```bash
npx agentvibes install --yes
```

**[→ View Complete Troubleshooting Guide](docs/troubleshooting.md)** - Solutions for audio issues, command problems, MCP errors, voice issues, and more

[↑ Back to top](#-table-of-contents)

---

## 🔄 Updating

**Quick Update (From Claude Code):**
```bash
/agent-vibes:update
```

**Alternative Methods:**
```bash
# Via npx
npx agentvibes update --yes

# Via npm (if installed globally)
npm update -g agentvibes && agentvibes update --yes
```

**Check Version:** `/agent-vibes:version`

**[→ View Complete Update Guide](docs/updating.md)** - All update methods, version checking, what gets updated, and troubleshooting

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

