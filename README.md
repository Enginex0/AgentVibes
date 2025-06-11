# 🎭 AgentVibes

[![CI](https://github.com/paulpreibisch/AgentVibes/actions/workflows/ci.yml/badge.svg)](https://github.com/paulpreibisch/AgentVibes/actions/workflows/ci.yml)
[![Tests](https://github.com/paulpreibisch/AgentVibes/actions/workflows/test.yml/badge.svg)](https://github.com/paulpreibisch/AgentVibes/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/paulpreibisch/AgentVibes/branch/master/graph/badge.svg)](https://codecov.io/gh/paulpreibisch/AgentVibes)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![npm version](https://badge.fury.io/js/agentvibes.svg)](https://badge.fury.io/js/agentvibes)
[![GitHub stars](https://img.shields.io/github/stars/paulpreibisch/AgentVibes.svg)](https://github.com/paulpreibisch/AgentVibes/stargazers)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

Beautiful console application to create unlimited themed agent teams for any coding project. Transform your development workflow with AI agents that have distinct personalities, communication styles, and specialized roles.

**Repository**: [github.com/paulpreibisch/AgentVibes](https://github.com/paulpreibisch/AgentVibes)

## ✨ Features

- 🎭 **Themed Personalities** - Matrix, Simpsons, Marvel, Guardians of the Galaxy, Star Wars, Anime
- 🐳 **Docker Integration** - Isolated environments for each agent
- 📊 **GitHub Projects** - Automated project board workflows
- 🔧 **Claude Code Ready** - Pre-configured CLAUDE.md and .mcp.json
- 🚀 **One-Click Launch** - Beautiful CLI with progress indicators
- 🎨 **Fully Customizable** - Create your own themes and characters

## 🎯 Quick Start

```bash
# Install globally
npm install -g agentvibes

# Create teams interactively
agentvibes

# Or use command line
agentvibes --theme matrix --repo https://github.com/user/repo.git
```

## 🎭 Available Themes

### 🕶️ Matrix Universe
**Agents**: Neo, Trinity, Morpheus, Cipher, Oracle, Agent Smith  
*"Agents fighting the system with philosophical depth"*

### 🍩 The Simpsons  
**Agents**: Homer, Bart, Lisa, Marge, Nelson  
*"Springfield's finest with humor and heart"*

### 🦸 Marvel Heroes
**Agents**: Iron Man, Spider-Man, Thor, Hulk  
*"Earth's mightiest programmers"*

### 🚀 Guardians of the Galaxy
**Agents**: Star-Lord, Gamora, Drax, Rocket, Groot  
*"Galaxy's most wanted developers with awesome mixtapes"*

### ⚔️ Star Wars
**Agents**: Luke, Leia, Han Solo, Chewbacca, Darth Vader, Yoda  
*"May the code be with you"*

### 🌸 Anime Characters
**Agents**: Naruto, Sasuke, Goku, Luffy, Tanjiro, Deku  
*"Popular anime characters coding with passion"*

## 🖥️ CLI Experience

### Welcome Screen
```
╭─────────────────────────────────────────╮
│                                         │
│      _                   __     ___     │
│     / \   __ _  ___ _ __ \ \   / (_)    │
│    / _ \ / _` |/ _ \ '_ \| |_| | |     │
│   / ___ \ (_| |  __/ | | |  _  | |     │
│  /_/   \_\__, |\___|_| |_| | |_|_|     │
│          |___/                          │
│                                         │
│    Create themed AI coding teams        │
│                                         │
│  by Paul Preibisch (@paulpreibisch)     │
│  github.com/paulpreibisch/AgentVibes    │
│                                         │
╰─────────────────────────────────────────╯
```

## 🌟 Show Some Love

If AgentVibes helps you build something cool:
- ⭐ Star this repo
- 📣 Tweet about your themed agents @paulpreibisch
- 🎭 Share your agent personalities
- 💬 Tag me in your projects

## 📸 Featured Projects

Using AgentVibes? Open a PR to add your project here!
- Your awesome project could be here!

## 🎭 Powered By

Built with AgentVibes? Give your agents credit:
`Generated with ❤️ by AgentVibes`

Your agents can introduce themselves:
"🕶️ Neo: Powered by AgentVibes from @paulpreibisch"

## 📊 GitHub Projects Integration

Automatically creates and configures GitHub Project boards with workflow automation:

### Workflow Columns
- 📋 **Todo** → 🚀 **In Progress** → ⏸️ **Paused** (optional)
- 👀 **Ready for Review** → 🧪 **Testing PR** → 🔄 **Rework** / ✅ **Merge PR**
- ✨ **Done**

### Automated Commands
Each agent gets project board commands:
```bash
/create-issue "Add authentication feature"
/start-issue 42
/link-pr 42 123
/check-board
```

## 🐳 Generated Structure

```
project-name/
├── agents/
│   ├── neo/                    # 🕶️ Neo's environment
│   │   ├── CLAUDE.md          # Agent personality & instructions
│   │   ├── .mcp.json          # MCP tools configuration
│   │   ├── .git/hooks/        # Auto-emoji commit hooks
│   │   ├── .claude/commands/  # Project board commands
│   │   ├── launch             # Start agent
│   │   ├── down               # Stop agent
│   │   ├── build.sh           # Build script
│   │   └── [cloned-repo]      # Your repository
│   ├── trinity/               # ⚡ Trinity's environment
│   └── morpheus/              # 💊 Morpheus's environment
├── docker/
│   └── docker-compose.matrix.yml
├── scripts/
│   ├── launch-all-teams.sh
│   ├── down-all-teams.sh
│   └── status-check.sh
└── docs/
    ├── TEAM-SETUP.md
    └── CHARACTER-GUIDE.md
```

## 🎨 Character-Driven Development

Each agent maintains their personality in:

### Git Commits
```bash
🕶️ Neo: Question the nature of this authentication bug
⚡ Trinity: Direct fix for API endpoint vulnerability  
💊 Morpheus: Free your mind from legacy code constraints
```

### Issues & PRs
```bash
🕶️ Team-1: There is no spoon - Remove unnecessary validation
⚡ Team-1: Dodge this - Implement bullet-time loading animations
```

## 💻 Command Line API

### Basic Usage
```bash
# Interactive setup
agentvibes

# Quick setup with defaults
agentvibes --theme matrix --repo https://github.com/user/repo.git

# Multiple themes
agentvibes --themes matrix,simpsons,guardians --repo https://github.com/user/project.git

# With project board
agentvibes --theme guardians --repo https://github.com/user/repo.git --project-board

# Dry run (see what would be created)
agentvibes --theme matrix --dry-run
```

### Full Options
```
Options:
  --themes, -t          Comma-separated theme names
  --repo, -r           GitHub repository URL to clone  
  --output, -o         Output directory (default: current)
  --port-start, -p     Starting port number (default: 3011)
  --docker-network     Docker network name
  --project-board      Enable GitHub Projects integration
  --project-id         Use existing project board by ID
  --skip-commands      Skip installing slash commands
  --config, -c         Load configuration from file
  --dry-run           Show what would be created without doing it
  --verbose, -v       Detailed output
```

## 🔧 Prerequisites

- **Node.js 18+** - For running the CLI and agents
- **Git** - With SSH key configured
- **GitHub CLI** - For repository and project board access
- **Docker** (optional) - For containerized environments

### Installation
```bash
# GitHub CLI
brew install gh        # macOS
sudo apt install gh    # Ubuntu
winget install GitHub.cli  # Windows

# Authenticate GitHub CLI
gh auth login
```

## 🎭 Creating Custom Themes

```json
{
  "name": "My Custom Theme",
  "description": "My awesome characters",
  "emoji": "🎭",
  "agents": [
    {
      "id": "character1",
      "name": "Character One", 
      "emoji": "🎪",
      "description": "The leader with great ideas",
      "personality": {
        "traits": ["creative", "bold", "inspiring"],
        "catchphrases": ["Let's make magic!", "Innovation time!"],
        "communication_style": "enthusiastic and creative"
      },
      "ports": { "backend": 3011, "frontend": 5175, "nginx": 3080 },
      "host": "character1.test"
    }
  ]
}
```

## 🌟 Examples in Action

### Matrix Team Working on Authentication
```bash
🕶️ Neo: "What if user authentication is just another layer of the Matrix?"
⚡ Trinity: "Focus, Neo. The vulnerability is in the JWT validation."
💊 Morpheus: "There is no password. Only cryptographic truth."
```

### Simpsons Team Debugging
```bash  
🍩 Homer: "D'oh! This null pointer exception makes me hungry."
🛹 Bart: "Don't have a cow, man. It's just a missing return statement."
🎷 Lisa: "According to my analysis, the root cause is in the data layer."
```

### Guardians Team Planning
```bash
🎧 Star-Lord: "Alright team, we need an awesome plan for this feature."
🦝 Rocket: "I got a plan: we build a really big API!"
🌳 Groot: "I am Groot." (Translation: "That's a solid approach.")
```

## 📝 License

Copyright 2024 Paul Preibisch

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

## 👨‍💻 Author

Created with ❤️ by [Paul Preibisch](https://twitter.com/paulpreibisch)

**Ready to assemble your agentic dream team?** 🚀

```bash
npm install -g agentvibes
agentvibes
```

---

**Repository**: [github.com/paulpreibisch/AgentVibes](https://github.com/paulpreibisch/AgentVibes)  
**Twitter**: [@paulpreibisch](https://twitter.com/paulpreibisch)  
**Created with ❤️ by Paul Preibisch**