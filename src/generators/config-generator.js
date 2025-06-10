import path from 'path'
import fs from 'fs-extra'
import Handlebars from 'handlebars'
import { interpolatePersonality, generateTeamIdentity } from '../themes/character-manager.js'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

export async function generateConfigurations(outputDir, characterConfig, options = {}) {
  const { projectConfig, repoUrl } = options
  const agentRoot = path.join(outputDir, characterConfig.paths.root)
  
  try {
    // Generate CLAUDE.md
    await generateClaudeMd(agentRoot, characterConfig, projectConfig)
    
    // Generate .mcp.json
    await generateMcpJson(agentRoot, characterConfig)
    
    // Generate launch scripts
    await generateScripts(agentRoot, characterConfig)
    
    // Generate project commands if project board is enabled
    if (projectConfig) {
      await generateProjectCommands(agentRoot, characterConfig, projectConfig)
    }
    
    // Generate Dockerfile
    await generateDockerfile(agentRoot, characterConfig)
    
    // Generate .env file
    await generateEnvFile(agentRoot, characterConfig, { repoUrl })
  } catch (error) {
    console.error(`Error generating configurations for ${characterConfig.name}:`, error)
    throw error
  }
}

async function generateClaudeMd(agentRoot, config, projectConfig) {
  const templatePath = path.join(__dirname, '../../templates/claude/CLAUDE.md.template')
  let template
  
  try {
    template = await fs.readFile(templatePath, 'utf-8')
  } catch (error) {
    console.warn(`Could not read template at ${templatePath}, using default template`)
    template = getDefaultClaudeTemplate()
  }
  
  // If template is empty, use a default
  if (!template || template.trim() === '') {
    template = getDefaultClaudeTemplate()
  }
  
  const teamIdentity = generateTeamIdentity(config, config.theme, config.teamNumber)
  
  // Register Handlebars helpers
  Handlebars.registerHelper('json', function(context) {
    return JSON.stringify(context, null, 2)
  })
  
  const data = {
    ...config,
    ...teamIdentity,
    projectId: projectConfig?.projectId || '',
    statusFieldId: projectConfig?.statusFieldId || '',
    hasProjectBoard: !!projectConfig,
    catchphrases: config.personality.catchphrases.map(c => `"${c}"`).join(', '),
    hostName: config.host,
    containerName: config.docker.containerName,
    dockerNetwork: config.docker.network
  }
  
  try {
    const compiled = Handlebars.compile(template)
    const content = compiled(data)
    
    await fs.ensureDir(agentRoot)
    await fs.writeFile(path.join(agentRoot, 'CLAUDE.md'), content)
  } catch (error) {
    console.error(`Error compiling/writing CLAUDE.md for ${config.name}:`, error)
    throw error
  }
}

async function generateMcpJson(agentRoot, config) {
  const mcpConfig = {
    name: `${config.name} Agent`,
    version: "1.0.0",
    description: config.description,
    emoji: config.emoji,
    tools: {
      discord: {
        enabled: true,
        channels: [`team-${config.teamNumber}`, `team-${config.teamNumber}-updates`, "general"]
      },
      github: {
        enabled: true,
        features: ["issues", "prs", "projects"]
      },
      docker: {
        enabled: true,
        container: config.docker.containerName
      },
      browser: {
        enabled: true,
        defaultUrl: `http://localhost:${config.ports.frontend}`
      }
    },
    personality: {
      traits: config.personality.traits,
      catchphrases: config.personality.catchphrases,
      style: config.personality.communication_style
    },
    network: {
      backend: `http://localhost:${config.ports.backend}`,
      frontend: `http://localhost:${config.ports.frontend}`,
      host: config.host
    }
  }
  
  await fs.writeFile(
    path.join(agentRoot, '.mcp.json'),
    JSON.stringify(mcpConfig, null, 2)
  )
}

async function generateScripts(agentRoot, config) {
  // Get catchphrase safely
  const catchphrase = config.personality.catchphrases && config.personality.catchphrases.length > 0 
    ? config.personality.catchphrases[0] 
    : "Let's get started!"
  
  // Launch script
  const launchScript = `#!/bin/bash
# Launch script for ${config.emoji} ${config.name}

echo "${config.emoji} ${config.name} says: \\"${catchphrase}\\""
echo "Starting services on ports ${config.ports.backend} (backend) and ${config.ports.frontend} (frontend)..."

# Build if needed
if [ ! -f "built.flag" ]; then
  echo "First time setup - building project..."
  npm install
  npm run build
  touch built.flag
fi

# Start services
npm run dev &
echo $! > .pid

echo "✅ ${config.name} is ready at http://localhost:${config.ports.frontend}"
echo "Backend API at http://localhost:${config.ports.backend}"
`
  
  await fs.writeFile(
    path.join(agentRoot, 'launch'),
    launchScript,
    { mode: 0o755 }
  )
  
  // Down script
  const downScript = `#!/bin/bash
# Shutdown script for ${config.emoji} ${config.name}

echo "Stopping ${config.name}..."

if [ -f .pid ]; then
  kill $(cat .pid) 2>/dev/null
  rm .pid
fi

# Stop any node processes on our ports
lsof -ti:${config.ports.backend} | xargs kill 2>/dev/null
lsof -ti:${config.ports.frontend} | xargs kill 2>/dev/null

echo "✅ ${config.name} stopped"
`
  
  await fs.writeFile(
    path.join(agentRoot, 'down'),
    downScript,
    { mode: 0o755 }
  )
  
  // Build script
  const buildScript = `#!/bin/bash
# Build script for ${config.emoji} ${config.name}

echo "Building ${config.name}..."

# Install dependencies
npm install

# Run build
npm run build

# Run tests
npm test

echo "✅ Build complete for ${config.name}"
`
  
  await fs.writeFile(
    path.join(agentRoot, 'build.sh'),
    buildScript,
    { mode: 0o755 }
  )
}

async function generateProjectCommands(agentRoot, config, projectConfig) {
  const commandsDir = path.join(agentRoot, '.claude/commands')
  await fs.ensureDir(commandsDir)
  
  const commands = {
    'create-issue': {
      content: `#!/bin/bash
# Create new issue and add to project board
issue_title="${config.emoji} Team-${config.teamNumber}: $ARGUMENTS"
issue_body="Created by ${config.emoji} ${config.name}"
issue_num=$(gh issue create --title "$issue_title" --body "$issue_body" | grep -o '[0-9]*$')
gh project item-add ${projectConfig.projectId} --owner OWNER --url https://github.com/OWNER/REPO/issues/$issue_num
echo "✅ Created issue #$issue_num and added to Todo column"`,
      description: 'Create new issue in Todo column'
    },
    'start-issue': {
      content: `#!/bin/bash
# Move issue to In Progress
issue_num="$1"
gh issue edit $issue_num --add-label "in-progress"
gh issue comment $issue_num --body "${config.emoji} ${config.name} says: Starting work on this issue"
# Update project board
item_id=$(gh project item-list ${projectConfig.projectId} --owner OWNER --limit 1000 --format json | jq -r ".items[] | select(.content.number == $issue_num) | .id")
gh project item-edit --project-id ${projectConfig.projectId} --id $item_id --field-id ${projectConfig.statusFieldId} --single-select-option-id IN_PROGRESS_ID
echo "🚀 Moved issue #$issue_num to In Progress"`,
      description: 'Start work on an issue'
    },
    'check-board': {
      content: `#!/bin/bash
# View project board items
echo "📋 Project Board Status for Team ${config.teamNumber}"
gh project item-list ${projectConfig.projectId} --owner OWNER --limit 50 --format table`,
      description: 'View project board items'
    }
  }
  
  for (const [name, command] of Object.entries(commands)) {
    await fs.writeFile(
      path.join(commandsDir, name),
      command.content,
      { mode: 0o755 }
    )
  }
}

async function generateDockerfile(agentRoot, config) {
  const dockerfile = `# Dockerfile for ${config.name}
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Build application
RUN npm run build

# Expose ports
EXPOSE ${config.ports.backend}
EXPOSE ${config.ports.frontend}

# Set environment variables
ENV NODE_ENV=production
ENV AGENT_NAME="${config.name}"
ENV AGENT_EMOJI="${config.emoji}"
ENV BACKEND_PORT=${config.ports.backend}
ENV FRONTEND_PORT=${config.ports.frontend}

# Start application
CMD ["npm", "start"]
`
  
  await fs.writeFile(
    path.join(agentRoot, 'Dockerfile'),
    dockerfile
  )
}

async function generateEnvFile(agentRoot, config, options) {
  const envContent = `# Environment configuration for ${config.name}
NODE_ENV=development
AGENT_NAME=${config.name}
AGENT_EMOJI=${config.emoji}
AGENT_ID=${config.id}
TEAM_NUMBER=${config.teamNumber}
THEME=${config.theme}

# Ports
BACKEND_PORT=${config.ports.backend}
FRONTEND_PORT=${config.ports.frontend}
NGINX_PORT=${config.ports.nginx}

# Network
HOST_NAME=${config.host}
DOCKER_NETWORK=${config.docker.network}

# Repository
REPO_URL=${options.repoUrl || ''}

# Features
ENABLE_DISCORD=true
ENABLE_GITHUB=true
ENABLE_DOCKER=true
`
  
  await fs.writeFile(
    path.join(agentRoot, '.env'),
    envContent
  )
}

function getDefaultClaudeTemplate() {
  // Read the actual template file
  const templatePath = path.join(__dirname, '../../templates/claude/CLAUDE.md.template')
  try {
    return fs.readFileSync(templatePath, 'utf-8')
  } catch (error) {
    // Fallback template if file not found
    return `# CLAUDE.md - {{name}} Configuration

## Agent Identity
- **Name**: {{emoji}} {{name}}
- **Team**: Team {{teamNumber}} - {{theme}}
- **Description**: {{description}}
- **Communication Style**: {{personality.communication_style}}

## Personality Traits
{{#each personality.traits}}
- {{this}}
{{/each}}

## Catchphrases
{{catchphrases}}

## Working Directory
When working in this agent's directory, you are {{name}} from {{theme}}.
Embrace your character's personality and communication style.

## Git Commit Protocol
When creating commits, always prepend your emoji:
\`\`\`bash
git commit -m "{{emoji}} {{name}}: Your commit message"
\`\`\`

## Issue Creation Protocol
When creating issues:
\`\`\`bash
gh issue create --title "{{emoji}} Team-{{teamNumber}}: Issue title"
\`\`\`

## PR Creation Protocol
When creating PRs:
\`\`\`bash
gh pr create --title "{{emoji}} Team-{{teamNumber}}: PR title"
\`\`\`

## Comment Protocol
When commenting on issues/PRs:
"{{emoji}} {{name}} says: Your comment here"

{{#if hasProjectBoard}}
## 🚨 PROJECT BOARD IS MANDATORY - NOT OPTIONAL

**Project ID**: {{projectId}}
**Status Field ID**: {{statusFieldId}}

### Workflow Commands
- \`/create-issue\` - Create new issue in Todo column
- \`/check-board\` - View project board status
- \`/start-issue [#]\` - Move issue to In Progress
- \`/link-pr [issue#] [PR#]\` - Link PR to issue

### Important
You MUST keep the project board updated at all times. This is not optional.
{{/if}}
`
  }
}